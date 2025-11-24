// lib/screens/doctor_create.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/prescription.dart';
import 'prescription_qr.dart';
import '../services/rxnorm_service.dart'; 
import 'doctor_search.dart';

class DoctorCreateScreen extends StatefulWidget {
  const DoctorCreateScreen({Key? key}) : super(key: key);

  @override
  State<DoctorCreateScreen> createState() => _DoctorCreateScreenState();
}

class _DoctorCreateScreenState extends State<DoctorCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _docNameCtrl = TextEditingController(text: 'Dr. YourName');
  final _patientNameCtrl = TextEditingController();
  final _medNameCtrl = TextEditingController();
  final _doseCtrl = TextEditingController();
  final _timesCtrl = TextEditingController(text: '08:00,20:00'); // comma separated
  final _durationCtrl = TextEditingController(text: '5');
  final _notesCtrl = TextEditingController();

  List<Medicine> medicines = [];

  void _addMedicine() {
    if (_medNameCtrl.text.trim().isEmpty) return;
    final times = _timesCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final med = Medicine(
      name: _medNameCtrl.text.trim(),
      dose: _doseCtrl.text.trim(),
      times: times,
      durationDays: int.tryParse(_durationCtrl.text) ?? 1,
      notes: '',
    );
    setState(() {
      medicines.add(med);
      _medNameCtrl.clear();
      _doseCtrl.clear();
      _timesCtrl.text = '08:00,20:00';
      _durationCtrl.text = '5';
    });
  }

  void _generatePrescription() {
    if (_patientNameCtrl.text.trim().isEmpty || medicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add patient name and at least one medicine')),
      );
      return;
    }

    final id = const Uuid().v4();
    final presc = Prescription(
      id: id,
      doctor: {'id': 'doc_1', 'name': _docNameCtrl.text.trim(), 'clinic': 'My Clinic'},
      patient: {'name': _patientNameCtrl.text.trim()},
      issuedAt: DateTime.now(),
      medicines: medicines,
      notes: _notesCtrl.text.trim(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PrescriptionQrScreen(prescription: presc)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor — Create Prescription')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(controller: _docNameCtrl, decoration: const InputDecoration(labelText: 'Doctor name')),
                const SizedBox(height: 8),
                TextFormField(controller: _patientNameCtrl, decoration: const InputDecoration(labelText: 'Patient name')),
                const SizedBox(height: 12),
                const Divider(),
                const Text('Add Medicine', style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(controller: _medNameCtrl, decoration: const InputDecoration(labelText: 'Medicine name')),
                TextFormField(controller: _doseCtrl, decoration: const InputDecoration(labelText: 'Dose (e.g., 500mg)')),
                TextFormField(controller: _timesCtrl, decoration: const InputDecoration(labelText: 'Times (comma separated, HH:mm)')),
                TextFormField(controller: _durationCtrl, decoration: const InputDecoration(labelText: 'Duration (days)')),
                const SizedBox(height: 8),
                ElevatedButton.icon(onPressed: _addMedicine, icon: const Icon(Icons.add), label: const Text('Add Medicine')),
                const SizedBox(height: 12),
                if (medicines.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Medicines added:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...medicines.map((m) => ListTile(
                            title: Text('${m.name} — ${m.dose}'),
                            subtitle: Text('${m.times.join(', ')} • ${m.durationDays} days'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => setState(() => medicines.remove(m)),
                            ),
                          )),
                    ],
                  ),
                const SizedBox(height: 12),
                TextFormField(controller: _notesCtrl, decoration: const InputDecoration(labelText: 'Notes (optional)')),
                const SizedBox(height: 16),
                ElevatedButton(
  onPressed: () async {
    final RxDrug? result = await Navigator.push<RxDrug?>(
      context,
      MaterialPageRoute(builder: (_) => const DoctorMedSearchScreen()),
    );

    if (result != null) {
      // Use the RxDrug to create a Medicine and add to the list shown in UI
      setState(() {
        medicines.add(Medicine(
          name: result.name,
          dose: '', // doctor can fill dose after selection if needed
          times: ['08:00', '20:00'], // default times; or keep empty []
          durationDays: 5, // default; doctor can edit later
          notes: '',
          rxcui: result.rxCui,
        ));

        // Optionally prefill the medName text field with the selected name:
        _medNameCtrl.text = result.name;
      });
    }
  },
  child: const Text('Add Medicine (Search)'),
),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
