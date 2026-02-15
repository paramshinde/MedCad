import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/prescription.dart';

class PatientScanScreen extends StatefulWidget {
  const PatientScanScreen({super.key});

  @override
  State<PatientScanScreen> createState() => _PatientScanScreenState();
}

class _PatientScanScreenState extends State<PatientScanScreen> {
  Prescription? _loaded;
  bool _isScanning = false;
  bool _isFetching = false;
  bool _alreadyDetected = false;

  Future<void> _loadPrescription(String id) async {
    try {
      setState(() => _isFetching = true);
      final snap = await FirebaseFirestore.instance
          .collection('prescriptions')
          .doc(id)
          .get();

      if (!mounted) return;

      if (!snap.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prescription not found')),
        );
        setState(() {
          _alreadyDetected = false;
          _isScanning = false;
        });
        return;
      }

      setState(() {
        _loaded = Prescription.fromMap(snap.data()!);
        _isScanning = false;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Unable to fetch prescription right now.')),
      );
      setState(() {
        _alreadyDetected = false;
        _isScanning = false;
      });
    } finally {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  void _startScanning() {
    setState(() {
      _loaded = null;
      _isScanning = true;
      _alreadyDetected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0F9FF), Color(0xFFFFFFFF), Color(0xFFE0F2FE)],
          ),
        ),
        child: SafeArea(
          child: _loaded == null ? _buildScannerUi() : _buildPrescriptionUi(),
        ),
      ),
    );
  }

  Widget _buildScannerUi() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0891B2), Color(0xFF06B6D4)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x330891B2),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.qr_code_2_rounded,
                color: Colors.white, size: 42),
          ),
          const SizedBox(height: 14),
          const Text(
            'Scan Prescription',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Place the QR code within the frame to scan',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x140F172A),
                    blurRadius: 14,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(14),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0x220891B2), Color(0x2206B6D4)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Stack(
                  children: [
                    if (_isScanning)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: MobileScanner(
                          onDetect: (capture) {
                            if (_alreadyDetected || _isFetching) return;
                            final raw = capture.barcodes.isNotEmpty
                                ? capture.barcodes.first.rawValue
                                : null;
                            if (raw == null || raw.trim().isEmpty) return;
                            _alreadyDetected = true;
                            _loadPrescription(raw.trim());
                          },
                        ),
                      )
                    else
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.camera_alt_rounded,
                                size: 72, color: Color(0x990891B2)),
                            SizedBox(height: 8),
                            Text(
                              'Position QR code here to scan',
                              style: TextStyle(color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    Positioned(
                        top: 14,
                        left: 14,
                        child: _corner(alignment: Alignment.topLeft)),
                    Positioned(
                        top: 14,
                        right: 14,
                        child: _corner(alignment: Alignment.topRight)),
                    Positioned(
                        bottom: 14,
                        left: 14,
                        child: _corner(alignment: Alignment.bottomLeft)),
                    Positioned(
                        bottom: 14,
                        right: 14,
                        child: _corner(alignment: Alignment.bottomRight)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (_isScanning || _isFetching) ? null : _startScanning,
              icon: (_isScanning || _isFetching)
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.camera_alt_rounded),
              label: Text((_isScanning || _isFetching)
                  ? 'Scanning...'
                  : 'Start Scanning'),
            ),
          ),
          const SizedBox(height: 14),
          _infoCard(),
        ],
      ),
    );
  }

  Widget _buildPrescriptionUi() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _loaded = null),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const Text(
                'Prescription',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x140F172A),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Patient: ${_loaded!.patientId}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (_loaded!.notes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(_loaded!.notes,
                            style: const TextStyle(color: Color(0xFF475569))),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ..._loaded!.medicines.map(
                  (m) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x120F172A),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text('Dose: ${m.dose}',
                            style: const TextStyle(color: Color(0xFF475569))),
                        Text(
                          'Timing: ${m.times.join(', ')}',
                          style: const TextStyle(color: Color(0xFF475569)),
                        ),
                        Text(
                          'Duration: ${m.durationDays} days',
                          style: const TextStyle(color: Color(0xFF475569)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _corner({required Alignment alignment}) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: alignment == Alignment.topLeft || alignment == Alignment.topRight
              ? const BorderSide(color: Color(0xFF0891B2), width: 3)
              : BorderSide.none,
          bottom: alignment == Alignment.bottomLeft ||
                  alignment == Alignment.bottomRight
              ? const BorderSide(color: Color(0xFF0891B2), width: 3)
              : BorderSide.none,
          left: alignment == Alignment.topLeft ||
                  alignment == Alignment.bottomLeft
              ? const BorderSide(color: Color(0xFF0891B2), width: 3)
              : BorderSide.none,
          right: alignment == Alignment.topRight ||
                  alignment == Alignment.bottomRight
              ? const BorderSide(color: Color(0xFF0891B2), width: 3)
              : BorderSide.none,
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x550891B2)),
      ),
      child: const Column(
        children: [
          _TipRow(
            icon: Icons.check_circle_outline_rounded,
            title: 'Good lighting required',
            subtitle: 'Ensure the QR code is well lit',
          ),
          SizedBox(height: 8),
          _TipRow(
            icon: Icons.check_circle_outline_rounded,
            title: 'Hold steady',
            subtitle: 'Keep your device still while scanning',
          ),
          SizedBox(height: 8),
          _TipRow(
            icon: Icons.info_outline_rounded,
            title: 'Valid prescription required',
            subtitle: 'Only scan QR codes from verified doctors',
          ),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TipRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF0891B2), size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              Text(subtitle,
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ],
          ),
        ),
      ],
    );
  }
}
