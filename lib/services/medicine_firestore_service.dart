import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicine_model.dart';

/// Firestore medicine search/detail service.
class MedicineFirestoreService {
  final _col = FirebaseFirestore.instance.collection('medicines');

  Future<List<Medicine>> searchByName(String query) async {
    if (query.trim().length < 2) return [];

    final q = query.toLowerCase();

    final snap = await _col
        .where('name_lower', isGreaterThanOrEqualTo: q)
        .where('name_lower', isLessThan: '$q\uf8ff')
        .limit(20)
        .get();

    return snap.docs
        .map((d) => Medicine.fromFirestore(d.id, d.data()))
        .toList();
  }

  /// Fetches a single medicine by exact name match (case-insensitive via name_lower).
  Future<Medicine?> getMedicineByNameExact(String name) async {
    final normalized = name.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    final snap =
        await _col.where('name_lower', isEqualTo: normalized).limit(1).get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return Medicine.fromFirestore(doc.id, doc.data());
  }
}
