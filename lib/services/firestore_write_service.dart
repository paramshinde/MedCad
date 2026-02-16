import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/prescription.dart';

/// Centralized Firestore write service with bounded retry/backoff.
class FirestoreWriteService {
  final FirebaseFirestore _db;

  FirestoreWriteService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  bool isQuotaExceeded(Object error) {
    return error is FirebaseException && error.code == 'resource-exhausted';
  }

  Future<void> createPrescription({
    required Prescription prescription,
    required String? doctorId,
  }) {
    return _withRetry(() async {
      final batch = _db.batch();
      final docRef = _db.collection('prescriptions').doc(prescription.id);
      batch.set(docRef, {
        ...prescription.toMap(),
        'doctorId': doctorId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();
    });
  }

  Future<void> saveMedicine({
    required String patientId,
    required String medicineName,
    required String dose,
    required String frequency,
    required int durationDays,
    required String prescriptionId,
  }) {
    return _withRetry(() async {
      final docId = _savedMedicineDocId(
        prescriptionId: prescriptionId,
        medicineName: medicineName,
      );
      await _db
          .collection('saved_medicines')
          .doc(patientId)
          .collection('medicineItems')
          .doc(docId)
          .set({
        'medicineName': medicineName,
        'dose': dose,
        'frequency': frequency,
        'durationDays': durationDays,
        'prescriptionId': prescriptionId,
        'savedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  String _savedMedicineDocId({
    required String prescriptionId,
    required String medicineName,
  }) {
    final normalized = medicineName.trim().toLowerCase().replaceAll(' ', '_');
    return Uri.encodeComponent('${prescriptionId}_$normalized');
  }

  Future<void> _withRetry(Future<void> Function() action) async {
    var attempt = 0;
    while (true) {
      try {
        await action();
        return;
      } on FirebaseException {
        if (attempt >= 2) rethrow;
        final delay = Duration(milliseconds: 400 * (1 << attempt));
        attempt += 1;
        await Future<void>.delayed(delay);
      }
    }
  }
}
