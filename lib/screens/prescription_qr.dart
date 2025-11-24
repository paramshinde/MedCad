import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/prescription.dart';

class PrescriptionQrScreen extends StatelessWidget {
  final Prescription prescription;
  const PrescriptionQrScreen({Key? key, required this.prescription}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final jsonString = prescription.toJsonString();

    return Scaffold(
      appBar: AppBar(title: const Text('Prescription QR')),
      body: Center(
        child: QrImageView(
          data: jsonString,
          version: QrVersions.auto,
          size: 300,
        ),
      ),
    );
  }
}
