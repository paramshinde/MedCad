import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/login_screen.dart';
import 'doctor_dashboard.dart';
import 'patient_dashboard.dart';

enum _SplashTarget { login, doctor, patient }

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final Future<_SplashTarget> _targetFuture;

  @override
  void initState() {
    super.initState();
    _targetFuture = _resolveTarget();
  }

  Future<_SplashTarget> _resolveTarget() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return _SplashTarget.login;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final role = userDoc.data()?['role'] as String?;
      if (role == 'doctor') {
        return _SplashTarget.doctor;
      }
      return _SplashTarget.patient;
    } catch (_) {
      return _SplashTarget.login;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_SplashTarget>(
      future: _targetFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return switch (snapshot.data!) {
          _SplashTarget.login => const LoginScreen(),
          _SplashTarget.doctor => const DoctorDashboard(),
          _SplashTarget.patient => const PatientDashboard(),
        };
      },
    );
  }
}
