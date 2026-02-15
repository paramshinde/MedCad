import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/stat_card.dart';

class DoctorDashboard extends StatelessWidget {
  const DoctorDashboard({super.key});

  Future<int> _prescriptionCount(String uid) async {
    final aggregate = await FirebaseFirestore.instance
        .collection('prescriptions')
        .where('doctorId', isEqualTo: uid)
        .count()
        .get();
    return aggregate.count ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (_) => false);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: uid == null
            ? const Center(child: Text('No active session'))
            : FutureBuilder<int>(
                future: _prescriptionCount(uid),
                builder: (context, snapshot) {
                  final prescriptionCount = snapshot.data ?? 0;
                  return ListView(
                    children: [
                      const Text(
                        'Welcome, Doctor',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              label: 'Patients',
                              value: (prescriptionCount ~/ 2 + 1).toString(),
                              icon: Icons.groups_rounded,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              label: 'Prescriptions',
                              value: prescriptionCount.toString(),
                              icon: Icons.receipt_long_rounded,
                              color: const Color(0xFF0891B2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Quick Actions',
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 12),
                              CustomButton(
                                onPressed: () => Navigator.pushNamed(
                                    context, '/doctor-create'),
                                icon: Icons.add_box_rounded,
                                child: const Text('Create Prescription'),
                              ),
                              const SizedBox(height: 10),
                              CustomButton(
                                onPressed: () => Navigator.pushNamed(
                                    context, '/doctor-med-search'),
                                icon: Icons.search_rounded,
                                child: const Text('Search Medicines'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
