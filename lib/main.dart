import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'models/stored_request.dart';
import 'widgets/scarab_badge.dart';
import 'widgets/location_autocomplete.dart';
import 'screens/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const YouMeanApp());
}

class YouMeanApp extends StatefulWidget {
  const YouMeanApp({super.key});

  @override
  State<YouMeanApp> createState() => _YouMeanAppState();
}

class _YouMeanAppState extends State<YouMeanApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('dark_mode') ?? true;
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouMean',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF008080), width: 2),
          ),
          hintStyle: const TextStyle(color: Color(0xFF999999)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          bodySmall: TextStyle(color: Colors.black),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000), // Pure black
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1A1A), // Very dark gray for inputs
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF008080), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF333333), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF008080), width: 2),
          ),
          hintStyle: const TextStyle(color: Color(0xFF666666)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFFFFFFF)),
          bodyMedium: TextStyle(color: Color(0xFFFFFFFF)),
          bodySmall: TextStyle(color: Color(0xFFFFFFFF)),
        ),
      ),
      themeMode: _themeMode,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _placeController = TextEditingController();
  double _emotionalState = 50.0; // 0 = Big Sad, 100 = Vibing
  bool _skipTime = false;
  LocationData? _selectedLocationData; // Stores lat/lon from autocomplete
  bool _showMenu = false;
  TimeOfDay? _selectedTime;
  DateTime? _selectedDate;
  bool _isCalculateHovered = false;
  bool _isSkipHovered = false;
  bool _isMoreHovered = false;
  bool _isSupportHovered = false;
  bool _isAboutHovered = false;
  bool _isSettingsHovered = false;
  bool _showIntro = true;
  bool _believeScience = false;
  bool _believeGod = false;
  bool _believeSpirituality = false;
  bool _isLoadingPreferences = true;

  @override
  void initState() {
    super.initState();
    _loadBeliefPreferences();
  }

  Future<void> _loadBeliefPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSetBeliefs = prefs.getBool('has_set_beliefs') ?? false;

    if (hasSetBeliefs) {
      setState(() {
        _believeScience = prefs.getBool('believe_science') ?? false;
        _believeGod = prefs.getBool('believe_god') ?? false;
        _believeSpirituality = prefs.getBool('believe_spirituality') ?? false;
        _showIntro = false;
        _isLoadingPreferences = false;
      });
    } else {
      setState(() {
        _isLoadingPreferences = false;
      });
    }
  }

  Future<void> _saveBeliefPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_set_beliefs', true);
    await prefs.setBool('believe_science', _believeScience);
    await prefs.setBool('believe_god', _believeGod);
    await prefs.setBool('believe_spirituality', _believeSpirituality);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_showIntro) {
      return Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Image.asset(
                      isDark ? 'ardet_assets/umean_dark.png' : 'ardet_assets/umean_logo_light.png',
                      width: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 60),
                  Text(
                    'Sorry this is personal but\ndo you believe in:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      height: 1.6,
                      color: isDark ? Colors.white : Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Science checkbox
                  GestureDetector(
                    onTap: () => setState(() => _believeScience = !_believeScience),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _believeScience
                              ? const Color(0xFF008080)
                              : (isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _believeScience ? const Color(0xFF008080) : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _believeScience ? const Color(0xFF008080) : (isDark ? Colors.white38 : Colors.black),
                                width: 2,
                              ),
                            ),
                            child: _believeScience
                                ? const Icon(Icons.check, size: 16, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Science',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // God or Gods checkbox
                  GestureDetector(
                    onTap: () => setState(() => _believeGod = !_believeGod),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _believeGod
                              ? const Color(0xFF008080)
                              : (isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _believeGod ? const Color(0xFF008080) : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _believeGod ? const Color(0xFF008080) : (isDark ? Colors.white38 : Colors.black),
                                width: 2,
                              ),
                            ),
                            child: _believeGod
                                ? const Icon(Icons.check, size: 16, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'One or More Gods',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Spirituality checkbox
                  GestureDetector(
                    onTap: () => setState(() => _believeSpirituality = !_believeSpirituality),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _believeSpirituality
                              ? const Color(0xFF008080)
                              : (isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _believeSpirituality ? const Color(0xFF008080) : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _believeSpirituality ? const Color(0xFF008080) : (isDark ? Colors.white38 : Colors.black),
                                width: 2,
                              ),
                            ),
                            child: _believeSpirituality
                                ? const Icon(Icons.check, size: 16, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Spirituality',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Continue button
                  SizedBox(
                    height: 56,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: (_believeScience || _believeGod || _believeSpirituality)
                            ? () async {
                                await _saveBeliefPreferences();
                                setState(() => _showIntro = false);
                              }
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: !(_believeScience || _believeGod || _believeSpirituality)
                                ? const Color(0xFF1A1A1A)
                                : null,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: (_believeScience || _believeGod || _believeSpirituality)
                              ? Stack(
                                  children: [
                                    Opacity(
                                      opacity: 0.6,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          image: const DecorationImage(
                                            image: AssetImage('ardet_assets/texture.png'),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'Continue',
                                        style: TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Continue',
                                    style: TextStyle(
                                      color: isDark ? Colors.white38 : Colors.black38,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // App title
                      Center(
                        child: Image.asset(
                          isDark ? 'ardet_assets/umean_dark.png' : 'ardet_assets/umean_logo_light.png',
                          width: 320,
                          fit: BoxFit.contain,
                        ),
                      ),
                  const SizedBox(height: 32),

                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Anon, no data . UX is open source. Like 90\'s freedom without being chained to the internet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        height: 1.6,
                        color: isDark ? Colors.white60 : Colors.black,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Time Born (moved to top)
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _skipTime ? null : () async {
                            final TimeOfDay? time = await showTimePicker(
                              context: context,
                              initialTime: _selectedTime ?? TimeOfDay.now(),
                              builder: (context, child) {
                                return MediaQuery(
                                  data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      timePickerTheme: TimePickerThemeData(
                                        backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF),
                                        dialBackgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                                        hourMinuteColor: MaterialStateColor.resolveWith((states) =>
                                          states.contains(MaterialState.selected) ? const Color(0xFF008080) : (isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5))),
                                        dayPeriodColor: MaterialStateColor.resolveWith((states) =>
                                          states.contains(MaterialState.selected) ? const Color(0xFF008080) : (isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5))),
                                      ),
                                      colorScheme: ColorScheme.fromSeed(
                                        seedColor: const Color(0xFF008080),
                                        brightness: isDark ? Brightness.dark : Brightness.light,
                                      ),
                                    ),
                                    child: child!,
                                  ),
                                );
                              },
                            );
                            if (time != null) {
                              setState(() {
                                _selectedTime = time;
                                // Format as 24-hour time "HH:mm"
                                final hour = time.hour.toString().padLeft(2, '0');
                                final minute = time.minute.toString().padLeft(2, '0');
                                _timeController.text = '$hour:$minute';
                              });
                            }
                          },
                          child: AbsorbPointer(
                            child: TextField(
                              controller: _timeController,
                              enabled: !_skipTime,
                              decoration: InputDecoration(
                                hintText: 'Time Born (24hr format)',
                                hintStyle: const TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 16,
                                ),
                                fillColor: _skipTime
                                    ? (isDark
                                        ? const Color(0xFF0F0F0F)
                                        : const Color(0xFFF0F0F0))
                                    : null,
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _skipTime = !_skipTime;
                            if (_skipTime) {
                              _timeController.clear();
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: _skipTime
                                ? (isDark ? Colors.white24 : Colors.black12)
                                : (isDark ? Colors.white12 : Colors.black.withOpacity(0.05)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _skipTime ? 'Skip Enabled' : 'Skip',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                              if (_skipTime) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '·',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? Colors.white38 : Colors.black26,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Less accurate',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w300,
                                    color: isDark ? Colors.white38 : Colors.black38,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Date Born (moved below Time)
                  GestureDetector(
                    onTap: () async {
                      final now = DateTime.now();
                      final initial = _selectedDate ?? DateTime(2026, 1, 1);

                      int selectedDay = initial.day;
                      int selectedMonth = initial.month;
                      int selectedYear = initial.year;

                      final months = [
                        'January', 'February', 'March', 'April', 'May', 'June',
                        'July', 'August', 'September', 'October', 'November', 'December'
                      ];

                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder: (context, setDialogState) {
                              // Calculate days in selected month/year
                              int daysInMonth = DateTime(selectedYear, selectedMonth + 1, 0).day;
                              if (selectedDay > daysInMonth) {
                                selectedDay = daysInMonth;
                              }

                              return Dialog(
                                backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  height: 400,
                                  child: Column(
                                    children: [
                                      Text(
                                        'Select Birth Date',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.white : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            // Day picker
                                            Expanded(
                                              child: CupertinoPicker(
                                                scrollController: FixedExtentScrollController(
                                                  initialItem: selectedDay - 1,
                                                ),
                                                itemExtent: 40,
                                                onSelectedItemChanged: (int index) {
                                                  setDialogState(() {
                                                    selectedDay = index + 1;
                                                  });
                                                },
                                                children: List<Widget>.generate(
                                                  daysInMonth,
                                                  (int index) => Center(
                                                    child: Text(
                                                      '${index + 1}',
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        color: isDark ? Colors.white : Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Month picker
                                            Expanded(
                                              flex: 2,
                                              child: CupertinoPicker(
                                                scrollController: FixedExtentScrollController(
                                                  initialItem: selectedMonth - 1,
                                                ),
                                                itemExtent: 40,
                                                onSelectedItemChanged: (int index) {
                                                  setDialogState(() {
                                                    selectedMonth = index + 1;
                                                  });
                                                },
                                                children: List<Widget>.generate(
                                                  12,
                                                  (int index) => Center(
                                                    child: Text(
                                                      months[index],
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color: isDark ? Colors.white : Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Year picker
                                            Expanded(
                                              child: CupertinoPicker(
                                                scrollController: FixedExtentScrollController(
                                                  initialItem: now.year - selectedYear,
                                                ),
                                                itemExtent: 40,
                                                onSelectedItemChanged: (int index) {
                                                  setDialogState(() {
                                                    selectedYear = now.year - index;
                                                  });
                                                },
                                                children: List<Widget>.generate(
                                                  now.year - 1900 + 1,
                                                  (int index) => Center(
                                                    child: Text(
                                                      '${now.year - index}',
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        color: isDark ? Colors.white : Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color: isDark ? Colors.white60 : Colors.black54,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              setState(() {
                                                _selectedDate = DateTime(selectedYear, selectedMonth, selectedDay);
                                                _dateController.text = '${selectedDay.toString().padLeft(2, '0')}/${selectedMonth.toString().padLeft(2, '0')}/$selectedYear';
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF008080),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text('Done', style: TextStyle(fontSize: 16)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _dateController,
                        decoration: const InputDecoration(
                          hintText: 'Date Born (D/M/Y)',
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 16,
                          ),
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Place Born with location autocomplete
                  LocationAutocomplete(
                    controller: _placeController,
                    isDark: isDark,
                    onLocationSelected: (locationData) {
                      setState(() {
                        _selectedLocationData = locationData;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Emotional State slider
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Big Sad',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                            Text(
                              'Vibing',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: const Color(0xFF008080),
                          inactiveTrackColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                          thumbColor: const Color(0xFF008080),
                          overlayColor: const Color(0xFF008080).withOpacity(0.2),
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                        ),
                        child: Slider(
                          value: _emotionalState,
                          min: 0,
                          max: 100,
                          onChanged: (value) {
                            setState(() {
                              _emotionalState = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Calculate button (teal/sandy gradient)
                  MouseRegion(
                    onEnter: (_) => setState(() => _isCalculateHovered = true),
                    onExit: (_) => setState(() => _isCalculateHovered = false),
                    child: AnimatedScale(
                      scale: _isCalculateHovered ? 1.02 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF008080).withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                            // Validate inputs
                            if (_selectedDate == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select birth date')),
                              );
                              return;
                            }
                            if (_placeController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter birth place')),
                              );
                              return;
                            }

                            // Format date as YYYY-MM-DD
                            final birthDate = '${_selectedDate!.year.toString().padLeft(4, '0')}-'
                                '${_selectedDate!.month.toString().padLeft(2, '0')}-'
                                '${_selectedDate!.day.toString().padLeft(2, '0')}';

                            // Format time as HH:MM or null if skipped
                            String? birthTime;
                            if (!_skipTime && _selectedTime != null) {
                              birthTime = '${_selectedTime!.hour.toString().padLeft(2, '0')}:'
                                  '${_selectedTime!.minute.toString().padLeft(2, '0')}';
                            }

                            // Submit to local server
                            final requestId = await ApiService.submitRequest(
                              birthCity: _placeController.text,
                              birthDate: birthDate,
                              birthTime: birthTime ?? '',
                              emotionalState: _emotionalState.round().toString(),
                              believeScience: _believeScience,
                              believeGod: _believeGod,
                              believeSpirituality: _believeSpirituality,
                            );

                            if (requestId != null) {
                              // Save to localStorage
                              await StorageService.saveRequest(StoredRequest(
                                requestId: requestId,
                                label: "Request ${_selectedDate!.day}/${_selectedDate!.month}",
                                birthDate: birthDate,
                                birthPlace: _placeController.text,
                                birthTime: birthTime,
                                status: RequestStatus.pending,
                                submittedAt: DateTime.now(),
                                lastCheckedAt: null,
                                hasNotification: false,
                              ));

                              // Navigate to waiting screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WaitingScreen(requestId: requestId),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Error: Could not connect to local server')),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      image: const DecorationImage(
                                        image: AssetImage('ardet_assets/texture.png'),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Calculate',
                                    style: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                  const SizedBox(height: 16),

                  // Menu toggle button
                  Center(
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _isMoreHovered = true),
                      onExit: (_) => setState(() => _isMoreHovered = false),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showMenu = !_showMenu;
                          });
                        },
                        child: AnimatedScale(
                          scale: _isMoreHovered ? 1.1 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Text(
                              _showMenu ? 'Hide' : 'More',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFC9A961),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Navigation menu (hideable)
                  if (_showMenu) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Settings button
                        MouseRegion(
                          onEnter: (_) => setState(() => _isSettingsHovered = true),
                          onExit: (_) => setState(() => _isSettingsHovered = false),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingsPage(),
                                ),
                              );
                            },
                            child: AnimatedScale(
                              scale: _isSettingsHovered ? 1.05 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              child: SizedBox(
                                width: 60,
                                height: 50,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: AnimatedOpacity(
                                        opacity: _isSettingsHovered ? 0.8 : 0.6,
                                        duration: const Duration(milliseconds: 200),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            image: const DecorationImage(
                                              image: AssetImage('ardet_assets/texture_2.png'),
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Center(
                                      child: Icon(
                                        Icons.settings,
                                        color: Color(0xFFFFFFFF),
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Support Creator button
                        MouseRegion(
                          onEnter: (_) => setState(() => _isSupportHovered = true),
                          onExit: (_) => setState(() => _isSupportHovered = false),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SupportTiersPage(),
                                ),
                              );
                            },
                            child: AnimatedScale(
                              scale: _isSupportHovered ? 1.05 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              child: SizedBox(
                                width: 140,
                                height: 50,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: AnimatedOpacity(
                                          opacity: _isSupportHovered ? 0.8 : 0.6,
                                          duration: const Duration(milliseconds: 200),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              image: const DecorationImage(
                                                image: AssetImage('ardet_assets/texture_2.png'),
                                                fit: BoxFit.cover,
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Center(
                                        child: Text(
                                          'Hoard',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300,
                                            color: Color(0xFFFFFFFF),
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // About Project button
                        MouseRegion(
                          onEnter: (_) => setState(() => _isAboutHovered = true),
                          onExit: (_) => setState(() => _isAboutHovered = false),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AboutProjectPage(),
                                ),
                              );
                            },
                            child: AnimatedScale(
                              scale: _isAboutHovered ? 1.05 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              child: SizedBox(
                                width: 140,
                                height: 50,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: AnimatedOpacity(
                                          opacity: _isAboutHovered ? 0.8 : 0.6,
                                          duration: const Duration(milliseconds: 200),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              image: const DecorationImage(
                                                image: AssetImage('ardet_assets/texture_2.png'),
                                                fit: BoxFit.cover,
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Center(
                                        child: Text(
                                          'About Project',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300,
                                            color: Color(0xFFFFFFFF),
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
            ),
            // Scarab notification badge
            const ScarabBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(String label, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: isDark ? Colors.white54 : Colors.black,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class SelfSummaryPage extends StatelessWidget {
  const SelfSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: isDark ? Colors.white54 : Colors.black,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Title
              Text(
                'Self Summary',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 3,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 40),

              // Table
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(2),
                        2: FlexColumnWidth(1.5),
                      },
                      children: [
                        // Header row
                        TableRow(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                          ),
                          children: [
                            _buildTableCell('Year', isDark, isHeader: true),
                            _buildTableCell('Action', isDark, isHeader: true),
                            _buildTableCell('Probability', isDark, isHeader: true),
                          ],
                        ),
                        // Sample data rows
                        ..._buildSampleRows(isDark),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, bool isDark, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? 14 : 13,
          fontWeight: isHeader ? FontWeight.w400 : FontWeight.w300,
          color: isDark
              ? (isHeader ? Colors.white70 : Colors.white60)
              : (isHeader ? Colors.black87 : Colors.black54),
          letterSpacing: isHeader ? 1 : 0.5,
        ),
      ),
    );
  }

  List<TableRow> _buildSampleRows(bool isDark) {
    final sampleData = [
      {'year': '2024', 'action': 'Career advancement', 'probability': '78%'},
      {'year': '2023', 'action': 'Relationship growth', 'probability': '65%'},
      {'year': '2022', 'action': 'Personal development', 'probability': '82%'},
      {'year': '2021', 'action': 'Health improvement', 'probability': '71%'},
      {'year': '2020', 'action': 'Financial stability', 'probability': '59%'},
    ];

    return sampleData.map((row) {
      return TableRow(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
        ),
        children: [
          _buildTableCell(row['year']!, isDark),
          _buildTableCell(row['action']!, isDark),
          _buildTableCell(row['probability']!, isDark),
        ],
      );
    }).toList();
  }
}

class AboutProjectPage extends StatelessWidget {
  const AboutProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: isDark ? Colors.white54 : Colors.black,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Title
              Text(
                'About Project',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 3,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 40),

              // Content
              Text(
                'Unlock sacred logic-driven ancient knowledge lost to time.\n\n'
                'This is knowledge I worked out myself through years of research and analysis. '
                'What was once hidden in mythology and ancient texts, I\'ve decoded using modern science and logical reasoning.\n\n'
                'The more you support, the more you learn—whether through scientific principles or religious logic that actually makes sense.\n\n'
                'Content lockers unlock deeper levels of understanding. Each tier reveals more of the framework that connects ancient wisdom with provable, logical conclusions.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  height: 1.8,
                  color: isDark ? Colors.white70 : Colors.black,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 40),

              // Divider
              Container(
                height: 1,
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
              ),
              const SizedBox(height: 40),

              // How it works
              Text(
                'How It Works',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                '1. Enter your birth data (time, date, place)\n\n'
                '2. The system calculates astronomical positions and patterns\n\n'
                '3. Historical correlations are analyzed (1926-2026 data)\n\n'
                '4. Probability scores reveal insights about your path\n\n'
                '5. Gather shards to unlock ancient tablets of wisdom',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  height: 1.8,
                  color: isDark ? Colors.white60 : Colors.black,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SupportTiersPage extends StatefulWidget {
  const SupportTiersPage({super.key});

  @override
  State<SupportTiersPage> createState() => _SupportTiersPageState();
}

class _SupportTiersPageState extends State<SupportTiersPage> {
  // User state (in production, this would come from a backend/local storage)
  int _currentShards = 0;
  int _currentLevelIndex = 0;
  final Set<int> _unlockedTablets = {};

  // Level definitions
  static const List<Map<String, dynamic>> _levels = [
    {'name': 'Hatched', 'icon': '🥒', 'shardsRequired': 0},
    {'name': 'Wyrm', 'icon': '🐍', 'shardsRequired': 100},
    {'name': 'Drake', 'icon': '🦎', 'shardsRequired': 500},
    {'name': 'Dragon', 'icon': '🐉', 'shardsRequired': 2000},
    {'name': "Tiamat's Chosen", 'icon': '👑', 'shardsRequired': 10000},
  ];

  // Tablet definitions
  static const List<Map<String, dynamic>> _tablets = [
    {
      'title': 'Tablet: Lunar Psychology',
      'preview': 'Discover how lunar cycles influence emotional patterns and decision-making across cultures and millennia.',
      'shardCost': 50,
      'priceCost': 5.0,
    },
    {
      'title': 'Tablet: Solar Archetypes',
      'preview': 'The sun as the source of life - explore how solar positions shape personality and destiny in ancient systems.',
      'shardCost': 75,
      'priceCost': 7.0,
    },
    {
      'title': 'Tablet: Planetary Hours',
      'preview': 'Master the ancient Chaldean system of planetary rulership over hours, days, and moments of power.',
      'shardCost': 100,
      'priceCost': 10.0,
    },
    {
      'title': 'Tablet: The Decan Mysteries',
      'preview': 'Unlock the 36 faces of the zodiac - Egyptian wisdom preserved through Babylonian star-watchers.',
      'shardCost': 150,
      'priceCost': 15.0,
    },
    {
      'title': 'Tablet: Nodes of Fate',
      'preview': 'The dragon\'s head and tail - karmic points that reveal past life patterns and future potential.',
      'shardCost': 200,
      'priceCost': 20.0,
    },
  ];

  int get _shardsToNextLevel {
    if (_currentLevelIndex >= _levels.length - 1) return 0;
    return _levels[_currentLevelIndex + 1]['shardsRequired'] as int;
  }

  double get _progressToNextLevel {
    if (_currentLevelIndex >= _levels.length - 1) return 1.0;
    final currentReq = _levels[_currentLevelIndex]['shardsRequired'] as int;
    final nextReq = _levels[_currentLevelIndex + 1]['shardsRequired'] as int;
    final progress = (_currentShards - currentReq) / (nextReq - currentReq);
    return progress.clamp(0.0, 1.0);
  }

  void _addShards(int amount) {
    setState(() {
      _currentShards += amount;
      // Check for level up
      for (int i = _levels.length - 1; i >= 0; i--) {
        if (_currentShards >= (_levels[i]['shardsRequired'] as int)) {
          _currentLevelIndex = i;
          break;
        }
      }
    });
  }

  void _unlockTablet(int index, {bool withShards = true}) {
    final tablet = _tablets[index];
    if (withShards) {
      if (_currentShards >= (tablet['shardCost'] as int)) {
        setState(() {
          _currentShards -= tablet['shardCost'] as int;
          _unlockedTablets.add(index);
        });
      }
    } else {
      // Payment flow would go here
      setState(() {
        _unlockedTablets.add(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tealAccent = const Color(0xFF00CED1);
    final goldAccent = const Color(0xFFD4AF37);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: isDark ? Colors.white54 : Colors.black54,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  // Shards display
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [goldAccent.withOpacity(0.2), goldAccent.withOpacity(0.1)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: goldAccent.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('💎', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(
                          '$_currentShards Shards',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: goldAccent,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ===== TOP SECTION: LEVELS OF KNOWLEDGE =====
                    const SizedBox(height: 16),
                    Text(
                      'LEVELS OF KNOWLEDGE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 4,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Level progression
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Level icons row
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(_levels.length, (index) {
                                final level = _levels[index];
                                final isCurrentLevel = index == _currentLevelIndex;
                                final isUnlocked = index <= _currentLevelIndex;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Column(
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        width: isCurrentLevel ? 56 : 44,
                                        height: isCurrentLevel ? 56 : 44,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isCurrentLevel
                                              ? tealAccent.withOpacity(0.2)
                                              : isUnlocked
                                                  ? goldAccent.withOpacity(0.1)
                                                  : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                                          border: Border.all(
                                            color: isCurrentLevel
                                                ? tealAccent
                                                : isUnlocked
                                                    ? goldAccent.withOpacity(0.5)
                                                    : Colors.transparent,
                                            width: isCurrentLevel ? 2 : 1,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            level['icon'] as String,
                                            style: TextStyle(
                                              fontSize: isCurrentLevel ? 24 : 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        level['name'] as String,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: isCurrentLevel ? FontWeight.w500 : FontWeight.w300,
                                          color: isCurrentLevel
                                              ? tealAccent
                                              : isUnlocked
                                                  ? (isDark ? Colors.white70 : Colors.black.withOpacity(0.7))
                                                  : (isDark ? Colors.white30 : Colors.black.withOpacity(0.3)),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Current level display
                          Text(
                            'Current Level: ${_levels[_currentLevelIndex]['name']}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: tealAccent,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Progress bar
                          if (_currentLevelIndex < _levels.length - 1) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _progressToNextLevel,
                                backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(tealAccent),
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$_currentShards / $_shardsToNextLevel to ${_levels[_currentLevelIndex + 1]['name']}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                            ),
                          ] else
                            Text(
                              'Maximum level achieved!',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: goldAccent,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // ===== MIDDLE SECTION: TABLETS =====
                    const SizedBox(height: 32),
                    Text(
                      'TABLETS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 4,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tablet list
                    ...List.generate(_tablets.length, (index) {
                      final tablet = _tablets[index];
                      final isUnlocked = _unlockedTablets.contains(index);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isUnlocked
                                  ? tealAccent.withOpacity(0.3)
                                  : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isUnlocked ? Icons.check_circle : Icons.lock_outline,
                                    size: 20,
                                    color: isUnlocked ? tealAccent : (isDark ? Colors.white38 : Colors.black38),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      tablet['title'] as String,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? Colors.white : Colors.black,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                tablet['preview'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                  height: 1.4,
                                ),
                              ),
                              if (!isUnlocked) ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: _currentShards >= (tablet['shardCost'] as int)
                                            ? () => _unlockTablet(index, withShards: true)
                                            : null,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                            color: _currentShards >= (tablet['shardCost'] as int)
                                                ? goldAccent.withOpacity(0.2)
                                                : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: _currentShards >= (tablet['shardCost'] as int)
                                                  ? goldAccent.withOpacity(0.5)
                                                  : Colors.transparent,
                                            ),
                                          ),
                                          child: Text(
                                            '💎 ${tablet['shardCost']} Shards',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: _currentShards >= (tablet['shardCost'] as int)
                                                  ? goldAccent
                                                  : (isDark ? Colors.white38 : Colors.black38),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'OR',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? Colors.white30 : Colors.black.withOpacity(0.3),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _unlockTablet(index, withShards: false),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                            color: tealAccent.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: tealAccent.withOpacity(0.4)),
                                          ),
                                          child: Text(
                                            '\$${(tablet['priceCost'] as double).toStringAsFixed(0)}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: tealAccent,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),

                    // ===== BOTTOM SECTION: GATHER SHARDS =====
                    const SizedBox(height: 24),
                    Text(
                      'GATHER SHARDS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 4,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Shard gathering options
                    Row(
                      children: [
                        // Watch
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _addShards(5),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text('👁️', style: TextStyle(fontSize: 28)),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Watch',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '+5 shards',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: tealAccent,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Quest
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _addShards(25),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text('⚔️', style: TextStyle(fontSize: 28)),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Quest',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '+10-50 shards',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: tealAccent,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Support
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _addShards(100),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    goldAccent.withOpacity(0.15),
                                    goldAccent.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: goldAccent.withOpacity(0.3)),
                              ),
                              child: Column(
                                children: [
                                  Text('💎', style: TextStyle(fontSize: 28)),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Support',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: goldAccent,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Direct',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: goldAccent.withOpacity(0.7),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Waiting Screen - polls for results
class WaitingScreen extends StatefulWidget {
  final String requestId;

  const WaitingScreen({super.key, required this.requestId});

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  bool _isCheckingNow = false;

  void _checkResultsNow() async {
    setState(() {
      _isCheckingNow = true;
    });

    try {
      final result = await ApiService.pollResults(widget.requestId);

      if (!mounted) return;

      if (result != null && result['status'] == 'completed' && result['result'] != null) {
        // Update storage status to "ready"
        await StorageService.updateRequestStatus(
          widget.requestId,
          RequestStatus.ready,
        );

        // Navigate to results page
        final calcResult = CalculationResult.fromJson(result['result']);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsPage(
              result: calcResult,
              requestId: widget.requestId,
            ),
          ),
        );
      } else if (result != null && result['status'] == 'failed') {
        // Update storage status to completed (even if failed)
        await StorageService.updateRequestStatus(
          widget.requestId,
          RequestStatus.completed,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result['error'] ?? 'Unknown error'}')),
        );
      } else {
        // Still pending
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Still processing. Check back in 24-48 hours!'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking results: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingNow = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFF000000),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success checkmark icon
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    children: [
                      Opacity(
                        opacity: 0.6,
                        child: Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('ardet_assets/texture.png'),
                              fit: BoxFit.cover,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const Center(
                        child: Icon(
                          Icons.check_rounded,
                          size: 60,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Simple success message
                Text(
                  'Submitted',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    color: isDark ? Colors.white : Colors.black,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 16),

                // Simple instruction
                Text(
                  'You\'ll be notified when ready',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 60),

                // Back to home button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Done',
                    style: TextStyle(
                      color: const Color(0xFF008080),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Results Page - shows calculation results
class ResultsPage extends StatefulWidget {
  final CalculationResult result;
  final String? requestId;

  const ResultsPage({super.key, required this.result, this.requestId});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  String _selectedMode = 'light'; // 'light', 'psychology', 'astronomy'
  int _yearsToShow = 5; // Default: show last 5 years
  final ScrollController _horizontalScrollController = ScrollController();
  int? _hoveredAge; // For Life Line tooltip
  bool _isLifeLineExpanded = false; // Life Line dropdown state

  /// Calculate intensity score (0-10) from Psychology + Astronomy data
  /// Combines three scoring components for accurate life intensity mapping
  double _calculateIntensity(YearData psychologyData, {YearData? astronomyData}) {
    // Get text from psychology mode
    final psychText = '${psychologyData.row1} ${psychologyData.row2} ${psychologyData.row3} ${psychologyData.row4} ${psychologyData.row5}'.toLowerCase();

    // Get major transits from astronomy mode (row4 is "Major Transits")
    final transitsText = astronomyData?.row4.toLowerCase() ?? '';

    // ========================================
    // COMPONENT 1: Psychology Keywords (0-4 points)
    // ========================================
    int keywordScore = 1; // Default baseline

    // HIGH intensity keywords (+4 points)
    final highIntensityKeywords = [
      'testing', 'questioning', 'negotiation', 'restructuring',
      'reassessing', 'renegotiating', 'threshold', 'crisis',
      'collide', 'collision', 'reevaluation', 'integrity versus despair',
      'regret processing', 'reality testing'
    ];

    // MEDIUM intensity keywords (+2 points)
    final mediumIntensityKeywords = [
      'prototyping', 'crystallizing', 'anchoring', 'demonstration',
      'differentiation', 'transition', 'calibration', 'recalibrating'
    ];

    // LOW intensity keywords (+0 points)
    final lowIntensityKeywords = [
      'consolidation', 'integration', 'acceptance', 'deepening',
      'peace', 'transcending', 'completion', 'foundational',
      'forming', 'awakening', 'developing'
    ];

    // Check for high intensity keywords first
    bool hasHighKeyword = highIntensityKeywords.any((k) => psychText.contains(k));
    bool hasMediumKeyword = mediumIntensityKeywords.any((k) => psychText.contains(k));
    bool hasLowKeyword = lowIntensityKeywords.any((k) => psychText.contains(k));

    if (hasHighKeyword) {
      keywordScore = 4;
    } else if (hasMediumKeyword) {
      keywordScore = 2;
    } else if (hasLowKeyword) {
      keywordScore = 0;
    } else {
      keywordScore = 1; // Everything else
    }

    // ========================================
    // COMPONENT 2: Psychology Status (0-3 points)
    // ========================================
    int statusScore = 1; // Default

    if (psychText.contains('tension')) {
      statusScore = 3;
    } else if (psychText.contains('active')) {
      statusScore = 2;
    } else if (psychText.contains('emerging')) {
      statusScore = 1;
    } else if (psychText.contains('stable') || psychText.contains('background')) {
      statusScore = 0;
    }

    // ========================================
    // COMPONENT 3: Astronomy Transits (0-3 points)
    // ========================================
    int transitScore = 0;

    // Check for major challenging transits (Saturn/Uranus/Pluto square/opposition/conjunction)
    bool hasSaturnSquare = transitsText.contains('saturn square');
    bool hasSaturnOpposition = transitsText.contains('saturn opposition');
    bool hasSaturnConjunction = transitsText.contains('saturn conjunction');
    bool hasUranusSquare = transitsText.contains('uranus square');
    bool hasUranusOpposition = transitsText.contains('uranus opposition');
    bool hasUranusConjunction = transitsText.contains('uranus conjunction');
    bool hasPlutoSquare = transitsText.contains('pluto square');
    bool hasPlutoOpposition = transitsText.contains('pluto opposition');
    bool hasPlutoConjunction = transitsText.contains('pluto conjunction');

    // Jupiter aspects
    bool hasJupiterSquare = transitsText.contains('jupiter square');
    bool hasJupiterOpposition = transitsText.contains('jupiter opposition');
    bool hasJupiterConjunction = transitsText.contains('jupiter conjunction');

    // Sextiles (milder)
    bool hasOuterPlanetSextile = transitsText.contains('sextile');
    bool hasNeptuneConjunction = transitsText.contains('neptune conjunction');

    // Score transits
    if (hasSaturnSquare || hasSaturnOpposition || hasSaturnConjunction ||
        hasUranusSquare || hasUranusOpposition || hasUranusConjunction ||
        hasPlutoSquare || hasPlutoOpposition || hasPlutoConjunction) {
      transitScore = 3;
    } else if (hasJupiterSquare || hasJupiterOpposition) {
      transitScore = 2;
    } else if (hasJupiterConjunction || hasOuterPlanetSextile || hasNeptuneConjunction) {
      transitScore = 1;
    } else {
      transitScore = 0;
    }

    // ========================================
    // TOTAL SCORE (0-10)
    // ========================================
    int totalScore = keywordScore + statusScore + transitScore;

    // Return normalized to 0-1 range for chart
    return (totalScore / 10.0).clamp(0.1, 1.0);
  }

  /// Apply rolling average smoothing to a list of scores
  List<double> _smoothScores(List<double> rawScores, {int windowSize = 3}) {
    if (rawScores.length <= windowSize) return rawScores;

    List<double> smoothed = [];
    int halfWindow = windowSize ~/ 2;

    for (int i = 0; i < rawScores.length; i++) {
      int start = (i - halfWindow).clamp(0, rawScores.length - 1);
      int end = (i + halfWindow + 1).clamp(0, rawScores.length);

      double sum = 0;
      int count = 0;
      for (int j = start; j < end; j++) {
        sum += rawScores[j];
        count++;
      }
      smoothed.add(sum / count);
    }

    return smoothed;
  }

  @override
  void initState() {
    super.initState();
    // Mark as viewed when results are displayed
    if (widget.requestId != null) {
      StorageService.markAsViewed(widget.requestId!);
    }
    // Keep default at 5 years (most recent)
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selfie = widget.result.mindSelfie;
    // Gold: User's story, data identifiers, section headers (vibrant to match logo)
    const goldAccent = Color(0xFFD4A84B);
    // Teal: Interactive elements only (vibrant cyan to match logo)
    const tealAccent = Color(0xFF00CED1);

    if (selfie == null) {
      return _buildFallbackPage(isDark);
    }

    // Get data for the selected mode
    final allYears = selfie.getYearsForMode(_selectedMode);
    final labels = selfie.getRowLabelsForMode(_selectedMode);

    // Filter years based on slider (show last N years)
    final displayYears = allYears.length > _yearsToShow
        ? allYears.sublist(allYears.length - _yearsToShow)
        : allYears;
    final totalYearsAvailable = allYears.length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B1E) : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back_ios,
                            size: 14,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Title: Mind Selfie
            Text(
              'Mind Selfie',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w200,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),

            // Mode Tab Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A2F33) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? tealAccent.withOpacity(0.3) : Colors.black.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    _buildModeTab('LIGHT', 'light', tealAccent, isDark),
                    _buildModeTab('PSYCHOLOGY', 'psychology', tealAccent, isDark),
                    _buildModeTab('ASTRONOMY', 'astronomy', tealAccent, isDark),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Life Line Graph - Collapsible
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Dropdown header
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isLifeLineExpanded = !_isLifeLineExpanded;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0D1B1E) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(_isLifeLineExpanded ? 12 : 12),
                        border: Border.all(
                          color: isDark ? tealAccent.withOpacity(0.2) : Colors.black.withOpacity(0.05),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Life Line',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: goldAccent,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'DEMO ONLY',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w400,
                                  color: isDark ? Colors.white38 : Colors.black38,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            _isLifeLineExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: tealAccent,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Expandable content
                  if (_isLifeLineExpanded)
                    _buildLifeLineGraphContent(selfie, goldAccent, tealAccent, isDark),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Location and Babylonian Date
            if (selfie.location.isNotEmpty || selfie.babylonianDate.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A2F33) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? goldAccent.withOpacity(0.15) : Colors.black.withOpacity(0.05),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selfie.location.isNotEmpty)
                        Row(
                          children: [
                            Text(
                              'Location: ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: goldAccent,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                selfie.location,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (selfie.location.isNotEmpty && selfie.babylonianDate.isNotEmpty)
                        const SizedBox(height: 4),
                      if (selfie.babylonianDate.isNotEmpty)
                        Row(
                          children: [
                            Text(
                              'Babylonian Date: ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: goldAccent,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                selfie.babylonianDate,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Scrollable Data Table
            Expanded(
              child: displayYears.isEmpty
                  ? Center(
                      child: Text(
                        'No data available for ${_selectedMode.toUpperCase()} mode',
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SingleChildScrollView(
                          controller: _horizontalScrollController,
                          scrollDirection: Axis.horizontal,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Age Header Row
                              Container(
                                decoration: BoxDecoration(
                                  color: goldAccent.withOpacity(0.12),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Empty cell for row labels
                                    Container(
                                      width: 110,
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                      child: Text(
                                        '',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? Colors.white70 : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    // Age columns
                                    ...displayYears.map((year) => Container(
                                      width: 120,
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(
                                            color: goldAccent.withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Age ${year.age}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: goldAccent,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                              // Data Rows - dynamically built based on available labels
                              if (labels.isNotEmpty)
                                _buildStyledDataRow(labels[0], displayYears.map((y) => y.row1).toList(), isDark, goldAccent, 0, isLast: labels.length == 1),
                              if (labels.length > 1)
                                _buildStyledDataRow(labels[1], displayYears.map((y) => y.row2).toList(), isDark, goldAccent, 1, isLast: labels.length == 2),
                              if (labels.length > 2)
                                _buildStyledDataRow(labels[2], displayYears.map((y) => y.row3).toList(), isDark, goldAccent, 2, isLast: labels.length == 3),
                              if (labels.length > 3)
                                _buildStyledDataRow(labels[3], displayYears.map((y) => y.row4).toList(), isDark, goldAccent, 3, isLast: labels.length == 4),
                              if (labels.length > 4)
                                _buildStyledDataRow(labels[4], displayYears.map((y) => y.row5).toList(), isDark, goldAccent, 4, isLast: true),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),

            // Slider to control years shown
            if (totalYearsAvailable > 5)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Years displayed',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                        Text(
                          '$_yearsToShow of $totalYearsAvailable',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: goldAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: tealAccent,
                        inactiveTrackColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE0E0E0),
                        thumbColor: tealAccent,
                        overlayColor: tealAccent.withOpacity(0.2),
                        trackHeight: 3,
                      ),
                      child: Slider(
                        value: _yearsToShow.toDouble(),
                        min: 5,
                        max: totalYearsAvailable.toDouble(),
                        divisions: totalYearsAvailable > 5 ? totalYearsAvailable - 5 : 1,
                        onChanged: (value) {
                          setState(() {
                            _yearsToShow = value.toInt();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // Footer hint
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Text(
                '← Scroll horizontally to see all ages →',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w300,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the Life Line graph content (for dropdown)
  /// Uses CustomPaint for full control over coordinate mapping
  Widget _buildLifeLineGraphContent(MindSelfie selfie, Color goldAccent, Color tealAccent, bool isDark) {
    // Get data for tooltips and interactions
    final psychologyYears = selfie.psychologyYears;
    final lightYears = selfie.lightYears;

    // Hardcoded Life Line scores (demo data)
    const List<double> scores = [3, 3, 3, 3, 2, 3, 5, 4, 4, 4, 5, 6, 6, 7, 6, 6, 5, 6, 7, 6, 6, 8, 10, 7];
    final maxAge = scores.length - 1;

    // Get "Right Now" text for tooltip from Light mode
    String getRightNowText(int age) {
      if (age < lightYears.length) {
        return lightYears[age].row1;
      }
      return '';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1B1E) : Colors.grey[100],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: Border.all(
          color: isDark ? goldAccent.withOpacity(0.15) : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Age range indicator
          Text(
            'Ages 0 to $maxAge',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w300,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 12),
          // Custom Canvas Graph
          SizedBox(
              height: 180,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onTapDown: (details) {
                      // Calculate which age was tapped
                      const leftMargin = 10.0;
                      const rightMargin = 10.0;
                      final usableWidth = constraints.maxWidth - leftMargin - rightMargin;
                      final tapX = details.localPosition.dx - leftMargin;
                      final tappedAge = ((tapX / usableWidth) * maxAge).round().clamp(0, maxAge);

                      // Scroll to that age in the table
                      if (tappedAge < psychologyYears.length) {
                        const columnWidth = 120.0;
                        final scrollPosition = tappedAge * columnWidth;
                        _horizontalScrollController.animateTo(
                          scrollPosition,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }

                      // Update hovered age for tooltip
                      setState(() {
                        _hoveredAge = tappedAge;
                      });
                    },
                    onPanUpdate: (details) {
                      const leftMargin = 10.0;
                      const rightMargin = 10.0;
                      final usableWidth = constraints.maxWidth - leftMargin - rightMargin;
                      final tapX = details.localPosition.dx - leftMargin;
                      final hoveredAge = ((tapX / usableWidth) * maxAge).round().clamp(0, maxAge);
                      setState(() {
                        _hoveredAge = hoveredAge;
                      });
                    },
                    onPanEnd: (_) {
                      setState(() {
                        _hoveredAge = null;
                      });
                    },
                    onTapUp: (_) {
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) {
                          setState(() {
                            _hoveredAge = null;
                          });
                        }
                      });
                    },
                    child: Stack(
                      children: [
                        // The graph canvas
                        CustomPaint(
                          size: Size(constraints.maxWidth, 180),
                          painter: _LifeLinePainter(
                            scores: scores,
                            maxAge: maxAge,
                            goldAccent: goldAccent,
                            isDark: isDark,
                            hoveredAge: _hoveredAge,
                          ),
                        ),
                        // Tooltip overlay
                        if (_hoveredAge != null && _hoveredAge! >= 0 && _hoveredAge! <= maxAge)
                          Positioned(
                            left: _calculateTooltipX(constraints.maxWidth, _hoveredAge!, maxAge),
                            top: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1A2F33) : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Age $_hoveredAge',
                                    style: TextStyle(
                                      color: goldAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (getRightNowText(_hoveredAge!).isNotEmpty)
                                    Text(
                                      getRightNowText(_hoveredAge!),
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Colors.black87,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // Disclaimer
          Text(
            'Life Line shows psychological intensity across your life. Tap to see details. Not a health assessment.',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w300,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.white30 : Colors.black26,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTooltipX(double containerWidth, int age, int maxAge) {
    const leftMargin = 10.0;
    const rightMargin = 10.0;
    final usableWidth = containerWidth - leftMargin - rightMargin;
    final x = leftMargin + (age / maxAge) * usableWidth;
    // Keep tooltip within bounds
    return (x - 40).clamp(0.0, containerWidth - 100);
  }

  Widget _buildModeTab(String label, String mode, Color tealAccent, bool isDark) {
    final isSelected = _selectedMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMode = mode;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? tealAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w300,
              letterSpacing: 1,
              color: isSelected
                  ? Colors.black
                  : (isDark ? Colors.white30 : Colors.black38),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyledDataRow(String label, List<String> values, bool isDark, Color labelColor, int rowIndex, {bool isLast = false}) {
    final bgColor = rowIndex.isEven
        ? (isDark ? const Color(0xFF162428) : Colors.white)
        : (isDark ? const Color(0xFF1A2F33) : const Color(0xFFF8FAFA));

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: isLast
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row label - gold for data identifiers
          Container(
            width: 110,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: labelColor,
                letterSpacing: 0.3,
              ),
            ),
          ),
          // Data cells - white for readable content
          ...values.map((value) => Container(
            width: 120,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                  width: 1,
                ),
              ),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w300,
                height: 1.4,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildFallbackPage(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B1E) : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'No Mind Selfie data available',
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for Life Line graph - ECG heart monitor style
class _LifeLinePainter extends CustomPainter {
  final List<double> scores;
  final int maxAge;
  final Color goldAccent;
  final bool isDark;
  final int? hoveredAge;

  _LifeLinePainter({
    required this.scores,
    required this.maxAge,
    required this.goldAccent,
    required this.isDark,
    this.hoveredAge,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) return;

    // Fixed score range
    const double minScore = 2;
    const double maxScore = 10;

    // Fixed graph boundaries
    const double graphTop = 20;
    final double graphBottom = size.height - 40;
    final double availableHeight = graphBottom - graphTop;

    // Margins for X axis
    const double leftPadding = 10.0;
    const double rightPadding = 10.0;
    final double availableWidth = size.width - leftPadding - rightPadding;

    // Calculate pixel points using exact formula
    List<Offset> points = [];
    for (int i = 0; i < scores.length; i++) {
      final double normalised = (scores[i] - minScore) / (maxScore - minScore);
      final double y = graphBottom - (normalised * availableHeight);
      final double x = leftPadding + (i / (scores.length - 1)) * availableWidth;
      points.add(Offset(x, y));
    }

    if (points.length < 2) return;

    // ========== ECG STYLE DRAWING ==========

    // 1. Draw subtle horizontal grid lines (ECG baseline reference)
    final gridPaint = Paint()
      ..color = goldAccent.withOpacity(0.08)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw 3 horizontal grid lines
    for (int i = 1; i <= 3; i++) {
      final gridY = graphTop + (availableHeight * i / 4);
      canvas.drawLine(
        Offset(leftPadding, gridY),
        Offset(size.width - rightPadding, gridY),
        gridPaint,
      );
    }

    // 2. Create STRAIGHT line path (no curves - ECG style)
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    // 3. Create fill path for subtle glow under line
    final fillPath = Path();
    fillPath.moveTo(points.first.dx, graphBottom);
    fillPath.lineTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      fillPath.lineTo(points[i].dx, points[i].dy);
    }
    fillPath.lineTo(points.last.dx, graphBottom);
    fillPath.close();

    // Draw very subtle gradient fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          goldAccent.withOpacity(0.15),
          goldAccent.withOpacity(0.02),
        ],
      ).createShader(Rect.fromLTWH(0, graphTop, size.width, availableHeight));
    canvas.drawPath(fillPath, fillPaint);

    // 4. Draw GLOWING line effect (multiple passes for glow)
    // Outer glow - wide and faint
    final outerGlowPaint = Paint()
      ..color = goldAccent.withOpacity(0.15)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, outerGlowPaint);

    // Middle glow
    final middleGlowPaint = Paint()
      ..color = goldAccent.withOpacity(0.3)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, middleGlowPaint);

    // Inner glow - brighter
    final innerGlowPaint = Paint()
      ..color = goldAccent.withOpacity(0.6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, innerGlowPaint);

    // Core line - BRIGHT and sharp
    final brightGold = Color.lerp(goldAccent, Colors.white, 0.3)!;
    final linePaint = Paint()
      ..color = brightGold
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    // 5. Draw small dots at data points (ECG style - minimal)
    final lastIndex = scores.length - 1;
    final interval = lastIndex <= 10 ? 2 : (lastIndex <= 30 ? 5 : 10);

    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final isLastAge = i == lastIndex;
      final isHovered = hoveredAge == i;

      if (isLastAge) {
        // Current age - larger glowing dot
        // Glow layers
        canvas.drawCircle(point, 10, Paint()..color = goldAccent.withOpacity(0.2));
        canvas.drawCircle(point, 6, Paint()..color = goldAccent.withOpacity(0.4));
        canvas.drawCircle(point, 4, Paint()..color = goldAccent);
        canvas.drawCircle(point, 2, Paint()..color = brightGold);
      } else if (isHovered) {
        // Hovered point - medium glow
        canvas.drawCircle(point, 6, Paint()..color = goldAccent.withOpacity(0.3));
        canvas.drawCircle(point, 3, Paint()..color = goldAccent);
        canvas.drawCircle(point, 1.5, Paint()..color = brightGold);
      } else if (i % interval == 0) {
        // Interval marks - tiny dots
        canvas.drawCircle(point, 2, Paint()..color = goldAccent.withOpacity(0.6));
      }
    }

    // 6. Draw X-axis labels
    final textStyle = TextStyle(
      fontSize: 9,
      fontWeight: FontWeight.w300,
      color: isDark ? Colors.white30 : Colors.black.withOpacity(0.3),
    );
    final lastAgeTextStyle = TextStyle(
      fontSize: 9,
      fontWeight: FontWeight.w600,
      color: goldAccent,
    );

    for (int i = 0; i < scores.length; i++) {
      final isLastAge = i == lastIndex;
      final isIntervalMark = i % interval == 0;

      if (i == 0 || isIntervalMark || isLastAge) {
        final x = leftPadding + (i / lastIndex) * availableWidth;
        final textSpan = TextSpan(
          text: i.toString(),
          style: isLastAge ? lastAgeTextStyle : textStyle,
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, size.height - 18),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LifeLinePainter oldDelegate) {
    return oldDelegate.scores != scores ||
        oldDelegate.hoveredAge != hoveredAge ||
        oldDelegate.isDark != isDark;
  }
}
