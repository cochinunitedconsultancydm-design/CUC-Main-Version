class DealActivity {
  final dynamic id;
  final dynamic dealId;
  final String type; // 'call', 'meeting', 'email', 'task', 'comment'
  final String? title;
  final String? description;
  final DateTime? dueDate;
  final bool isCompleted;
  final dynamic createdBy;
  final DateTime? createdAt;
  final String? creatorName;

  DealActivity({
    this.id,
    required this.dealId,
    required this.type,
    this.title,
    this.description,
    this.dueDate,
    this.isCompleted = false,
    this.createdBy,
    this.createdAt,
    this.creatorName,
  });

  factory DealActivity.fromMap(Map<String, dynamic> map) {
    return DealActivity(
      id: map['id'],
      dealId: map['deal_id'],
      type: map['type'] ?? 'comment',
      title: map['title'],
      description: map['description'],
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date'].toString()) : null,
      isCompleted: map['is_completed'] ?? false,
      createdBy: map['created_by'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'].toString()) : null,
      creatorName: map['creator_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deal_id': dealId,
      'type': type,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'is_completed': isCompleted,
      'created_by': createdBy,
    };
  }
}
