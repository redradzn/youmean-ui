import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'models/stored_request.dart';
import 'widgets/scarab_badge.dart';
import 'screens/my_requests_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const YouMeanApp());
}

class YouMeanApp extends StatelessWidget {
  const YouMeanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouMean',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black12, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1C1C1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white12, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
      ),
      themeMode: ThemeMode.system,
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
  final _emotionalController = TextEditingController();
  bool _skipTime = false;
  bool _showMenu = false;
  TimeOfDay? _selectedTime;
  DateTime? _selectedDate;
  bool _isCalculateHovered = false;
  bool _isSkipHovered = false;
  bool _isMoreHovered = false;
  bool _isSupportHovered = false;
  bool _isAboutHovered = false;
  bool _isMyRequestsHovered = false;
  bool _showIntro = true;
  bool _believeScience = false;
  bool _believeGod = false;
  bool _believeSpirituality = false;

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _placeController.dispose();
    _emotionalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_showIntro) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'YouMean',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w200,
                      letterSpacing: 4,
                      color: isDark ? Colors.white : Colors.black,
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
                      color: isDark ? Colors.white70 : Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Science checkbox
                  GestureDetector(
                    onTap: () => setState(() => _believeScience = !_believeScience),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark ? Colors.white38 : Colors.black38,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            color: _believeScience
                                ? const Color(0xFF008080)
                                : Colors.transparent,
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
                            fontWeight: FontWeight.w300,
                            color: isDark ? Colors.white : Colors.black,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // God or Gods checkbox
                  GestureDetector(
                    onTap: () => setState(() => _believeGod = !_believeGod),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark ? Colors.white38 : Colors.black38,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            color: _believeGod
                                ? const Color(0xFF800080)
                                : Colors.transparent,
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
                            fontWeight: FontWeight.w300,
                            color: isDark ? Colors.white : Colors.black,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Spirituality checkbox
                  GestureDetector(
                    onTap: () => setState(() => _believeSpirituality = !_believeSpirituality),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark ? Colors.white38 : Colors.black38,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            color: _believeSpirituality
                                ? const Color(0xFF9370DB)
                                : Colors.transparent,
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
                            fontWeight: FontWeight.w300,
                            color: isDark ? Colors.white : Colors.black,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Continue button
                  SizedBox(
                    height: 56,
                    child: TextButton(
                      onPressed: (_believeScience || _believeGod || _believeSpirituality)
                          ? () => setState(() => _showIntro = false)
                          : null,
                      style: TextButton.styleFrom(
                        backgroundColor: (_believeScience || _believeGod || _believeSpirituality)
                            ? const Color(0xFFC7C7C7)
                            : const Color(0xFFE0E0E0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          color: (_believeScience || _believeGod || _believeSpirituality)
                              ? Colors.black
                              : Colors.black38,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 2,
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
                      Text(
                        'YouMean',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w200,
                      letterSpacing: 4,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'anonymous. no ads. no data collection.\n'
                      'no dodgy terms and conditions.\n\n'
                      'its like the 90s again.\n\n'
                      'UX is open source. backend is decentralized.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        height: 1.6,
                        color: isDark ? Colors.white60 : Colors.black54,
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
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    timePickerTheme: TimePickerThemeData(
                                      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                                      dialBackgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF5F5F5),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (time != null) {
                              setState(() {
                                _selectedTime = time;
                                _timeController.text = time.format(context);
                              });
                            }
                          },
                          child: AbsorbPointer(
                            child: TextField(
                              controller: _timeController,
                              enabled: !_skipTime,
                              decoration: InputDecoration(
                                hintText: 'Time Born (AM / PM)',
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
                      final DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              datePickerTheme: DatePickerThemeData(
                                backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                                headerBackgroundColor: const Color(0xFF008080),
                                headerForegroundColor: Colors.white,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate = date;
                          _dateController.text = '${date.day}/${date.month}/${date.year}';
                        });
                      }
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

                  // Place Born
                  TextField(
                    controller: _placeController,
                    decoration: const InputDecoration(
                      hintText: 'Place Born',
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
                  const SizedBox(height: 20),

                  // Emotional State input
                  TextField(
                    controller: _emotionalController,
                    decoration: const InputDecoration(
                      hintText: 'How are you feeling? (e.g., calm, anxious, energized)',
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 16,
                      ),
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 60),

                  // Calculate button (light gray with black text)
                  MouseRegion(
                    onEnter: (_) => setState(() => _isCalculateHovered = true),
                    onExit: (_) => setState(() => _isCalculateHovered = false),
                    child: AnimatedScale(
                      scale: _isCalculateHovered ? 1.02 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: SizedBox(
                        height: 56,
                        child: TextButton(
                          onPressed: () async {
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
                            if (_emotionalController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please describe how you feel')),
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
                              emotionalState: _emotionalController.text,
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
                          style: TextButton.styleFrom(
                            backgroundColor: _isCalculateHovered
                                ? const Color(0xFFD7D7D7)
                                : const Color(0xFFC7C7C7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Calculate',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 2,
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
                            child: ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Color(0xFF00FFFF), // Bright Cyan
                                  Color(0xFFFF00FF), // Bright Magenta
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ).createShader(bounds),
                              child: Text(
                                _showMenu ? 'Hide' : 'More',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
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
                        // My Requests button
                        MouseRegion(
                          onEnter: (_) => setState(() => _isMyRequestsHovered = true),
                          onExit: (_) => setState(() => _isMyRequestsHovered = false),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyRequestsPage(),
                                ),
                              );
                            },
                            child: AnimatedScale(
                              scale: _isMyRequestsHovered ? 1.05 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _isMyRequestsHovered
                                        ? const [
                                            Color(0xFF00A0A0), // Brighter Teal
                                            Color(0xFF10B0B0), // Brighter Cyan
                                          ]
                                        : const [
                                            Color(0xFF008080), // Teal
                                            Color(0xFF20B2AA), // Light Sea Green
                                          ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'My Requests',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
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
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _isSupportHovered
                                        ? const [
                                            Color(0xFF00A0A0), // Brighter Teal
                                            Color(0xFFA000A0), // Brighter Purple
                                          ]
                                        : const [
                                            Color(0xFF008080), // Teal
                                            Color(0xFF800080), // Purple
                                          ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Support Creator',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
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
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _isAboutHovered
                                        ? const [
                                            Color(0xFF005050), // Slightly brighter Dark Teal
                                            Color(0xFF500050), // Slightly brighter Dark Purple
                                          ]
                                        : const [
                                            Color(0xFF004040), // Dark Teal (50% darker)
                                            Color(0xFF400040), // Dark Purple (50% darker)
                                          ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'About Project',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                    letterSpacing: 1,
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
            color: isDark ? Colors.white54 : Colors.black54,
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
                        color: isDark ? Colors.white54 : Colors.black54,
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
                        color: isDark ? Colors.white54 : Colors.black54,
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
                  color: isDark ? Colors.white70 : Colors.black87,
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
                '5. Support to unlock deeper knowledge tiers',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  height: 1.8,
                  color: isDark ? Colors.white60 : Colors.black54,
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

class SupportTiersPage extends StatelessWidget {
  const SupportTiersPage({super.key});

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
                        color: isDark ? Colors.white54 : Colors.black54,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Title
              Text(
                'Support Tiers',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 3,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 24),

              // Message
              Text(
                'YouMean is currently developed and maintained by one person, Ardet. Your support helps make this vision real.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: isDark ? Colors.white60 : Colors.black54,
                  height: 1.6,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 40),

              // Support tiers
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTierCard('Tier 1', 'Basic Support', isDark),
                      const SizedBox(height: 16),
                      _buildTierCard('Tier 2', 'Bronze Support', isDark),
                      const SizedBox(height: 16),
                      _buildTierCard('Tier 3', 'Silver Support', isDark),
                      const SizedBox(height: 16),
                      _buildTierCard('Tier 4', 'Gold Support', isDark),
                      const SizedBox(height: 16),
                      _buildTierCard('Tier 5', 'Platinum Support', isDark),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTierCard(String tier, String name, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tier,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: isDark ? Colors.white : Colors.black,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  color: isDark ? Colors.white54 : Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ],
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF008080).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: Color(0xFF008080),
                  ),
                ),
                const SizedBox(height: 32),

                // Success message
                Text(
                  'Request Submitted Successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 24),

                // Instructions
                Text(
                  'Your request is being processed offline for maximum security and privacy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    height: 1.6,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 32),

                // Request ID box
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Your Request ID',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SelectableText(
                        widget.requestId,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'monospace',
                          color: const Color(0xFF008080),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Save this ID to check your results later',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w300,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Timeline info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF008080).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF008080).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 16,
                            color: Color(0xFF008080),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Results typically ready in 24-48 hours',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bookmark this page or save your Request ID',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Check Results Now button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: TextButton(
                    onPressed: _isCheckingNow ? null : _checkResultsNow,
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF008080),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isCheckingNow
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Check Results Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Back to home button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Back to Home',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 14,
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
  int _yearsToShow = 5; // Default: show last 5 years

  @override
  void initState() {
    super.initState();
    // Mark as viewed when results are displayed
    if (widget.requestId != null) {
      StorageService.markAsViewed(widget.requestId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selfie = widget.result.mindSelfie;

    if (selfie == null) {
      return _buildFallbackPage(isDark);
    }

    // Get years to display based on slider
    final displayYears = selfie.years.length > _yearsToShow
        ? selfie.years.sublist(selfie.years.length - _yearsToShow)
        : selfie.years;

    final labels = selfie.rowLabels;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 20,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'Mind Selfie',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w200,
                      color: isDark ? Colors.white : Colors.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${selfie.beliefSystem.toUpperCase()} PERSPECTIVE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.5,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Scrollable table
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF9F9F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: DataTable(
                        headingRowHeight: 48,
                        dataRowHeight: 64,
                        horizontalMargin: 16,
                        columnSpacing: 40,
                        dividerThickness: 0,
                        columns: [
                          DataColumn(
                            label: SizedBox(
                              width: 120,
                              child: Text(
                                '',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: isDark ? Colors.white38 : Colors.black38,
                                ),
                              ),
                            ),
                          ),
                          ...displayYears.map((year) {
                            return DataColumn(
                              label: Container(
                                width: 100,
                                alignment: Alignment.center,
                                child: Text(
                                  'Age ${year.age}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.5,
                                    color: isDark ? Colors.white60 : Colors.black54,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                        rows: [
                          _buildDataRow(labels[0], displayYears.map((y) => y.row1).toList(), isDark),
                          _buildDataRow(labels[1], displayYears.map((y) => y.row2).toList(), isDark),
                          _buildDataRow(labels[2], displayYears.map((y) => y.row3).toList(), isDark),
                          _buildDataRow(labels[3], displayYears.map((y) => y.row4).toList(), isDark),
                          _buildDataRow(labels[4], displayYears.map((y) => y.row5).toList(), isDark),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Slider to control years shown
            Padding(
              padding: const EdgeInsets.all(24),
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
                        '$_yearsToShow of ${selfie.totalYearsAvailable}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: const Color(0xFF008080),
                      inactiveTrackColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE0E0E0),
                      thumbColor: const Color(0xFF008080),
                      overlayColor: const Color(0xFF008080).withOpacity(0.2),
                      trackHeight: 2,
                    ),
                    child: Slider(
                      value: _yearsToShow.toDouble(),
                      min: 5,
                      max: selfie.totalYearsAvailable.toDouble(),
                      divisions: selfie.totalYearsAvailable - 4,
                      onChanged: (value) {
                        setState(() {
                          _yearsToShow = value.toInt();
                        });
                      },
                    ),
                  ),
                  Text(
                    'Scroll right to see all years →',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w300,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(String label, List<String> values, bool isDark) {
    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        ...values.map((value) {
          return DataCell(
            Container(
              width: 100,
              alignment: Alignment.center,
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFallbackPage(bool isDark) {
    return Scaffold(
      body: Center(
        child: Text(
          'No Mind Selfie data available',
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
      ),
    );
  }
}
