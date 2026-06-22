class Checklist {
  final dynamic id;
  final String title;
  final String? description;
  final int? managerId;
  final int? responsibleId;
  final String status; // Pending, Completed, Not Completed, Postponed
  final String? remarks;
  final String? reason;
  final String? dueDate;
  final String? createdAt;
  final String? updatedAt;

  // Joined fields
  final String? managerName;
  final String? responsibleName;

  // Connected Work
  final dynamic dealId;
  final String? dealName;

  Checklist({
    this.id,
    required this.title,
    this.description,
    this.managerId,
    this.responsibleId,
    this.status = 'Pending',
    this.remarks,
    this.reason,
    this.dueDate,
    this.createdAt,
    this.updatedAt,
    this.managerName,
    this.responsibleName,
    this.dealId,
    this.dealName,
  });

  factory Checklist.fromMap(Map<String, dynamic> map) {
    final rawDesc = map['description'] as String? ?? '';
    dynamic parsedDealId;
    String? parsedDealName;
    String cleanDesc = rawDesc;

    final regExp = RegExp(
      r'\[CONNECTED_WORK\]\s*\n\s*DealId:\s*(\d+)\s*\n\s*DealName:\s*(.*?)$',
      multiLine: true,
      caseSensitive: false,
    );

    final match = regExp.firstMatch(rawDesc);
    if (match != null) {
      parsedDealId = match.group(1);
      parsedDealName = match.group(2)?.trim();
      final index = rawDesc.indexOf('[CONNECTED_WORK]');
      if (index != -1) {
        cleanDesc = rawDesc.substring(0, index).trim();
      }
    }

    return Checklist(
      id: map['id'],
      title: map['title'],
      description: cleanDesc,
      managerId: map['manager_id'],
      responsibleId: map['responsible_id'],
      status: map['status'] ?? 'Pending',
      remarks: map['remarks'],
      reason: map['reason'],
      dueDate: map['due_date']?.toString(),
      createdAt: map['created_at']?.toString(),
      updatedAt: map['updated_at']?.toString(),
      managerName: map['manager_name'],
      responsibleName: map['responsible_name'],
      dealId: parsedDealId,
      dealName: parsedDealName,
    );
  }

  Map<String, dynamic> toMap() {
    String finalDesc = description ?? '';
    if (dealId != null && dealName != null) {
      final index = finalDesc.indexOf('[CONNECTED_WORK]');
      if (index != -1) {
        finalDesc = finalDesc.substring(0, index).trim();
      }
      finalDesc = "$finalDesc\n\n[CONNECTED_WORK]\nDealId: $dealId\nDealName: $dealName";
    }

    return {
      if (id != null) 'id': id,
      'title': title,
      'description': finalDesc,
      'manager_id': managerId,
      'responsible_id': responsibleId,
      'status': status,
      'remarks': remarks,
      'reason': reason,
      'due_date': dueDate,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
