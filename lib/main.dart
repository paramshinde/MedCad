import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth/login_screen.dart';
import 'auth/register_doctor.dart';
import 'firebase_options.dart';
import 'screens/doctor/analytics_dashboard.dart';
import 'screens/doctor/doctor_patient_list.dart';
import 'screens/doctor_create.dart';
import 'screens/doctor_dashboard.dart';
import 'screens/doctor_med_search.dart';
import 'screens/doctor_search.dart';
import 'screens/patient/emergency_card.dart';
import 'screens/patient/patient_dashboard.dart';
import 'screens/patient/prescription_history.dart';
import 'screens/patient/saved_medicines_screen.dart';
import 'screens/patient/scan_qr.dart';
import 'screens/patient_create.dart';
import 'screens/patient_scan.dart';
import 'screens/patient_search.dart';
import 'screens/role/role_selection.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'utils/app_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable offline persistence for Firestore cache-first behavior.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  // Initialize local notifications for medicine reminders.
  await NotificationService.init();

  runApp(const MedCodeApp());
}

/// Root widget configuring app theme and route table.
class MedCodeApp extends StatelessWidget {
  const MedCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0891B2),
        brightness: Brightness.light,
      ),
      fontFamily: 'Poppins',
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        scaffoldBackgroundColor: const Color(0xFFF3F8FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F172A),
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD8E3EA)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD8E3EA)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF0891B2), width: 1.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            backgroundColor: const Color(0xFF0891B2),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(0, 48),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const _StartupGate(),
        '/role': (context) => const RoleSelectionScreen(),
        '/login': (context) => const LoginScreen(),
        '/register-doctor': (context) => const RegisterDoctorScreen(),
        '/doctorDashboard': (context) => const DoctorDashboard(),
        '/doctor-dashboard': (context) => const DoctorDashboard(),
        '/doctor-create': (context) => const DoctorCreateScreen(),
        '/doctor-search': (context) => const DoctorSearchScreen(),
        '/doctor-med-search': (context) => const DoctorMedSearchScreen(),
        '/doctor-patients': (context) => const DoctorPatientListScreen(),
        '/analytics': (context) => const AnalyticsDashboardScreen(),
        '/patientDashboard': (context) => const PatientDashboardScreen(),
        '/patient-dashboard': (context) => const PatientDashboardScreen(),
        '/patient-create': (context) => const PatientCreateScreen(),
        '/patient-search': (context) => const PatientSearchScreen(),
        '/patient-scan': (context) => const PatientScanScreen(),
        '/scanQR': (context) => const ScanQrScreen(),
        '/savedMedicines': (context) => const SavedMedicinesScreen(),
        '/patient-history': (context) => const PrescriptionHistoryScreen(),
        '/emergencyCard': (context) => const EmergencyCardScreen(),
        '/splash': (context) => const SplashScreen(),
      },
    );
  }
}

/// Startup gate that decides first screen based on first-launch role selection.
class _StartupGate extends StatefulWidget {
  const _StartupGate();

  @override
  State<_StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<_StartupGate> {
  Future<String?> _getSavedRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.userRoleKey);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getSavedRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data;
        if (role == null) {
          return const RoleSelectionScreen();
        }
        if (role == AppConstants.roleDoctor) {
          return const DoctorDashboard();
        }
        return const PatientDashboardScreen();
      },
    );
  }
}
