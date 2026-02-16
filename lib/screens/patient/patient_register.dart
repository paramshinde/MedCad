import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth_service.dart';
import '../../utils/app_constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Patient registration screen creating auth account + baseline profile.
class PatientRegisterScreen extends StatefulWidget {
  const PatientRegisterScreen({super.key});

  @override
  State<PatientRegisterScreen> createState() => _PatientRegisterScreenState();
}

class _PatientRegisterScreenState extends State<PatientRegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    if (name.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill all fields.')),
      );
      return;
    }

    if (pass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService().registerPatient(
        name: name,
        email: email,
        password: pass,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userRoleKey, AppConstants.rolePatient);

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
          context, '/patientDashboard', (_) => false);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message = switch (e.code) {
        'email-already-in-use' => 'This email is already registered.',
        'invalid-email' => 'Invalid email format.',
        'weak-password' => 'Password must be stronger.',
        _ => e.message ?? 'Patient registration failed.',
      };
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unexpected error during registration.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            CustomTextField(controller: _nameCtrl, label: 'Name'),
            CustomTextField(
              controller: _emailCtrl,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            CustomTextField(
              controller: _passCtrl,
              label: 'Password',
              obscureText: true,
            ),
            CustomTextField(
              controller: _confirmCtrl,
              label: 'Confirm Password',
              obscureText: true,
            ),
            const SizedBox(height: 8),
            CustomButton(
              onPressed: _register,
              isLoading: _isLoading,
              icon: Icons.person_add_alt_1_rounded,
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
