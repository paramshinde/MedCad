import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_constants.dart';

/// First-launch role chooser screen.
///
/// Stores the role in SharedPreferences and redirects to role-specific dashboard.
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  bool _isSaving = false;

  Future<void> _selectRole(String role) async {
    setState(() => _isSaving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userRoleKey, role);

      if (!mounted) return;
      final route = role == AppConstants.roleDoctor
          ? '/doctorDashboard'
          : '/patientDashboard';
      Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MedCad')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Are you a Doctor or a Patient?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : () => _selectRole(AppConstants.roleDoctor),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Text('????? I am a Doctor',
                          style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : () => _selectRole(AppConstants.rolePatient),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Text('?? I am a Patient',
                          style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ),
                if (_isSaving) ...[
                  const SizedBox(height: 18),
                  const CircularProgressIndicator(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
