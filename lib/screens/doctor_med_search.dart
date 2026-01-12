import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../services/rxnorm_service.dart';
import '../services/medicine_firestore_service.dart';
import '../models/medicine_model.dart';

class DoctorMedSearchScreen extends StatefulWidget {
  const DoctorMedSearchScreen({super.key});

  @override
  State<DoctorMedSearchScreen> createState() => _DoctorMedSearchScreenState();
}

class _DoctorMedSearchScreenState extends State<DoctorMedSearchScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final _firestoreService = MedicineFirestoreService();

  dynamic _selected; // can be Medicine or RxDrug

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Firestore first → RxNorm fallback
  Future<List<dynamic>> _getSuggestions(String pattern) async {
    if (pattern.trim().length < 2) return [];

    // 1️⃣ Firestore
    final localResults = await _firestoreService.searchByName(pattern);
    if (localResults.isNotEmpty) {
      return localResults;
    }

    // 2️⃣ RxNorm
    return await RxNormService.findByName(pattern, max: 15);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Search')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TypeAheadField<dynamic>(
              controller: _ctrl,
              focusNode: _focusNode,
              suggestionsCallback: _getSuggestions,

              builder: (context, controller, focusNode) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Medicine name',
                    hintText: 'Start typing (e.g., paracetamol)',
                    border: const OutlineInputBorder(),
                    suffixIcon: controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              controller.clear();
                              setState(() => _selected = null);
                              focusNode.requestFocus();
                            },
                          )
                        : null,
                  ),
                );
              },

              itemBuilder: (context, item) {
                if (item is Medicine) {
                  return ListTile(
                    leading: const Icon(Icons.medical_services),
                    title: Text(item.name),
                    subtitle: Text(item.manufacturer),
                  );
                } else if (item is RxDrug) {
                  return ListTile(
                    leading: const Icon(Icons.public),
                    title: Text(item.name),
                    subtitle: Text('RxCUI: ${item.rxCui}'),
                  );
                }
                return const SizedBox();
              },

              onSelected: (item) {
                setState(() {
                  _selected = item;
                  _ctrl.text = item is Medicine ? item.name : item.name;
                });
                _focusNode.unfocus();
              },

              emptyBuilder: (context) =>
                  const ListTile(title: Text('No matches found')),
              loadingBuilder: (context) =>
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              errorBuilder: (context, error) =>
                  ListTile(title: Text('Error: $error')),
            ),

            const SizedBox(height: 12),

            if (_selected != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.check_circle),
                  title: Text(
                    _selected is Medicine
                        ? _selected.name
                        : _selected.name,
                  ),
                  subtitle: Text(
                    _selected is Medicine
                        ? _selected.manufacturer
                        : 'RxCUI: ${_selected.rxCui}',
                  ),
                  trailing: ElevatedButton(
                    child: const Text('Use'),
                    onPressed: () {
                      Navigator.pop(context, _selected);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
