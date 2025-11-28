import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/prescription.dart';
import 'package:intl/intl.dart';

class PatientScanScreen extends StatefulWidget {
  const PatientScanScreen({super.key});

  @override
  State<PatientScanScreen> createState() => _PatientScanScreenState();
}

class _PatientScanScreenState extends State<PatientScanScreen> {
  String? error;
  Prescription? loaded;
  final MobileScannerController controller = MobileScannerController();

  void _handleBarcodeCapture(BarcodeCapture capture) {
    if (capture.barcodes.isEmpty) return;
    final raw = capture.barcodes.first.rawValue;
    if (raw == null) return;

    try {
      final presc = Prescription.fromJsonString(raw);
      setState(() {
        loaded = presc;
        error = null;
      });
    } catch (e) {
      setState(() {
        error = "Invalid QR or unsupported format";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient — Scan QR')),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              controller: controller,
              onDetect: _handleBarcodeCapture,
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: loaded == null
                  ? Center(child: Text(error ?? "Scan a prescription QR"))
                  : _buildPrescription(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescription() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Patient: ${loaded!.patient['name']}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text("Doctor: ${loaded!.doctor['name']}"),
          Text("Issued: ${DateFormat.yMMMMd().add_jm().format(loaded!.issuedAt)}"),
          const SizedBox(height: 12),
          const Text("Medicines:",
              style: TextStyle(fontWeight: FontWeight.bold)),
          ...loaded!.medicines.map((m) => ListTile(
                title: Text("${m.name} — ${m.dose}"),
                subtitle:
                    Text("Times: ${m.times.join(', ')} • ${m.durationDays} days"),
              )),
        ],
      ),
    );
  }
}
