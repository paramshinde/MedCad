import 'package:cloud_firestore/cloud_firestore.dart';

/// Patient domain model used by patient and doctor modules.
class PatientModel {
  final String patientId;
  final String name;
  final int age;
  final String gender;
  final String phone;
  final String email;
  final String address;
  final String medicalHistory;
  final String assignedDoctorId;
  final String bloodGroup;
  final String allergies;
  final String chronicDiseases;
  final String emergencyContact;
  final Timestamp createdAt;

  const PatientModel({
    required this.patientId,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.email,
    required this.address,
    required this.medicalHistory,
    this.assignedDoctorId = '',
    this.bloodGroup = '',
    this.allergies = '',
    this.chronicDiseases = '',
    this.emergencyContact = '',
    required this.createdAt,
  });

  /// Creates a typed patient model from a Firestore map.
  factory PatientModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return PatientModel(
      patientId: (map['patientId'] as String?) ?? id ?? '',
      name: (map['name'] as String?) ?? '',
      age: (map['age'] as num?)?.toInt() ?? 0,
      gender: (map['gender'] as String?) ?? '',
      phone: (map['phone'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      address: (map['address'] as String?) ?? '',
      medicalHistory: (map['medicalHistory'] as String?) ?? '',
      assignedDoctorId: (map['assignedDoctorId'] as String?) ?? '',
      bloodGroup: (map['bloodGroup'] as String?) ?? '',
      allergies: (map['allergies'] as String?) ?? '',
      chronicDiseases: (map['chronicDiseases'] as String?) ?? '',
      emergencyContact: (map['emergencyContact'] as String?) ?? '',
      createdAt: (map['createdAt'] as Timestamp?) ?? Timestamp.now(),
    );
  }

  /// Converts this patient model into a Firestore map payload.
  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'name': name,
      'age': age,
      'gender': gender,
      'phone': phone,
      'email': email,
      'address': address,
      'medicalHistory': medicalHistory,
      'assignedDoctorId': assignedDoctorId,
      'bloodGroup': bloodGroup,
      'allergies': allergies,
      'chronicDiseases': chronicDiseases,
      'emergencyContact': emergencyContact,
      'createdAt': createdAt,
    };
  }
}
