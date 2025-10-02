// lib/login_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'user_profile.dart';   // 👈 destination screen
import 'signup_page.dart';    // for the “Need an account?” link

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final username = _usernameCtrl.text.trim().toLowerCase();
    final password = _passwordCtrl.text.trim();

    try {
      // 1️⃣ Find email from username_lookup
      final snap = await FirebaseFirestore.instance
          .collection('username_lookup')
          .doc(username)
          .get();

      if (!snap.exists) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Unknown username')));
        setState(() => _loading = false);
        return;
      }
      final email = snap['email'] as String;

      // 2️⃣ Firebase Auth email + password sign‑in
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // 3️⃣ Navigate to profile
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserProfilePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      final msg = e.code == 'wrong-password'
          ? 'Incorrect password'
          : e.message ?? 'Authentication error';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign In')),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            _field(_usernameCtrl, 'Username',
                    (v) =>
                v == null || v.trim().isEmpty ? 'Enter username' : null),
            _field(
              _passwordCtrl,
              'Password',
                  (v) => v != null && v.length >= 6
                  ? null
                  : 'Password must be ≥ 6 chars',
              obscure: true,
            ),
            const SizedBox(height: 32),
            _button('Sign In', _signIn),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: _loading
                    ? null
                    : () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SignUpPage()),
                ),
                child: const Text('Need an account? Sign up'),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  // ───────── helper widgets ─────────
  Widget _field(TextEditingController c, String label,
      String? Function(String?) validator,
      {bool obscure = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: c,
          decoration: InputDecoration(labelText: label),
          validator: validator,
          obscureText: obscure,
        ),
      );

  Widget _button(String label, VoidCallback onTap) => ElevatedButton(
    onPressed: _loading ? null : onTap,
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF019863),
      minimumSize: const Size(160, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    child: Text(_loading ? 'Please wait…' : label,
        style: const TextStyle(color: Colors.white)),
  );
}
