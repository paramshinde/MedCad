// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/doctor_create.dart';
import 'screens/patient_scan.dart';
import 'services/notification_service.dart';
import 'package:flutter/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const MedCodeApp());
}

class MedCodeApp extends StatelessWidget {
  const MedCodeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedCode',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MedCode — Home')),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.medical_services),
              label: const Text('Doctor — Create Prescription'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorCreateScreen())),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Patient — Scan Prescription'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientScanScreen())),
            ),
            const SizedBox(height: 18),
            const Text('This is a starter app. Extend it with storage, auth, HMAC, and reminders.'),
          ],
        ),
      ),
    );
  }
}
