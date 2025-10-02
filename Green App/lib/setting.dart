import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'user_profile.dart';
import 'edit_settings.dart';

class _Palette {
  static const background  = Color(0xFFF8FBFA);
  static const textPrimary = Color(0xFF0E1A13);
  static const buttonGreen = Color(0xFF019863);
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Future<Map<String, dynamic>> _prefsFuture;

  @override
  void initState() {
    super.initState();
    _prefsFuture = _loadPrefs();
  }

  Future<Map<String, dynamic>> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'language'       : 'English',                                // fixed
      // 'isDarkTheme' removed from display but still loaded if you want to keep
      'notificationsOn': prefs.getBool('notificationsOn') ?? true,
    };
  }

  Future<void> _openEditor() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EditSettingsPage()),
    );
    if (mounted) setState(() => _prefsFuture = _loadPrefs());
  }

  @override
  Widget build(BuildContext context) {
    final h22      = GoogleFonts.splineSans(
      fontSize: 22, fontWeight: FontWeight.bold,
      color: _Palette.textPrimary, letterSpacing: -0.015,
    );
    final h22Green = h22.copyWith(color: _Palette.buttonGreen);
    final h18      = h22.copyWith(fontSize: 18);
    final body16   = GoogleFonts.notoSans(
      fontSize: 16, color: _Palette.textPrimary,
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
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const UserProfilePage()),
                      );
                    },
                  ),
                  const Spacer(),
                  Text('Settings', style: h18),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit, color: _Palette.textPrimary),
                    tooltip: 'Edit Settings',
                    onPressed: _openEditor,
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _prefsFuture,
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final p = snap.data!;
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                          const EdgeInsets.fromLTRB(16, 20, 16, 12),
                          child: Text('Preferences', style: h22Green),
                        ),
                        _SettingRow(
                          label: 'Language',
                          value: p['language'],
                          style: body16,
                        ),
                        // Theme option removed here completely
                        _SettingRow(
                          label: 'Notifications',
                          value: p['notificationsOn'] ? 'Enabled' : 'Disabled',
                          style: body16,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 28),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.logout),
                              label: const Text('Sign Out'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _Palette.buttonGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: GoogleFonts.splineSans(
                                  fontSize: 16, fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                await GoogleSignIn().signOut();
                                if (mounted) {
                                  Navigator.of(context)
                                      .pushReplacementNamed('/');
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.label,
    required this.value,
    required this.style,
  });

  final String label;
  final String value;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => Container(
    color: _Palette.background,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        Expanded(
          child: Text(label,
              style: style.copyWith(overflow: TextOverflow.ellipsis)),
        ),
        Text(value, style: style),
      ],
    ),
  );
}
