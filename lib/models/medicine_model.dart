class MedicineModel {
  final String id;
  final String name;
  final String? manufacturer;
  final double? price;
  final List<String>? aliases;

  MedicineModel({
    required this.id,
    required this.name,
    this.manufacturer,
    this.price,
    this.aliases,
  });

  factory MedicineModel.fromMap(Map<String, dynamic> data, String id) {
    return MedicineModel(
      id: id,
      name: data['name'] ?? '',
      manufacturer: data['manufacturer'],
      price: data['price'] != null ? (data['price'] as num).toDouble() : null,
      aliases: (data['aliases'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }
}
