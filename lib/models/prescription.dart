class Prescription {
  final String id;
  final String patientId;
  final List<PrescriptionMedicine> medicines;
  final String notes;

  Prescription({
    required this.id,
    required this.patientId,
    required this.medicines,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'notes': notes,
      'medicines': medicines.map((m) => m.toMap()).toList(),
    };
  }

  factory Prescription.fromMap(Map<String, dynamic> map) {
    return Prescription(
      id: map['id'],
      patientId: map['patientId'],
      notes: map['notes'] ?? '',
      medicines: (map['medicines'] as List)
          .map((m) => PrescriptionMedicine.fromMap(m))
          .toList(),
    );
  }
}

class PrescriptionMedicine {
  final String name;
  final String dose;
  final List<String> times;
  final int durationDays;

  PrescriptionMedicine({
    required this.name,
    required this.dose,
    required this.times,
    required this.durationDays,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dose': dose,
      'times': times,
      'durationDays': durationDays,
    };
  }

  factory PrescriptionMedicine.fromMap(Map<String, dynamic> map) {
    return PrescriptionMedicine(
      name: map['name'],
      dose: map['dose'],
      times: List<String>.from(map['times']),
      durationDays: map['durationDays'],
    );
  }
}
