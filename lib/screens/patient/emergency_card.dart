import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/patient_model.dart';
import '../../services/patient_firestore_service.dart';

/// Emergency profile card for quick access to critical patient details.
class EmergencyCardScreen extends StatefulWidget {
  const EmergencyCardScreen({super.key});

  @override
  State<EmergencyCardScreen> createState() => _EmergencyCardScreenState();
}

class _EmergencyCardScreenState extends State<EmergencyCardScreen> {
  final _bloodGroupCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _chronicCtrl = TextEditingController();
  final _emergencyCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _isEditing = false;
  bool _isDirty = false;
  String? _primedPatientId;
  bool _primedForEdit = false;

  @override
  void dispose() {
    _bloodGroupCtrl.dispose();
    _allergiesCtrl.dispose();
    _chronicCtrl.dispose();
    _emergencyCtrl.dispose();
    super.dispose();
  }

  bool _needsEmergencyInfo(PatientModel patient) {
    return patient.bloodGroup.trim().isEmpty ||
        patient.allergies.trim().isEmpty ||
        patient.chronicDiseases.trim().isEmpty ||
        patient.emergencyContact.trim().isEmpty;
  }

  void _primeControllers(PatientModel patient) {
    _bloodGroupCtrl.text = patient.bloodGroup;
    _allergiesCtrl.text = patient.allergies;
    _chronicCtrl.text = patient.chronicDiseases;
    _emergencyCtrl.text = patient.emergencyContact;
    _isDirty = false;
  }

  void _maybePrimeControllers(PatientModel patient) {
    final needsPrime = _primedPatientId != patient.patientId ||
        (_isEditing && !_primedForEdit);
    if (!needsPrime) return;
    _primeControllers(patient);
    _primedPatientId = patient.patientId;
    _primedForEdit = _isEditing;
  }

  void _markDirty() {
    if (_isDirty) return;
    setState(() => _isDirty = true);
  }

  Future<bool> _confirmDiscard() async {
    if (!_isDirty) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your emergency details changes will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Editing'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _saveEmergencyInfo(
    PatientModel patient,
    PatientFirestoreService service,
  ) async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save emergency details?'),
        content: const Text('This will update your emergency card.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isSaving = true);
    try {
      final updated = PatientModel(
        patientId: patient.patientId,
        name: patient.name,
        age: patient.age,
        gender: patient.gender,
        phone: patient.phone,
        email: patient.email,
        address: patient.address,
        medicalHistory: patient.medicalHistory,
        assignedDoctorId: patient.assignedDoctorId,
        bloodGroup: _bloodGroupCtrl.text.trim(),
        allergies: _allergiesCtrl.text.trim(),
        chronicDiseases: _chronicCtrl.text.trim(),
        emergencyContact: _emergencyCtrl.text.trim(),
        createdAt: patient.createdAt,
      );
      await service.updatePatient(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Emergency details saved.')),
      );
      setState(() {
        _isEditing = false;
        _isDirty = false;
        _primedForEdit = false;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save emergency details.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

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

                  if (_needsEmergencyInfo(patient) || _isEditing) {
                    _maybePrimeControllers(patient);
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Complete Emergency Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: _bloodGroupCtrl.text.isEmpty
                                    ? null
                                    : _bloodGroupCtrl.text,
                                decoration: const InputDecoration(
                                  labelText: 'Blood Group',
                                ),
                                items: const [
                                  'A+',
                                  'A-',
                                  'B+',
                                  'B-',
                                  'AB+',
                                  'AB-',
                                  'O+',
                                  'O-',
                                ]
                                    .map(
                                      (value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(value),
                                      ),
                                    )
                                    .toList(growable: false),
                                onChanged: (value) {
                                  _bloodGroupCtrl.text = value ?? '';
                                  _markDirty();
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Select blood group';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _allergiesCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Allergies',
                                  hintText: 'E.g., penicillin',
                                ),
                                onChanged: (_) => _markDirty(),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter allergies (or none)';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _chronicCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Chronic Diseases',
                                  hintText: 'E.g., diabetes',
                                ),
                                onChanged: (_) => _markDirty(),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter chronic diseases (or none)';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _emergencyCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Emergency Contact',
                                  hintText: 'Name and phone number',
                                ),
                                onChanged: (_) => _markDirty(),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter emergency contact';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isSaving
                                      ? null
                                      : () => _saveEmergencyInfo(
                                            patient,
                                            service,
                                          ),
                                  child: Text(
                                    _isSaving ? 'Saving...' : 'Save Details',
                                  ),
                                ),
                              ),
                              if (_isEditing) ...[
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: _isSaving
                                        ? null
                                        : () async {
                                            final discard =
                                                await _confirmDiscard();
                                            if (!discard) return;
                                            if (!mounted) return;
                                            setState(() {
                                              _isEditing = false;
                                              _isDirty = false;
                                              _primedForEdit = false;
                                            });
                                          },
                                    child: const Text('Cancel'),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
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
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => setState(() {
                                _isEditing = true;
                                _isDirty = false;
                                _primedForEdit = false;
                              }),
                              icon: const Icon(Icons.edit_rounded),
                              label: const Text('Edit Emergency Details'),
                            ),
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
