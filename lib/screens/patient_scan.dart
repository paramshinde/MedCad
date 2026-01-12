import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/prescription.dart';

class PatientScanScreen extends StatefulWidget {
  const PatientScanScreen({super.key});

  @override
  State<PatientScanScreen> createState() => _PatientScanScreenState();
}

class _PatientScanScreenState extends State<PatientScanScreen> {
  Prescription? _loaded;
  bool _scanned = false;

  Future<void> _loadPrescription(String id) async {
    final snap = await FirebaseFirestore.instance
        .collection('prescriptions')
        .doc(id)
        .get();

    if (!snap.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prescription not found')),
      );
      return;
    }

    setState(() {
      _loaded = Prescription.fromMap(snap.data()!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Prescription')),
      body: _loaded == null
          ? MobileScanner(
              onDetect: (capture) {
                if (_scanned) return;
                final barcode = capture.barcodes.first;
                final id = barcode.rawValue;
                if (id == null) return;

                _scanned = true;
                _loadPrescription(id);
              },
            )
          : Padding(
              padding: const EdgeInsets.all(12),
              child: ListView(
                children: [
                  const Text(
                    'Prescription',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ..._loaded!.medicines.map(
                    (m) => Card(
                      child: ListTile(
                        title: Text('${m.name} — ${m.dose}'),
                        subtitle: Text(
                          '${m.times.join(', ')} • ${m.durationDays} days',
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (_loaded!.notes.isNotEmpty)
                    Text('Notes: ${_loaded!.notes}'),
                ],
              ),
            ),
    );
  }
}
