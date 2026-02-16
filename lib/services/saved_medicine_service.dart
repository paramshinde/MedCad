import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_write_service.dart';

/// Service for storing and managing medicines saved by a patient.
class SavedMedicineService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirestoreWriteService _writeService = FirestoreWriteService();

  CollectionReference<Map<String, dynamic>> _items(String patientId) {
    return _db
        .collection('saved_medicines')
        .doc(patientId)
        .collection('medicineItems');
  }

  /// Saves a medicine item under the patient medicine subcollection.
  Future<void> saveMedicine({
    required String patientId,
    required String medicineName,
    required String dose,
    required String frequency,
    required int durationDays,
    required String prescriptionId,
  }) async {
    await _writeService.saveMedicine(
      patientId: patientId,
      medicineName: medicineName,
      dose: dose,
      frequency: frequency,
      durationDays: durationDays,
      prescriptionId: prescriptionId,
    );
  }

  /// Streams saved medicines for a patient ordered by latest saved item first.
  Stream<List<Map<String, dynamic>>> getSavedMedicines(String patientId) {
    return _items(patientId)
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(growable: false),
        );
  }

  /// Deletes a saved medicine document by id.
  Future<void> deleteSavedMedicine({
    required String patientId,
    required String medicineItemId,
  }) async {
    await _items(patientId).doc(medicineItemId).delete();
  }
}
