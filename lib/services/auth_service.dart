import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_constants.dart';

/// Authentication and user bootstrap helper for doctor/patient roles.
class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> registerDoctor({
    required String name,
    required String email,
    required String password,
    required String specialization,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _db.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'email': email,
      'role': 'doctor',
      'specialization': specialization,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Registers a patient user and creates baseline profile documents.
  Future<void> registerPatient({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = cred.user!.uid;
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'role': AppConstants.rolePatient,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _db.collection('patients').doc(uid).set({
      'patientId': uid,
      'name': name,
      'email': email,
      'age': 0,
      'gender': '',
      'phone': '',
      'address': '',
      'medicalHistory': '',
      'assignedDoctorId': '',
      'bloodGroup': '',
      'allergies': '',
      'chronicDiseases': '',
      'emergencyContact': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Signs out current user and clears persisted role selection.
  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userRoleKey);
  }
}
