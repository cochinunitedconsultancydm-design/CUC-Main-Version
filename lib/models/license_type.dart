class LicenseType {
  final int id;
  final String name;
  final String? description;

  LicenseType({required this.id, required this.name, this.description});

  factory LicenseType.fromMap(Map<String, dynamic> map) {
    return LicenseType(
      id: map['id'],
      name: map['name'] ?? '',
      description: map['description'],
    );
  }
}
