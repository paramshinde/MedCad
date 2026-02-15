import 'package:flutter/material.dart';

import '../models/medicine_model.dart';

/// Reusable card that displays complete medicine information sections.
class MedicineDetailCard extends StatelessWidget {
  final Medicine medicine;

  const MedicineDetailCard({
    super.key,
    required this.medicine,
  });

  String _safe(String? value) {
    final text = (value ?? '').trim();
    return text.isEmpty ? 'Not available' : text;
  }

  @override
  Widget build(BuildContext context) {
    final sideEffects = medicine.sideEffects.isEmpty
        ? const ['Not available']
        : medicine.sideEffects;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Medicine Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _detailRow('Generic Name', _safe(medicine.genericName)),
              _detailRow('Brand Name', _safe(medicine.brandName)),
              _detailRow('Strength', _safe(medicine.strength)),
              _detailRow('Dosage Form', _safe(medicine.dosageForm)),
              _detailRow('Manufacturer', _safe(medicine.manufacturer)),
              _detailRow('Indications', _safe(medicine.indications)),
              const SizedBox(height: 8),
              ExpansionTile(
                title: const Text('Side Effects'),
                children: sideEffects
                    .map((e) => ListTile(dense: true, title: Text(_safe(e))))
                    .toList(growable: false),
              ),
              ExpansionTile(
                title: const Text('Warnings'),
                children: [
                  ListTile(dense: true, title: Text(_safe(medicine.warnings))),
                ],
              ),
              ExpansionTile(
                title: const Text('Contraindications'),
                children: [
                  ListTile(
                    dense: true,
                    title: Text(_safe(medicine.contraindications)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
