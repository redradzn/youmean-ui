import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Stores location data including coordinates
class LocationData {
  final String displayName;
  final double latitude;
  final double longitude;

  LocationData({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });
}

/// Location autocomplete using OpenStreetMap Nominatim API
class LocationAutocomplete extends StatefulWidget {
  final TextEditingController controller;
  final Function(LocationData) onLocationSelected;
  final bool isDark;

  const LocationAutocomplete({
    super.key,
    required this.controller,
    required this.onLocationSelected,
    required this.isDark,
  });

  @override
  State<LocationAutocomplete> createState() => _LocationAutocompleteState();
}

class _LocationAutocompleteState extends State<LocationAutocomplete> {
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounceTimer;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isSelecting = false; // Prevents actions during selection
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _hideDropdown();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus && !_isSelecting) {
      // Small delay to allow tap on dropdown item to register
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!_focusNode.hasFocus && !_isSelecting) {
          _hideDropdown();
        }
      });
    } else if (_focusNode.hasFocus && _suggestions.isNotEmpty && !_isSelecting) {
      // Show dropdown when field is focused and we have suggestions
      _showDropdown();
    }
  }

  void _onTextChanged() {
    // Don't search if we're in the middle of selecting
    if (_isSelecting) return;

    _debounceTimer?.cancel();

    final query = widget.controller.text.trim();
    if (query.length < 2) {
      _hideDropdown();
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    // 300ms debounce
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _searchLocations(query);
    });
  }

  Future<void> _searchLocations(String query) async {
    if (_isSelecting) return;

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(query)}'
        '&format=json'
        '&limit=5'
        '&addressdetails=1',
      );

      final response = await http.get(uri, headers: {
        'User-Agent': 'YouMeanApp/1.0',
      });

      if (_isSelecting) return; // Check again after async

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (mounted && !_isSelecting) {
          setState(() {
            _suggestions = data.cast<Map<String, dynamic>>();
            _isLoading = false;
          });

          if (_suggestions.isNotEmpty && _focusNode.hasFocus) {
            _showDropdown();
          } else {
            _hideDropdown();
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _hideDropdown();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _hideDropdown();
      }
    }
  }

  /// Parse and clean the display_name intelligently
  String _formatLocation(Map<String, dynamic> item) {
    final address = item['address'] as Map<String, dynamic>?;

    if (address == null) {
      return _cleanDisplayName(item['display_name'] ?? '');
    }

    final city = address['city'] ??
                 address['town'] ??
                 address['village'] ??
                 address['municipality'] ??
                 address['hamlet'] ??
                 address['locality'] ?? '';

    final state = address['state'] ??
                  address['region'] ??
                  address['province'] ?? '';

    final country = address['country'] ?? '';

    List<String> parts = [];

    if (city.isNotEmpty) parts.add(city);

    if (state.isNotEmpty && state != city && state != country) {
      parts.add(state);
    }

    if (country.isNotEmpty && country != city) {
      parts.add(country);
    }

    if (parts.isEmpty) {
      return _cleanDisplayName(item['display_name'] ?? '');
    }

    return _removeDuplicates(parts.join(', '));
  }

  String _removeDuplicates(String text) {
    final parts = text.split(', ');
    final seen = <String>{};
    final unique = <String>[];

    for (final part in parts) {
      final normalized = part.trim().toLowerCase();
      if (!seen.contains(normalized) && part.trim().isNotEmpty) {
        seen.add(normalized);
        unique.add(part.trim());
      }
    }

    return unique.join(', ');
  }

  String _cleanDisplayName(String displayName) {
    final parts = displayName.split(',')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    if (parts.length <= 3) {
      return _removeDuplicates(parts.join(', '));
    }

    final city = parts.first;
    final country = parts.last;

    String? region;
    if (parts.length > 3) {
      region = parts[parts.length - 2];
      if (RegExp(r'^\d').hasMatch(region)) {
        region = parts.length > 4 ? parts[parts.length - 3] : null;
      }
    }

    List<String> result = [city];
    if (region != null && region != city && region != country) {
      result.add(region);
    }
    result.add(country);

    return _removeDuplicates(result.join(', '));
  }

  void _selectLocation(Map<String, dynamic> item) {
    // Set selecting flag to prevent any other actions
    _isSelecting = true;

    final formattedName = _formatLocation(item);
    final lat = double.tryParse(item['lat']?.toString() ?? '0') ?? 0;
    final lon = double.tryParse(item['lon']?.toString() ?? '0') ?? 0;

    // Update text field immediately with the selected location
    widget.controller.text = formattedName;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: formattedName.length),
    );

    // Clear suggestions
    setState(() {
      _suggestions = [];
      _isLoading = false;
    });

    // Notify parent with location data
    widget.onLocationSelected(LocationData(
      displayName: formattedName,
      latitude: lat,
      longitude: lon,
    ));

    // Hide dropdown after 300ms
    Future.delayed(const Duration(milliseconds: 300), () {
      _hideDropdown();
      _focusNode.unfocus();
      _isSelecting = false;
    });
  }

  void _showDropdown() {
    if (_overlayEntry != null || _isSelecting) return;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: Colors.transparent,
            child: _buildDropdown(),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildDropdown() {
    if (_suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: _suggestions.length,
          itemBuilder: (context, index) {
            final item = _suggestions[index];
            final formatted = _formatLocation(item);
            final fullName = item['display_name'] ?? '';

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _selectLocation(item),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: index < _suggestions.length - 1
                        ? Border(
                            bottom: BorderSide(
                              color: widget.isDark
                                  ? const Color(0xFF333333)
                                  : const Color(0xFFE0E0E0),
                              width: 0.5,
                            ),
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: Color(0xFF008080),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatted,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: widget.isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            if (fullName != formatted && fullName.length > formatted.length)
                              Text(
                                fullName,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: widget.isDark ? Colors.white38 : Colors.black38,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: 'Place Born',
          hintStyle: const TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 16,
            color: Color(0xFF666666),
          ),
          suffixIcon: _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF008080)),
                    ),
                  ),
                )
              : null,
        ),
        style: TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 16,
          color: widget.isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
