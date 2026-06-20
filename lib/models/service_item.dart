class ServiceItem {
  final int id;
  final int? serviceId;
  final String title;
  final String? description;
  final String? imagePath;
  final Map<String, dynamic>? details;

  ServiceItem({
    required this.id,
    this.serviceId,
    required this.title,
    this.description,
    this.imagePath,
    this.details,
  });

  factory ServiceItem.fromMap(Map<String, dynamic> map) {
    return ServiceItem(
      id: map['id'] ?? 0,
      serviceId: map['service_id'],
      title: map['title'] ?? 'Untitled Service',
      description: map['description'],
      imagePath: map['image_path'],
      details: map['details'],
    );
  }
}
