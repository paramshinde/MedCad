import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Timeline view for patient prescription history grouped by date.
class PrescriptionHistoryScreen extends StatefulWidget {
  const PrescriptionHistoryScreen({super.key});

  @override
  State<PrescriptionHistoryScreen> createState() =>
      _PrescriptionHistoryScreenState();
}

class _PrescriptionHistoryScreenState extends State<PrescriptionHistoryScreen> {
  String? _patientId;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _prescriptionStream;

  @override
  void initState() {
    super.initState();
    _patientId = FirebaseAuth.instance.currentUser?.uid;
    if (_patientId != null) {
      _prescriptionStream = FirebaseFirestore.instance
          .collection('prescriptions')
          .where('patientId', isEqualTo: _patientId)
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
  }

  String _dayKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prescription History')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _patientId == null
            ? const Center(child: Text('Please log in to view history.'))
            : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _prescriptionStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Unable to load history.'));
                  }

                  final docs = snapshot.data?.docs ?? const [];
                  if (docs.isEmpty) {
                    return const Center(child: Text('No prescriptions found.'));
                  }

                  final grouped = <String,
                      List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};
                  for (final doc in docs) {
                    final ts = doc.data()['createdAt'] as Timestamp?;
                    final dt = ts?.toDate() ?? DateTime.now();
                    final key = _dayKey(dt);
                    grouped.putIfAbsent(key, () => []).add(doc);
                  }

                  final sortedKeys = grouped.keys.toList()
                    ..sort((a, b) => b.compareTo(a));

                  return ListView.builder(
                    itemCount: sortedKeys.length,
                    itemBuilder: (context, index) {
                      final key = sortedKeys[index];
                      final items = grouped[key]!;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              key,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...items.map((doc) {
                              final data = doc.data();
                              final meds =
                                  (data['medicines'] as List<dynamic>? ??
                                      const []);
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(
                                      'Prescription ${data['id'] ?? doc.id}'),
                                  subtitle: Text(
                                    'Medicines: ${meds.length}\nNotes: ${data['notes'] ?? ''}',
                                  ),
                                  isThreeLine: true,
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
