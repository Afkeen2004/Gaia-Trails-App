    import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Palette {
  static const background  = Color(0xFFF8FBFA);
  static const textPrimary = Color(0xFF0E1A13);
  static const buttonGreen = Color(0xFF019863);
}

class EditSettingsPage extends StatefulWidget {
  const EditSettingsPage({super.key});
  @override
  State<EditSettingsPage> createState() => _EditSettingsPageState();
}

class _EditSettingsPageState extends State<EditSettingsPage> {
  String language        = 'English';
  bool   isDarkTheme     = false;
  bool   notificationsOn = true;
  bool   _loading        = true;

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final savedLang = prefs.getString('language');
    if (savedLang == 'English') {
      language = 'English';
    } else {
      language = 'English';
      await prefs.setString('language', 'English');
    }

    isDarkTheme     = prefs.getBool('isDarkTheme')     ?? false;
    notificationsOn = prefs.getBool('notificationsOn') ?? true;

    setState(() => _loading = false);
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', 'English');
    await prefs.setBool('isDarkTheme', isDarkTheme);
    await prefs.setBool('notificationsOn', notificationsOn);
  }

  SwitchThemeData get _greenSwitchTheme => SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected)
          ? _Palette.buttonGreen
          : _Palette.textPrimary.withOpacity(.4),
    ),
    trackColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.selected)
          ? _Palette.buttonGreen.withOpacity(.35)
          : _Palette.textPrimary.withOpacity(.2),
    ),
  );

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: _Palette.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final title22 = GoogleFonts.splineSans(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: _Palette.textPrimary,
      letterSpacing: -0.015,
    );
    final header18   = title22.copyWith(fontSize: 18);
    final labelGreen = GoogleFonts.notoSans(
      fontSize: 16,
      color: _Palette.buttonGreen,
      fontWeight: FontWeight.w500,
    );

    return Scaffold(
      backgroundColor: _Palette.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: _Palette.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text('Edit Settings', style: header18),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 12),
                      child: Text(
                        'Preferences',
                        style: title22.copyWith(color: _Palette.buttonGreen),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DropdownButtonFormField<String>(
                        value: 'English',
                        decoration: InputDecoration(
                          labelText: 'Language',
                          labelStyle: labelGreen,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'English',
                            child: Text('English'),
                          ),
                        ],
                        onChanged: (_) {},
                      ),
                    ),
                    Theme(
                      data: Theme.of(context).copyWith(
                        switchTheme: _greenSwitchTheme,
                      ),
                      child: SwitchListTile(
                        key: const ValueKey('notifToggle'),
                        contentPadding: EdgeInsets.zero,
                        title: Text('Notifications', style: labelGreen),
                        value: notificationsOn,
                        onChanged: (v) =>
                            setState(() => notificationsOn = v),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _Palette.buttonGreen,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          await _savePrefs();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Settings saved!')),
                            );
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          'Save',
                          style: GoogleFonts.splineSans(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
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
