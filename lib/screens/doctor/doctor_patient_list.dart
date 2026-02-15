import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/patient_model.dart';
import '../../services/patient_firestore_service.dart';

/// Screen for doctors to view only their assigned patients and search by name.
class DoctorPatientListScreen extends StatefulWidget {
  const DoctorPatientListScreen({super.key});

  @override
  State<DoctorPatientListScreen> createState() =>
      _DoctorPatientListScreenState();
}

class _DoctorPatientListScreenState extends State<DoctorPatientListScreen> {
  final _searchCtrl = TextEditingController();
  final _service = PatientFirestoreService();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doctorId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('My Patients')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: doctorId == null
            ? const Center(child: Text('Please log in to view patients.'))
            : Column(
                children: [
                  TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Search patients by name',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value.trim().toLowerCase());
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: StreamBuilder<List<PatientModel>>(
                      stream: _service.getPatientsByDoctorId(doctorId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Center(
                            child:
                                Text('Unable to fetch patients at the moment.'),
                          );
                        }

                        final allPatients = snapshot.data ?? [];
                        final filtered = _searchQuery.isEmpty
                            ? allPatients
                            : allPatients
                                .where(
                                  (p) => p.name
                                      .toLowerCase()
                                      .contains(_searchQuery),
                                )
                                .toList();

                        if (filtered.isEmpty) {
                          return const Center(
                              child: Text('No matching patients found.'));
                        }

                        return ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final patient = filtered[index];
                            return Card(
                              child: ListTile(
                                title: Text(patient.name),
                                subtitle: Text(
                                  '${patient.gender}, ${patient.age} | ${patient.phone}',
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
