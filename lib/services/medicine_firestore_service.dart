import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicine_model.dart';

class MedicineFirestoreService {
  final _col = FirebaseFirestore.instance.collection('medicines');

  Future<List<MedicineModel>> search(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    final snap = await _col
        .where('name_lower', isGreaterThanOrEqualTo: q)
        .where('name_lower', isLessThan: q + '\uf8ff')
        .limit(40)
        .get();

    return snap.docs
        .map((d) => MedicineModel.fromMap(d.data(), d.id))
        .toList();
  }
}
