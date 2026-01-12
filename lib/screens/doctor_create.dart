import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/medicine_model.dart';
import '../models/prescription.dart';
import 'doctor_med_search.dart';
import 'prescription_qr.dart';

class DoctorCreateScreen extends StatefulWidget {
  const DoctorCreateScreen({super.key});

  @override
  State<DoctorCreateScreen> createState() => _DoctorCreateScreenState();
}

class _DoctorCreateScreenState extends State<DoctorCreateScreen> {
  final _patientIdCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  final _doseCtrl = TextEditingController();
  final _daysCtrl = TextEditingController(text: '5');

  final List<PrescriptionMedicine> _medicines = [];

  @override
  void dispose() {
    _patientIdCtrl.dispose();
    _notesCtrl.dispose();
    _doseCtrl.dispose();
    _daysCtrl.dispose();
    super.dispose();
  }

  Future<void> _addMedicine() async {
    final Medicine? selected = await Navigator.push<Medicine?>(
      context,
      MaterialPageRoute(
        builder: (_) => const DoctorMedSearchScreen(),
      ),
    );

    if (selected == null) return;

    if (_doseCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter dose')),
      );
      return;
    }

    setState(() {
      _medicines.add(
        PrescriptionMedicine(
          name: selected.name,
          dose: _doseCtrl.text.trim(),
          times: const ['Morning', 'Night'],
          durationDays: int.tryParse(_daysCtrl.text) ?? 5,
        ),
      );
    });

    _doseCtrl.clear();
  }

  void _generatePrescription() {
    if (_patientIdCtrl.text.trim().isEmpty || _medicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient ID and medicines required')),
      );
      return;
    }

    final prescription = Prescription(
      id: const Uuid().v4(),
      patientId: _patientIdCtrl.text.trim(),
      medicines: _medicines,
      notes: _notesCtrl.text.trim(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrescriptionQrScreen(prescription: prescription),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Prescription')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            TextField(
              controller: _patientIdCtrl,
              decoration: const InputDecoration(
                labelText: 'Patient ID',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _doseCtrl,
              decoration: const InputDecoration(
                labelText: 'Dose (e.g. 500 mg)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _daysCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Duration (days)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Medicine'),
              onPressed: _addMedicine,
            ),

            const SizedBox(height: 20),

            if (_medicines.isNotEmpty)
              const Text(
                'Medicines Added',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

            ..._medicines.map(
              (m) => Card(
                child: ListTile(
                  title: Text(
                    '${m.name} — ${m.dose.isEmpty ? '(dose not set)' : m.dose}',
                  ),
                  subtitle:
                      Text('${m.times.join(', ')} • ${m.durationDays} days'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() => _medicines.remove(m));
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _generatePrescription,
              child: const Text('Generate Prescription QR'),
            ),
          ],
        ),
      ),
    );
  }
}
