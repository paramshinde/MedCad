import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/prescription.dart';
import 'doctor_med_search.dart';
import 'prescription_qr.dart';

class DoctorCreateScreen extends StatefulWidget {
  const DoctorCreateScreen({super.key});

  @override
  State<DoctorCreateScreen> createState() => _DoctorCreateScreenState();
}

class _DoctorCreateScreenState extends State<DoctorCreateScreen> {
  final _patientNameCtrl = TextEditingController();
  final _patientAgeCtrl = TextEditingController();
  final _patientPhoneCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  final List<_EditableMedicine> _medicines = [];

  @override
  void dispose() {
    _patientNameCtrl.dispose();
    _patientAgeCtrl.dispose();
    _patientPhoneCtrl.dispose();
    _diagnosisCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _addMedicine() async {
    final selected = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(builder: (_) => const DoctorMedSearchScreen()),
    );

    if (selected == null) return;

    final String medName = (selected.name as String?)?.trim() ?? '';
    if (medName.isEmpty) return;

    setState(() {
      _medicines.add(
        _EditableMedicine(
          id: const Uuid().v4(),
          name: medName,
          dose: '1 tablet',
          durationDays: 5,
          frequency: 'Twice daily',
        ),
      );
    });
  }

  void _removeMedicine(String id) {
    setState(() {
      _medicines.removeWhere((m) => m.id == id);
    });
  }

  List<String> _timesFromFrequency(String frequency) {
    final f = frequency.toLowerCase();
    if (f.contains('once')) return const ['Morning'];
    if (f.contains('twice')) return const ['Morning', 'Night'];
    if (f.contains('thrice')) return const ['Morning', 'Afternoon', 'Night'];
    return const ['Morning', 'Night'];
  }

  void _generatePrescription() {
    if (_patientNameCtrl.text.trim().isEmpty ||
        _diagnosisCtrl.text.trim().isEmpty ||
        _medicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Patient details, diagnosis, and medicines are required.'),
        ),
      );
      return;
    }

    final medicines = _medicines
        .map(
          (m) => PrescriptionMedicine(
            name: m.name,
            dose: m.dose.trim().isEmpty ? '1 tablet' : m.dose.trim(),
            times: _timesFromFrequency(m.frequency),
            durationDays: m.durationDays,
          ),
        )
        .toList();

    final noteBuffer = StringBuffer();
    noteBuffer.writeln('Diagnosis: ${_diagnosisCtrl.text.trim()}');
    if (_patientAgeCtrl.text.trim().isNotEmpty) {
      noteBuffer.writeln('Age: ${_patientAgeCtrl.text.trim()}');
    }
    if (_patientPhoneCtrl.text.trim().isNotEmpty) {
      noteBuffer.writeln('Phone: ${_patientPhoneCtrl.text.trim()}');
    }
    if (_notesCtrl.text.trim().isNotEmpty) {
      noteBuffer.writeln('Notes: ${_notesCtrl.text.trim()}');
    }

    final prescription = Prescription(
      id: const Uuid().v4(),
      patientId: _patientNameCtrl.text.trim(),
      medicines: medicines,
      notes: noteBuffer.toString().trim(),
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
      appBar: AppBar(
        title: const Text('Create Prescription'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.description_outlined,
                          color: Color(0xFF0891B2)),
                      SizedBox(width: 8),
                      Text(
                        'Patient Information',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _patientNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Patient Name / ID',
                      hintText: 'Enter full name or patient id',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _patientAgeCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Age'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _patientPhoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(labelText: 'Phone'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _diagnosisCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Diagnosis',
                      hintText: 'Enter diagnosis',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Medicines',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addMedicine,
                      icon: const Icon(Icons.search),
                      label: const Text('Search and Add Medicine'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0891B2),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_medicines.isNotEmpty) ...[
              const SizedBox(height: 14),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medicines Added (${_medicines.length})',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    ..._medicines.map(
                      (medicine) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _MedicineEditor(
                          medicine: medicine,
                          onDelete: () => _removeMedicine(medicine.id),
                          onChanged: () => setState(() {}),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            _card(
              child: TextField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes',
                  hintText: 'Optional notes for patient/pharmacy',
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generatePrescription,
                icon: const Icon(Icons.qr_code_2_rounded),
                label: const Text('Generate Prescription QR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0891B2),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _EditableMedicine {
  final String id;
  final String name;
  String dose;
  int durationDays;
  String frequency;

  _EditableMedicine({
    required this.id,
    required this.name,
    required this.dose,
    required this.durationDays,
    required this.frequency,
  });
}

class _MedicineEditor extends StatelessWidget {
  final _EditableMedicine medicine;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  const _MedicineEditor({
    required this.medicine,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  medicine.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.close_rounded, color: Color(0xFFDC2626)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: medicine.dose,
                  decoration: const InputDecoration(labelText: 'Dosage'),
                  onChanged: (v) {
                    medicine.dose = v;
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: medicine.durationDays.toString(),
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Duration (days)'),
                  onChanged: (v) {
                    medicine.durationDays =
                        int.tryParse(v) ?? medicine.durationDays;
                    onChanged();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: medicine.frequency,
            decoration: const InputDecoration(labelText: 'Frequency'),
            items: const [
              DropdownMenuItem(value: 'Once daily', child: Text('Once daily')),
              DropdownMenuItem(
                  value: 'Twice daily', child: Text('Twice daily')),
              DropdownMenuItem(
                  value: 'Thrice daily', child: Text('Thrice daily')),
            ],
            onChanged: (v) {
              medicine.frequency = v ?? medicine.frequency;
              onChanged();
            },
          ),
        ],
      ),
    );
  }
}
