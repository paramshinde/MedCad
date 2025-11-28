// lib/screens/doctor_search.dart
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../services/rxnorm_service.dart';

class DoctorMedSearchScreen extends StatefulWidget {
  const DoctorMedSearchScreen({super.key});

  @override
  State<DoctorMedSearchScreen> createState() => _DoctorMedSearchScreenState();
}

class _DoctorMedSearchScreenState extends State<DoctorMedSearchScreen> {
  // Keep a controller and focus node so other parts of the screen can access them.
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  RxDrug? _selected;

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Fetch suggestions from your service. Return an empty list on error.
  Future<List<RxDrug>> _getSuggestions(String pattern) async {
    if (pattern.trim().length < 2) return [];
    try {
      final list = await RxNormService.findByName(pattern, max: 15);
      return list;
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search error: $err')),
        );
      }
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Search (RxNorm)')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // TypeAheadField usage for flutter_typeahead >= 5.x
            TypeAheadField<RxDrug>(
              // pass your controller & focus node so the builder receives them
              controller: _ctrl,
              focusNode: _focusNode,

              // suggestions callback
              suggestionsCallback: _getSuggestions,

              // Build the actual TextField. The `controller` argument here is the
              // same instance you passed above (so they stay in sync).
              builder: (BuildContext context, TextEditingController controller, FocusNode focusNode) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Medicine name',
                    hintText: 'Start typing (e.g., ibuprofen)',
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
                  onSubmitted: (_) => focusNode.unfocus(),
                );
              },

              // suggestion tile
              itemBuilder: (context, RxDrug suggestion) {
                final tty = suggestion.tty.isNotEmpty ? ' • ${suggestion.tty}' : '';
                return ListTile(
                  leading: const Icon(Icons.medical_services),
                  title: Text(suggestion.name),
                  subtitle: Text('RxCUI: ${suggestion.rxCui}$tty'),
                );
              },

              // selection callback (v5.x uses onSelected)
              onSelected: (RxDrug suggestion) {
                setState(() {
                  _selected = suggestion;
                  // keep our own _ctrl in sync (we already passed it in)
                  _ctrl.text = suggestion.name;
                });
                _focusNode.unfocus();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Selected: ${suggestion.name} (RxCUI ${suggestion.rxCui})')),
                );
              },

              // empty / error / loading builders (v5.x)
              emptyBuilder: (context) => const ListTile(title: Text('No matches')),
              errorBuilder: (context, error) => ListTile(title: Text('Error: $error')),
              loadingBuilder: (context) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)),
              ),

              // appearance and sizing of the suggestions box
              decorationBuilder: (context, child) => Material(elevation: 4, child: child),
              offset: const Offset(0, 6),
              constraints: const BoxConstraints(maxHeight: 300),
            ),

            const SizedBox(height: 12),

            if (_selected != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(_selected!.name),
                  subtitle: Text('RxCUI: ${_selected!.rxCui}'),
                  trailing: ElevatedButton(
                    child: const Text('Use'),
                    onPressed: () {
                      // Return selected RxDrug to caller (e.g., prescription form)
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
