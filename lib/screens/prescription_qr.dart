import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/prescription.dart';

class PrescriptionQrScreen extends StatelessWidget {
  final Prescription prescription;

  const PrescriptionQrScreen({
    super.key,
    required this.prescription,
  });

  Future<void> _savePrescription() async {
    await FirebaseFirestore.instance
        .collection('prescriptions')
        .doc(prescription.id)
        .set(prescription.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prescription QR')),
      body: FutureBuilder(
        future: _savePrescription(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Scan this QR at pharmacy / patient app',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                QrImageView(
                  data: prescription.id,
                  size: 220,
                ),

                const SizedBox(height: 20),

                Text('Prescription ID: ${prescription.id}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
