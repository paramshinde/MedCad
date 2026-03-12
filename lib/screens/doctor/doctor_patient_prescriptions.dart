import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/patient_model.dart';

/// Shows prescriptions created by the current doctor for a specific patient.
class DoctorPatientPrescriptionsScreen extends StatelessWidget {
  final PatientModel patient;

  const DoctorPatientPrescriptionsScreen({
    super.key,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    final doctorId = FirebaseAuth.instance.currentUser?.uid;
    final patientKeys = <String>{patient.patientId, patient.name}
      ..removeWhere((e) => e.trim().isEmpty);

    return Scaffold(
      appBar: AppBar(title: Text('${patient.name} Prescriptions')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: doctorId == null
            ? const Center(child: Text('Please log in to view prescriptions.'))
            : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('prescriptions')
                    .where('doctorId', isEqualTo: doctorId)
                    .where('patientId', whereIn: patientKeys.toList())
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Unable to load prescriptions.'),
                    );
                  }

                  final docs = snapshot.data?.docs ?? const [];
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('No prescriptions found.'),
                    );
                  }

                  final sortedDocs =
                      List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
                    docs,
                  )..sort((a, b) {
                          final aTs = a.data()['createdAt'] as Timestamp?;
                          final bTs = b.data()['createdAt'] as Timestamp?;
                          final aDt = aTs?.toDate() ??
                              DateTime.fromMillisecondsSinceEpoch(0);
                          final bDt = bTs?.toDate() ??
                              DateTime.fromMillisecondsSinceEpoch(0);
                          return bDt.compareTo(aDt);
                        });

                  return ListView.separated(
                    itemCount: sortedDocs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final data = sortedDocs[index].data();
                      final meds =
                          (data['medicines'] as List<dynamic>?) ?? const [];
                      final notes = (data['notes'] as String?) ?? '';
                      final id = (data['id'] as String?) ??
                          sortedDocs[index].id;
                      final medNames = meds
                          .map((m) => (m as Map<String, dynamic>)['name'])
                          .whereType<String>()
                          .map((n) => n.trim())
                          .where((n) => n.isNotEmpty)
                          .toList(growable: false);

                      return Card(
                        child: ListTile(
                          title: Text('Prescription $id'),
                          subtitle: Text(
                            'Medicines: ${meds.length}'
                            '${medNames.isEmpty ? '' : '\n${
                                medNames.join(', ')
                              }'}'
                            '${notes.trim().isEmpty ? '' : '\nNotes: $notes'}',
                          ),
                          isThreeLine:
                              notes.trim().isNotEmpty || medNames.isNotEmpty,
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
