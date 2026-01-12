import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicine_model.dart';

class MedicineFirestoreService {
  final _db = FirebaseFirestore.instance;
  final _col = FirebaseFirestore.instance.collection('medicines');

  Future<List<Medicine>> searchByName(String query) async {
    if (query.trim().length < 2) return [];

    final q = query.toLowerCase();

    final snap = await _col
        .where('name_lower', isGreaterThanOrEqualTo: q)
        .where('name_lower', isLessThan: q + '\uf8ff')
        .limit(20)
        .get();

    return snap.docs
        .map((d) => Medicine.fromFirestore(d.id, d.data()))
        .toList();
  }
}
