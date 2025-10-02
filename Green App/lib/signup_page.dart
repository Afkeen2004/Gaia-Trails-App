// signup_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'user_profile.dart';       // ⬅️ Changed from TreeSelectionPage
import 'login_page.dart';         // Login screen

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loading = false;

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final name     = _nameCtrl.text.trim();
    final email    = _emailCtrl.text.trim();
    final username = _usernameCtrl.text.trim();
    final phone    = _phoneCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'name': name,
        'email': email,
        'username': username,
        'phone': phone,
        'created_at': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('username_lookup')
          .doc(username.toLowerCase())
          .set({'email': email});

      _nameCtrl.clear();
      _emailCtrl.clear();
      _usernameCtrl.clear();
      _phoneCtrl.clear();
      _passwordCtrl.clear();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserProfilePage()), // ⬅️ Changed
        );
      }
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'email-already-in-use' => 'That email is already registered.',
        'weak-password'        => 'Password is too weak.',
        _                      => e.message ?? 'Authentication failed.',
      };
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
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _textField(_nameCtrl, 'Name',
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter your name' : null),
              _textField(_emailCtrl, 'Email',
                  keyboard: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter email';
                    final regex = RegExp(r'^[\w-\.]+@.+\..+\$');
                    return regex.hasMatch(v) ? null : 'Invalid email format';
                  }),
              _textField(_usernameCtrl, 'Username',
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Choose a username' : null),
              _textField(_phoneCtrl, 'Phone Number',
                  keyboard: TextInputType.phone,
                  validator: (v) => RegExp(r'^\d{7,15}\$').hasMatch(v ?? '')
                      ? null
                      : 'Enter 7–15 digit phone'),
              _passwordField(),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _loading ? null : _createAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF019863),
                  minimumSize: const Size(160, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  _loading ? 'Please wait…' : 'Create Account',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _loading
                      ? null
                      : () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginPage()),
                    );
                  },
                  child: const Text('Already have an account? Sign in'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────── Helper widgets ─────────────

  Widget _textField(
      TextEditingController controller,
      String label, {
        String? Function(String?)? validator,
        TextInputType keyboard = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: keyboard,
        validator: validator,
      ),
    );
  }

  Widget _passwordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _passwordCtrl,
        decoration: const InputDecoration(labelText: 'Password'),
        obscureText: true,
        validator: (v) => v != null && v.length >= 6
            ? null
            : 'Password must be at least 6 characters',
      ),
    );
  }
}
