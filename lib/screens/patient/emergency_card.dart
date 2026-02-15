import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/patient_model.dart';
import '../../services/patient_firestore_service.dart';

/// Emergency profile card for quick access to critical patient details.
class EmergencyCardScreen extends StatelessWidget {
  const EmergencyCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patientId = FirebaseAuth.instance.currentUser?.uid;
    final service = PatientFirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Card')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: patientId == null
            ? const Center(child: Text('Please login to view emergency card.'))
            : FutureBuilder<PatientModel?>(
                future: service.getPatientById(patientId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Unable to load emergency profile details.'),
                    );
                  }

                  final patient = snapshot.data;
                  if (patient == null) {
                    return const Center(
                      child:
                          Text('No emergency profile found for your account.'),
                    );
                  }

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient.name,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                              'Blood Group: ${patient.bloodGroup.isEmpty ? 'N/A' : patient.bloodGroup}'),
                          Text(
                              'Allergies: ${patient.allergies.isEmpty ? 'N/A' : patient.allergies}'),
                          Text(
                            'Chronic Diseases: '
                            '${patient.chronicDiseases.isEmpty ? 'N/A' : patient.chronicDiseases}',
                          ),
                          Text(
                            'Emergency Contact: '
                            '${patient.emergencyContact.isEmpty ? 'N/A' : patient.emergencyContact}',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
