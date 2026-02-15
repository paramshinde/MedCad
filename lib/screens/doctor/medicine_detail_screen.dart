import 'package:flutter/material.dart';

import '../../models/medicine_model.dart';
import '../../widgets/medicine_detail_card.dart';

/// Full medicine detail preview screen used by doctor before selecting medicine.
class MedicineDetailScreen extends StatelessWidget {
  final Medicine medicine;

  const MedicineDetailScreen({
    super.key,
    required this.medicine,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(medicine.name.isEmpty ? 'Medicine Detail' : medicine.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(child: MedicineDetailCard(medicine: medicine)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, medicine),
                child: const Text('Use This Medicine'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
