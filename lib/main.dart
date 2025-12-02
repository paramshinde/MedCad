// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/doctor_create.dart';
import 'screens/patient_scan.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase first
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, st) {
    
    debugPrint('Firebase initialization error: $e\n$st');
  }

 
  try {
    await NotificationService.init();
  } catch (e, st) {
    debugPrint('NotificationService.init() error: $e\n$st');
  }

  runApp(const MedCodeApp());
}

class MedCodeApp extends StatelessWidget {
  const MedCodeApp({super.key});

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
  const HomeScreen({super.key});

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
            const Text(""),
          ],
        ),
      ),
    );
  }
}
