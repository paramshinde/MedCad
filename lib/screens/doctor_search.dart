// lib/screens/doctor_search.dart
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../services/rxnorm_service.dart';

class DoctorMedSearchScreen extends StatefulWidget {
  const DoctorMedSearchScreen({Key? key}) : super(key: key);

  @override
  State<DoctorMedSearchScreen> createState() => _DoctorMedSearchScreenState();
}

class _DoctorMedSearchScreenState extends State<DoctorMedSearchScreen> {
  final TextEditingController _ctrl = TextEditingController();
  RxDrug? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Search (RxNorm)')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TypeAheadField<RxDrug>(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _ctrl,
                decoration: const InputDecoration(
                  labelText: 'Medicine name',
                  hintText: 'Start typing (e.g., ibuprofen)',
                  border: OutlineInputBorder(),
                ),
              ),
              suggestionsCallback: (pattern) async {
                if (pattern.trim().length < 2) return [];
                // small debounce is already handled by package; but you can implement one if needed
                final list = await RxNormService.findByName(pattern, max: 15);
                return list;
              },
              itemBuilder: (context, RxDrug suggestion) {
                return ListTile(
                  title: Text(suggestion.name),
                  subtitle: Text('RxCUI: ${suggestion.rxCui}${suggestion.tty.isNotEmpty ? ' • ${suggestion.tty}' : ''}'),
                );
              },
              onSuggestionSelected: (RxDrug suggestion) {
                setState(() {
                  _selected = suggestion;
                  _ctrl.text = suggestion.name;
                });
                // Use selected RxDrug to pre-fill dose/time or to save RxCUI in prescription
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Selected: ${suggestion.name} (RxCUI ${suggestion.rxCui})')),
                );
              },
              noItemsFoundBuilder: (context) => const ListTile(title: Text('No matches')),
              errorBuilder: (context, err) => ListTile(title: Text('Error: $err')),
            ),

            const SizedBox(height: 12),
            if (_selected != null)
              Card(
                child: ListTile(
                  title: Text(_selected!.name),
                  subtitle: Text('RxCUI: ${_selected!.rxCui}'),
                  trailing: ElevatedButton(
                    child: const Text('Use'),
                    onPressed: () {
                      // Example: add to current prescription with default dose/time
                      // TODO: push to your prescription form
                      Navigator.pop(context, _selected);
                    },
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
