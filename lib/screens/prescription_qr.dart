import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/prescription.dart';

class PrescriptionQrScreen extends StatelessWidget {
  final Prescription prescription;

  const PrescriptionQrScreen({
    super.key,
    required this.prescription,
  });

  Future<void> _savePrescription() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    await FirebaseFirestore.instance
        .collection('prescriptions')
        .doc(prescription.id)
        .set({
      ...prescription.toMap(),
      'doctorId': uid,
      'patientName': prescription.patientId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prescription QR')),
      body: FutureBuilder<void>(
        future: _savePrescription(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Failed to save prescription.'),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PrescriptionQrScreen(
                            prescription: prescription,
                          ),
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
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
                QrImageView(data: prescription.id, size: 220),
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
