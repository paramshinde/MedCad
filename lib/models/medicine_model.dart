/// Unified medicine model used by search, detail preview, and prescription flows.
class Medicine {
  final String id;
  final String name;
  final String genericName;
  final String brandName;
  final String strength;
  final String dosageForm;
  final String manufacturer;
  final String saltComposition;
  final String indications;
  final List<String> sideEffects;
  final String warnings;
  final String contraindications;

  const Medicine({
    required this.id,
    required this.name,
    required this.genericName,
    required this.brandName,
    required this.strength,
    required this.dosageForm,
    required this.manufacturer,
    required this.saltComposition,
    required this.indications,
    required this.sideEffects,
    required this.warnings,
    required this.contraindications,
  });

  /// Maps a medicine Firestore document into the app model.
  factory Medicine.fromFirestore(String id, Map<String, dynamic> data) {
    final name = (data['name'] as String?) ?? '';
    final salt = (data['salt_composition'] as String?) ?? '';
    final shortComp = (data['short_composition'] as String?) ?? '';
    final sideEffectsRaw = (data['side_effects'] as List<dynamic>?) ?? const [];
    final warningsRaw =
        (data['warnings'] as String?) ?? (data['drug_interactions'] as String?) ?? '';

    return Medicine(
      id: id,
      name: name,
      genericName: shortComp.isNotEmpty ? shortComp : 'Not available',
      brandName: name.isNotEmpty ? name : 'Not available',
      strength: salt.isNotEmpty ? salt : 'Not available',
      dosageForm: (data['type'] as String?)?.trim().isNotEmpty == true
          ? (data['type'] as String)
          : 'Not available',
      manufacturer: (data['manufacturer'] as String?) ?? 'Not available',
      saltComposition: salt,
      indications: (data['indications'] as String?) ?? 'Not available',
      sideEffects: sideEffectsRaw.map((e) => e.toString()).toList(growable: false),
      warnings: warningsRaw.isNotEmpty ? warningsRaw : 'Not available',
      contraindications:
          (data['contraindications'] as String?) ?? 'Not available',
    );
  }

  /// Builds a copy with selective field overrides.
  Medicine copyWith({
    String? genericName,
    String? brandName,
    String? strength,
    String? dosageForm,
    String? manufacturer,
    String? indications,
    List<String>? sideEffects,
    String? warnings,
    String? contraindications,
  }) {
    return Medicine(
      id: id,
      name: name,
      genericName: genericName ?? this.genericName,
      brandName: brandName ?? this.brandName,
      strength: strength ?? this.strength,
      dosageForm: dosageForm ?? this.dosageForm,
      manufacturer: manufacturer ?? this.manufacturer,
      saltComposition: saltComposition,
      indications: indications ?? this.indications,
      sideEffects: sideEffects ?? this.sideEffects,
      warnings: warnings ?? this.warnings,
      contraindications: contraindications ?? this.contraindications,
    );
  }
}
