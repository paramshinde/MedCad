import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../models/medicine_model.dart';
import '../screens/doctor/medicine_detail_screen.dart';
import '../services/medicine_firestore_service.dart';
import '../services/rxnorm_service.dart';

/// Doctor medicine search screen that resolves and previews full medicine details.
class DoctorMedSearchScreen extends StatefulWidget {
  const DoctorMedSearchScreen({super.key});

  @override
  State<DoctorMedSearchScreen> createState() => _DoctorMedSearchScreenState();
}

class _DoctorMedSearchScreenState extends State<DoctorMedSearchScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final _firestoreService = MedicineFirestoreService();

  bool _isLoadingDetail = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Firestore first, then RxNorm fallback for medicine name suggestions.
  Future<List<dynamic>> _getSuggestions(String pattern) async {
    if (pattern.trim().length < 2) return [];

    final localResults = await _firestoreService.searchByName(pattern);
    if (localResults.isNotEmpty) return localResults;

    return RxNormService.findByName(pattern, max: 15);
  }

  /// Resolves a selected suggestion into a full [Medicine] detail object.
  Future<Medicine?> _resolveMedicine(dynamic selected) async {
    Medicine? fromFirestore;
    RxDrug? rx;

    if (selected is Medicine) {
      fromFirestore = await _firestoreService.getMedicineByNameExact(selected.name) ?? selected;
    } else if (selected is RxDrug) {
      rx = selected;
      fromFirestore = await _firestoreService.getMedicineByNameExact(selected.name);
    } else {
      return null;
    }

    final base = fromFirestore ??
        Medicine(
          id: rx?.rxCui ?? '',
          name: rx?.name ?? 'Medicine',
          genericName: 'Not available',
          brandName: rx?.name ?? 'Not available',
          strength: 'Not available',
          dosageForm: 'Not available',
          manufacturer: 'Not available',
          saltComposition: '',
          indications: 'Not available',
          sideEffects: const [],
          warnings: 'Not available',
          contraindications: 'Not available',
        );

    final rxCui = rx?.rxCui;
    if (rxCui == null || rxCui.isEmpty) return base;

    final detail = await RxNormService.getMedicineDetailByRxCui(rxCui);
    return base.copyWith(
      brandName: (detail['brandName'] as String?)?.trim().isNotEmpty == true
          ? detail['brandName'] as String
          : base.brandName,
      dosageForm: (detail['dosageForm'] as String?)?.trim().isNotEmpty == true
          ? detail['dosageForm'] as String
          : base.dosageForm,
      indications: (detail['indications'] as String?)?.trim().isNotEmpty == true
          ? detail['indications'] as String
          : base.indications,
    );
  }

  Future<void> _onSuggestionTap(dynamic item) async {
    setState(() => _isLoadingDetail = true);
    try {
      final resolved = await _resolveMedicine(item);
      if (!mounted) return;

      if (resolved == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to resolve medicine details.')),
        );
        return;
      }

      final selectedMedicine = await Navigator.push<Medicine?>(
        context,
        MaterialPageRoute(
          builder: (_) => MedicineDetailScreen(medicine: resolved),
        ),
      );

      if (!mounted || selectedMedicine == null) return;
      Navigator.pop(context, selectedMedicine);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load medicine details.')),
      );
    } finally {
      if (mounted) setState(() => _isLoadingDetail = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Search')),
      body: Padding(
        padding: const EdgeInsets.all(12),
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
                }
                if (item is RxDrug) {
                  return ListTile(
                    leading: const Icon(Icons.public),
                    title: Text(item.name),
                    subtitle: Text('RxCUI: ${item.rxCui}'),
                  );
                }
                return const ListTile(title: Text('Unsupported suggestion'));
              },
              onSelected: _onSuggestionTap,
              emptyBuilder: (context) =>
                  const ListTile(title: Text('No matches found')),
              loadingBuilder: (context) => const Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              errorBuilder: (context, error) =>
                  ListTile(title: Text('Error: $error')),
            ),
            const SizedBox(height: 12),
            if (_isLoadingDetail)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 10),
                      Text('Loading medicine details...'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
