import 'package:flutter/material.dart';
import '../services/medicine_firestore_service.dart';
import '../models/medicine_model.dart';

class DoctorMedSearchScreen extends StatefulWidget {
  const DoctorMedSearchScreen({super.key});

  @override
  State<DoctorMedSearchScreen> createState() => _DoctorMedSearchScreenState();
}

class _DoctorMedSearchScreenState extends State<DoctorMedSearchScreen> {
  final _ctrl = TextEditingController();
  final _service = MedicineFirestoreService();
  List<MedicineModel> results = [];
  bool loading = false;

  void search() async {
    final q = _ctrl.text;
    if (q.isEmpty) return;

    setState(() => loading = true);
    results = await _service.search(q);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Medicine")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _ctrl,
              decoration: InputDecoration(
                hintText: "Enter medicine name",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: search,
                ),
              ),
              onSubmitted: (_) => search(),
            ),
            if (loading) const LinearProgressIndicator(),
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, i) {
                  final m = results[i];
                  return ListTile(
                    title: Text(m.name),
                    subtitle: Text(m.manufacturer ?? ""),
                    trailing: Text(m.price?.toString() ?? ""),
                    onTap: () => Navigator.pop(context, m),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
