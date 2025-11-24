// lib/models/prescription.dart
import 'dart:convert';

class Medicine {
  String name;
  String dose;
  List<String> times; // format "08:00"
  int durationDays;
  String notes;
  String? rxcui; // <-- new optional RxNorm identifier

  Medicine({
    required this.name,
    required this.dose,
    required this.times,
    required this.durationDays,
    this.notes = '',
    this.rxcui,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
        name: json['name'] ?? '',
        dose: json['dose'] ?? '',
        times: List<String>.from(json['times'] ?? []),
        durationDays: json['duration_days'] ?? 0,
        notes: json['notes'] ?? '',
        rxcui: json['rxcui'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'dose': dose,
        'times': times,
        'duration_days': durationDays,
        'notes': notes,
        if (rxcui != null) 'rxcui': rxcui,
      };
}


class Prescription {
  String id;
  Map<String, dynamic> doctor;
  Map<String, dynamic> patient;
  DateTime issuedAt;
  List<Medicine> medicines;
  String notes;

  Prescription({
    required this.id,
    required this.doctor,
    required this.patient,
    required this.issuedAt,
    required this.medicines,
    this.notes = '',
  });

  factory Prescription.fromJson(Map<String, dynamic> json) => Prescription(
        id: json['id'] ?? '',
        doctor: Map<String, dynamic>.from(json['doctor'] ?? {}),
        patient: Map<String, dynamic>.from(json['patient'] ?? {}),
        issuedAt: DateTime.parse(json['issued_at'] ?? DateTime.now().toIso8601String()),
        medicines: (json['medicines'] as List<dynamic>? ?? [])
            .map((m) => Medicine.fromJson(Map<String, dynamic>.from(m)))
            .toList(),
        notes: json['notes'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'doctor': doctor,
        'patient': patient,
        'issued_at': issuedAt.toIso8601String(),
        'medicines': medicines.map((m) => m.toJson()).toList(),
        'notes': notes,
      };

  String toJsonString() => jsonEncode(toJson());

  static Prescription fromJsonString(String s) =>
      Prescription.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
