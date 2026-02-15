import 'package:flutter/material.dart';

import '../models/patient_model.dart';
import '../services/patient_firestore_service.dart';

/// Patient search/list screen supporting edit and delete operations.
class PatientSearchScreen extends StatefulWidget {
  const PatientSearchScreen({super.key});

  @override
  State<PatientSearchScreen> createState() => _PatientSearchScreenState();
}

class _PatientSearchScreenState extends State<PatientSearchScreen> {
  final _service = PatientFirestoreService();
  String? _workingPatientId;

  bool _isEmailValid(String value) {
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return regex.hasMatch(value);
  }

  Future<void> _deletePatient(PatientModel patient) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Patient'),
        content: Text('Delete ${patient.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _workingPatientId = patient.patientId);
    try {
      await _service.deletePatient(patient.patientId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient deleted.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete patient.')),
      );
    } finally {
      if (mounted) setState(() => _workingPatientId = null);
    }
  }

  Future<void> _editPatient(PatientModel patient) async {
    final nameCtrl = TextEditingController(text: patient.name);
    final ageCtrl = TextEditingController(text: patient.age.toString());
    final genderCtrl = TextEditingController(text: patient.gender);
    final phoneCtrl = TextEditingController(text: patient.phone);
    final emailCtrl = TextEditingController(text: patient.email);
    final addressCtrl = TextEditingController(text: patient.address);
    final historyCtrl = TextEditingController(text: patient.medicalHistory);
    final formKey = GlobalKey<FormState>();

    final shouldSave = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Edit Patient',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Name is required'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: ageCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Age'),
                    validator: (value) {
                      final parsed = int.tryParse(value?.trim() ?? '');
                      if (parsed == null || parsed <= 0) {
                        return 'Enter a valid age';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: genderCtrl,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Gender is required'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Phone is required'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      final input = value?.trim() ?? '';
                      if (input.isEmpty) return null;
                      if (!_isEmailValid(input)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: addressCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: historyCtrl,
                    maxLines: 3,
                    decoration:
                        const InputDecoration(labelText: 'Medical History'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          Navigator.pop(context, true);
                        }
                      },
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (shouldSave != true) {
      nameCtrl.dispose();
      ageCtrl.dispose();
      genderCtrl.dispose();
      phoneCtrl.dispose();
      emailCtrl.dispose();
      addressCtrl.dispose();
      historyCtrl.dispose();
      return;
    }

    final updated = PatientModel(
      patientId: patient.patientId,
      name: nameCtrl.text.trim(),
      age: int.parse(ageCtrl.text.trim()),
      gender: genderCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      address: addressCtrl.text.trim(),
      medicalHistory: historyCtrl.text.trim(),
      assignedDoctorId: patient.assignedDoctorId,
      bloodGroup: patient.bloodGroup,
      allergies: patient.allergies,
      chronicDiseases: patient.chronicDiseases,
      emergencyContact: patient.emergencyContact,
      createdAt: patient.createdAt,
    );

    nameCtrl.dispose();
    ageCtrl.dispose();
    genderCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
    historyCtrl.dispose();

    setState(() => _workingPatientId = patient.patientId);
    try {
      await _service.updatePatient(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient updated.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update patient.')),
      );
    } finally {
      if (mounted) setState(() => _workingPatientId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Patients')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<List<PatientModel>>(
          stream: _service.getPatientsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text('Failed to load patients. Please try again.'),
              );
            }

            final patients = snapshot.data ?? [];
            if (patients.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.people_outline_rounded,
                          size: 36, color: Color(0xFF64748B)),
                      SizedBox(height: 10),
                      Text('No patients found'),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              itemCount: patients.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final patient = patients[index];
                final isBusy = _workingPatientId == patient.patientId;

                return Card(
                  child: ListTile(
                    title: Text(patient.name),
                    subtitle: Text(
                      '${patient.gender}, ${patient.age} | ${patient.phone}',
                    ),
                    trailing: Wrap(
                      spacing: 6,
                      children: [
                        IconButton(
                          tooltip: 'Edit',
                          onPressed:
                              isBusy ? null : () => _editPatient(patient),
                          icon: const Icon(Icons.edit_rounded),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          onPressed:
                              isBusy ? null : () => _deletePatient(patient),
                          icon: const Icon(Icons.delete_rounded,
                              color: Color(0xFFDC2626)),
                        ),
                      ],
                    ),
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
