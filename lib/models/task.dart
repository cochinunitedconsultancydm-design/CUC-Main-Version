class Task {
  final int? id;
  final String title;
  final String? description;
  final int? assignedBy;
  final int? assignedTo;
  final String status;
  final String? dueDate;
  final String? createdAt;
  final String? location;
  final String? clientName;
  final String? phoneNumber;
  final String? updatedAt;

  // Additional fields for joined queries
  final String? assignedByName;
  final String? assignedToName;

  Task({
    this.id,
    required this.title,
    this.description,
    this.assignedBy,
    this.assignedTo,
    this.status = 'Pending',
    this.dueDate,
    this.createdAt,
    this.location,
    this.clientName,
    this.phoneNumber,
    this.updatedAt,
    this.assignedByName,
    this.assignedToName,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      assignedBy: map['assigned_by'],
      assignedTo: map['assigned_to'],
      status: map['status'] ?? 'Pending',
      dueDate: map['due_date']?.toString(),
      createdAt: map['created_at']?.toString(),
      location: map['location'],
      clientName: map['client_name'],
      phoneNumber: map['phone_number'],
      updatedAt: map['updated_at']?.toString(),
      assignedByName: map['assigned_by_name'],
      assignedToName: map['assigned_to_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'assigned_by': assignedBy,
      'assigned_to': assignedTo,
      'status': status,
      'due_date': dueDate,
      'location': location,
      'client_name': clientName,
      'phone_number': phoneNumber,
      'updated_at': updatedAt,
    };
  }
}
