import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

// Auth
import 'auth/login_screen.dart';
import 'auth/register_doctor.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/doctor_dashboard.dart';
import 'screens/doctor_create.dart';
import 'screens/doctor_search.dart';
import 'screens/doctor_med_search.dart';
import 'screens/patient_dashboard.dart';
import 'screens/patient_scan.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MedCodeApp());
}

class MedCodeApp extends StatelessWidget {
  const MedCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedCode',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      initialRoute: '/',

      routes: {
        // Core
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register-doctor': (context) => const RegisterDoctorScreen(),

        // Doctor
        '/doctor-dashboard': (context) => const DoctorDashboard(),
        '/doctor-create': (context) => DoctorCreateScreen(),
        '/doctor-search': (context) => DoctorSearchScreen(),
        '/doctor-med-search': (context) => DoctorMedSearchScreen(),

        // Patient
        '/patient-dashboard': (context) => const PatientDashboard(),
        '/patient-scan': (context) => PatientScanScreen(),
      },
    );
  }
}
