import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../services/saved_medicine_service.dart';
import '../../services/firestore_write_service.dart';

/// QR scanner screen for patients to fetch and save prescription medicines.
class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final _savedService = SavedMedicineService();
  final _writeService = FirestoreWriteService();
  Map<String, dynamic>? _prescription;
  String? _prescriptionId;
  bool _isScanning = false;
  bool _busy = false;
  bool _alreadyDetected = false;

  Future<void> _loadPrescription(String id) async {
    try {
      setState(() => _busy = true);
      final snap = await FirebaseFirestore.instance
          .collection('prescriptions')
          .doc(id)
          .get();
      if (!mounted) return;

      if (!snap.exists || snap.data() == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prescription not found.')),
        );
        setState(() {
          _alreadyDetected = false;
          _isScanning = false;
        });
        return;
      }

      setState(() {
        _prescriptionId = id;
        _prescription = snap.data();
        _isScanning = false;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to fetch prescription.')),
      );
      setState(() {
        _alreadyDetected = false;
        _isScanning = false;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveMedicine(Map<String, dynamic> med) async {
    final patientId = FirebaseAuth.instance.currentUser?.uid;
    if (patientId == null || _prescriptionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to save medicine.')),
      );
      return;
    }

    try {
      setState(() => _busy = true);
      await _savedService.saveMedicine(
        patientId: patientId,
        medicineName: (med['name'] as String?) ?? 'Unknown Medicine',
        dose: (med['dose'] as String?) ?? '',
        frequency: ((med['times'] as List<dynamic>?) ?? const []).join(', '),
        durationDays: (med['durationDays'] as num?)?.toInt() ?? 0,
        prescriptionId: _prescriptionId!,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicine saved to your list.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _writeService.isQuotaExceeded(e)
                ? 'Quota exceeded'
                : 'Failed to save medicine.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final meds = (_prescription?['medicines'] as List<dynamic>?) ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Prescription QR')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _prescription == null
            ? Column(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _isScanning
                            ? MobileScanner(
                                onDetect: (capture) {
                                  if (_alreadyDetected || _busy) return;
                                  final value = capture.barcodes.isNotEmpty
                                      ? capture.barcodes.first.rawValue
                                      : null;
                                  if (value == null || value.trim().isEmpty) {
                                    return;
                                  }
                                  _alreadyDetected = true;
                                  _loadPrescription(value.trim());
                                },
                              )
                            : const Center(
                                child:
                                    Text('Tap start to scan prescription QR'),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (_isScanning || _busy)
                          ? null
                          : () {
                              setState(() {
                                _isScanning = true;
                                _alreadyDetected = false;
                              });
                            },
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: Text(_busy ? 'Please wait...' : 'Start Scanning'),
                    ),
                  ),
                ],
              )
            : ListView(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prescription ID: ${_prescriptionId ?? '-'}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                              'Patient: ${_prescription?['patientId'] ?? '-'}'),
                          if ((_prescription?['notes'] as String?)
                                  ?.isNotEmpty ??
                              false) ...[
                            const SizedBox(height: 6),
                            Text('Notes: ${_prescription?['notes']}'),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...meds.map((m) {
                    final med = m as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              med['name']?.toString() ?? 'Unknown Medicine',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text('Dose: ${med['dose'] ?? ''}'),
                            Text(
                                'Times: ${((med['times'] as List<dynamic>?) ?? []).join(', ')}'),
                            Text('Duration: ${med['durationDays'] ?? 0} days'),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    _busy ? null : () => _saveMedicine(med),
                                child: const Text('Save to My Medicines'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
      ),
    );
  }
}
