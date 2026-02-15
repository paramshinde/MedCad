import 'package:flutter/material.dart';

import '../../widgets/custom_button.dart';

/// Patient dashboard with quick access to core patient workflows.
class PatientDashboardScreen extends StatelessWidget {
  const PatientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Welcome, Patient',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CustomButton(
                      onPressed: () => Navigator.pushNamed(context, '/scanQR'),
                      icon: Icons.qr_code_scanner_rounded,
                      child: const Text('Scan Prescription QR'),
                    ),
                    const SizedBox(height: 10),
                    CustomButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/savedMedicines'),
                      icon: Icons.medication_rounded,
                      child: const Text('Saved Medicines'),
                    ),
                    const SizedBox(height: 10),
                    CustomButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/patient-history'),
                      icon: Icons.timeline_rounded,
                      child: const Text('Prescription History Timeline'),
                    ),
                    const SizedBox(height: 10),
                    CustomButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/emergencyCard'),
                      icon: Icons.emergency_rounded,
                      child: const Text('Emergency Profile Card'),
                    ),
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
