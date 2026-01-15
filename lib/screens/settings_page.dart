import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _believeScience = false;
  bool _believeGod = false;
  bool _believeSpirituality = false;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _believeScience = prefs.getBool('believe_science') ?? false;
      _believeGod = prefs.getBool('believe_god') ?? false;
      _believeSpirituality = prefs.getBool('believe_spirituality') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _savePreferences() async {
    setState(() => _isSaving = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('believe_science', _believeScience);
    await prefs.setBool('believe_god', _believeGod);
    await prefs.setBool('believe_spirituality', _believeSpirituality);

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Belief preferences saved'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFF000000),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings'),
        backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFF000000),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    Text(
                      'Belief System',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select what resonates with you',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: isDark ? const Color(0xFFC9A961) : const Color(0xFF705C45),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Science checkbox
                    GestureDetector(
                      onTap: () => setState(() => _believeScience = !_believeScience),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _believeScience
                                ? const Color(0xFF008080)
                                : (isDark ? Colors.white12 : Colors.black12),
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
                                  color: _believeScience ? const Color(0xFF008080) : (isDark ? Colors.white38 : Colors.black38),
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

                    // God checkbox
                    GestureDetector(
                      onTap: () => setState(() => _believeGod = !_believeGod),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _believeGod
                                ? const Color(0xFF008080)
                                : (isDark ? Colors.white12 : Colors.black12),
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
                                  color: _believeGod ? const Color(0xFF008080) : (isDark ? Colors.white38 : Colors.black38),
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
                          color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _believeSpirituality
                                ? const Color(0xFF008080)
                                : (isDark ? Colors.white12 : Colors.black12),
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
                                  color: _believeSpirituality ? const Color(0xFF008080) : (isDark ? Colors.white38 : Colors.black38),
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
                    const Spacer(),

                    // Save button
                    SizedBox(
                      height: 56,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: (_believeScience || _believeGod || _believeSpirituality) && !_isSaving
                              ? _savePreferences
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
                                        child: _isSaving
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFFFFF)),
                                                ),
                                              )
                                            : const Text(
                                                'Save',
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
                                      'Save',
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
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
