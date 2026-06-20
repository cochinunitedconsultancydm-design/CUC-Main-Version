class LicenseService {
  final int id;
  final int clientLicenseId;
  final double cost;
  final DateTime? date;
  final String description;

  LicenseService({
    required this.id,
    required this.clientLicenseId,
    required this.cost,
    this.date,
    required this.description,
  });

  factory LicenseService.fromMap(Map<String, dynamic> map) {
    return LicenseService(
      id: map['id'],
      clientLicenseId: map['client_license_id'],
      cost: double.tryParse(map['service_cost']?.toString() ?? '0') ?? 0.0,
      date: map['service_date'] != null ? DateTime.tryParse(map['service_date'].toString()) : null,
      description: map['service_description'] ?? '',
    );
  }
}
