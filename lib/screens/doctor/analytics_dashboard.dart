import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Doctor analytics screen showing high-level metrics.
class AnalyticsDashboardScreen extends StatelessWidget {
  const AnalyticsDashboardScreen({super.key});

  Future<Map<String, dynamic>> _loadAnalytics() async {
    final db = FirebaseFirestore.instance;

    final patientCountAgg = await db.collection('patients').count().get();
    final prescriptionCountAgg =
        await db.collection('prescriptions').count().get();

    final prescriptions = await db.collection('prescriptions').get();
    final Map<String, int> medicineCounts = {};

    for (final doc in prescriptions.docs) {
      final meds = (doc.data()['medicines'] as List<dynamic>? ?? []);
      for (final med in meds) {
        final name = (med as Map<String, dynamic>)['name'] as String? ?? '';
        if (name.isEmpty) continue;
        medicineCounts[name] = (medicineCounts[name] ?? 0) + 1;
      }
    }

    String mostPrescribed = 'N/A';
    int mostCount = 0;
    medicineCounts.forEach((name, itemCount) {
      if (itemCount > mostCount) {
        mostCount = itemCount;
        mostPrescribed = name;
      }
    });

    return {
      'totalPatients': patientCountAgg.count ?? 0,
      'totalPrescriptions': prescriptionCountAgg.count ?? 0,
      'mostPrescribedMedicine': mostPrescribed,
      'mostPrescribedCount': mostCount,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _loadAnalytics(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Failed to load analytics.'));
            }

            final data = snapshot.data ?? {};
            return ListView(
              children: [
                _metricCard('Total Patients', '${data['totalPatients'] ?? 0}'),
                const SizedBox(height: 12),
                _metricCard('Total Prescriptions',
                    '${data['totalPrescriptions'] ?? 0}'),
                const SizedBox(height: 12),
                _metricCard(
                  'Most Prescribed Medicine',
                  '${data['mostPrescribedMedicine'] ?? 'N/A'} (${data['mostPrescribedCount'] ?? 0})',
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _metricCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
            const SizedBox(height: 6),
            Text(value,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
