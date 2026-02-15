import 'package:flutter/material.dart';

import '../widgets/custom_button.dart';

class PatientDashboard extends StatelessWidget {
  const PatientDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      onPressed: () =>
                          Navigator.pushNamed(context, '/patient-scan'),
                      icon: Icons.qr_code_scanner_rounded,
                      child: const Text('Scan Prescription'),
                    ),
                    const SizedBox(height: 10),
                    CustomButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/patient-create'),
                      icon: Icons.person_add_alt_1_rounded,
                      child: const Text('Create Patient'),
                    ),
                    const SizedBox(height: 10),
                    CustomButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/patient-search'),
                      icon: Icons.search_rounded,
                      child: const Text('Search Patients'),
                    ),
                    const SizedBox(height: 10),
                    CustomButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('History view coming soon.')),
                        );
                      },
                      icon: Icons.history_rounded,
                      child: const Text('View History'),
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
