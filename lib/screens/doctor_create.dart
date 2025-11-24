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
    final medName = _medNameCtrl.text.trim();
    if (medName.isEmpty) return;

    final times = _timesCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final med = Medicine(
      name: medName,
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
    // Basic validation
    if (_patientNameCtrl.text.trim().isEmpty || medicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add patient name and at least one medicine')),
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final id = const Uuid().v4();
    final presc = Prescription(
      id: id,
      doctor: {
        'id': 'doc_1',
        'name': _docNameCtrl.text.trim(),
        'clinic': 'My Clinic'
      },
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
  void dispose() {
    _docNameCtrl.dispose();
    _patientNameCtrl.dispose();
    _medNameCtrl.dispose();
    _doseCtrl.dispose();
    _timesCtrl.dispose();
    _durationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor — Create Prescription')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Doctor & Patient
                  TextFormField(
                    controller: _docNameCtrl,
                    decoration: const InputDecoration(labelText: 'Doctor name'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter doctor name' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _patientNameCtrl,
                    decoration: const InputDecoration(labelText: 'Patient name'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter patient name' : null,
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Add Medicine area
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Add Medicine', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(controller: _medNameCtrl, decoration: const InputDecoration(labelText: 'Medicine name')),
                  TextFormField(controller: _doseCtrl, decoration: const InputDecoration(labelText: 'Dose (e.g., 500mg)')),
                  TextFormField(controller: _timesCtrl, decoration: const InputDecoration(labelText: 'Times (comma separated, HH:mm)')),
                  TextFormField(controller: _durationCtrl, decoration: const InputDecoration(labelText: 'Duration (days)')),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _addMedicine,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Medicine'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final RxDrug? result = await Navigator.push<RxDrug?>(
                              context,
                              MaterialPageRoute(builder: (_) => const DoctorMedSearchScreen()),
                            );

                            if (result != null) {
                              setState(() {
                                medicines.add(Medicine(
                                  name: result.name,
                                  dose: '',
                                  times: ['08:00', '20:00'],
                                  durationDays: 5,
                                  notes: '',
                                  rxcui: result.rxCui,
                                ));
                                _medNameCtrl.text = result.name;
                              });
                            }
                          },
                          icon: const Icon(Icons.search),
                          label: const Text('Add Medicine (Search)'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Medicines list
                  if (medicines.isNotEmpty)
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Medicines added:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...List.generate(medicines.length, (index) {
                              final m = medicines[index];
                              return ListTile(
                                title: Text('${m.name} — ${m.dose.isEmpty ? '(dose not set)' : m.dose}'),
                                subtitle: Text('${m.times.join(', ')} • ${m.durationDays} days'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => setState(() {
                                    medicines.removeAt(index);
                                  }),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  TextFormField(controller: _notesCtrl, decoration: const InputDecoration(labelText: 'Notes (optional)')),
                  const SizedBox(height: 20),

                  // Big Row: Search (again) + Generate QR
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final RxDrug? result = await Navigator.push<RxDrug?>(
                              context,
                              MaterialPageRoute(builder: (_) => const DoctorMedSearchScreen()),
                            );

                            if (result != null) {
                              setState(() {
                                medicines.add(Medicine(
                                  name: result.name,
                                  dose: '',
                                  times: ['08:00', '20:00'],
                                  durationDays: 5,
                                  notes: '',
                                  rxcui: result.rxCui,
                                ));
                                _medNameCtrl.text = result.name;
                              });
                            }
                          },
                          icon: const Icon(Icons.search),
                          label: const Text('Add Medicine (Search)'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _generatePrescription,
                          icon: const Icon(Icons.qr_code),
                          label: const Text('Generate QR'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
