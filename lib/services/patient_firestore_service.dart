import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/patient_model.dart';

/// Firestore CRUD service for patient entities.
class PatientFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('patients');

  /// Creates a new patient document.
  Future<void> addPatient(PatientModel patient) async {
    await _col.doc(patient.patientId).set(patient.toMap());
  }

  /// Updates an existing patient document.
  Future<void> updatePatient(PatientModel patient) async {
    await _col.doc(patient.patientId).update({
      'patientId': patient.patientId,
      'name': patient.name,
      'age': patient.age,
      'gender': patient.gender,
      'phone': patient.phone,
      'email': patient.email,
      'address': patient.address,
      'medicalHistory': patient.medicalHistory,
      'assignedDoctorId': patient.assignedDoctorId,
      'bloodGroup': patient.bloodGroup,
      'allergies': patient.allergies,
      'chronicDiseases': patient.chronicDiseases,
      'emergencyContact': patient.emergencyContact,
    });
  }

  /// Deletes a patient document by id.
  Future<void> deletePatient(String patientId) async {
    await _col.doc(patientId).delete();
  }

  /// Streams all patients and sorts by created date descending.
  Stream<List<PatientModel>> getPatientsStream() {
    return _col.snapshots().map((snap) {
      final patients = snap.docs
          .map((d) => PatientModel.fromMap(d.data(), id: d.id))
          .toList();
      patients.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return patients;
    });
  }

  /// Streams patients that are assigned to a specific doctor.
  Stream<List<PatientModel>> getPatientsByDoctorId(String doctorId) {
    return _col
        .where('assignedDoctorId', isEqualTo: doctorId)
        .snapshots()
        .map((snap) {
      final patients = snap.docs
          .map((d) => PatientModel.fromMap(d.data(), id: d.id))
          .toList();
      patients.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return patients;
    });
  }

  /// Retrieves a single patient by document id.
  Future<PatientModel?> getPatientById(String patientId) async {
    final snap = await _col.doc(patientId).get();
    if (!snap.exists || snap.data() == null) return null;
    return PatientModel.fromMap(snap.data()!, id: snap.id);
  }
}
