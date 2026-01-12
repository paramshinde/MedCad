class Medicine {
  final String id;
  final String name;
  final String manufacturer;
  final String saltComposition;

  Medicine({
    required this.id,
    required this.name,
    required this.manufacturer,
    required this.saltComposition,
  });

  factory Medicine.fromFirestore(String id, Map<String, dynamic> data) {
    return Medicine(
      id: id,
      name: data['name'] ?? '',
      manufacturer: data['manufacturer'] ?? '',
      saltComposition: data['salt_composition'] ?? '',
    );
  }
}
