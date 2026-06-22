class CompanyBill {
  final dynamic id;
  final String category;
  final String title;
  final double amount;
  final DateTime billDate;
  final String status;
  final String? description;
  final dynamic spentBy;
  final String? spentByName;
  final DateTime? createdAt;

  CompanyBill({
    this.id,
    required this.category,
    required this.title,
    required this.amount,
    required this.billDate,
    this.status = 'Pending',
    this.description,
    this.spentBy,
    this.spentByName,
    this.createdAt,
  });

  factory CompanyBill.fromMap(Map<String, dynamic> map) {
    return CompanyBill(
      id: map['id'],
      category: map['category']?.toString() ?? 'Other',
      title: map['title']?.toString() ?? 'No Title',
      amount: double.tryParse(map['amount']?.toString() ?? '0') ?? 0.0,
      billDate: map['bill_date'] != null 
          ? DateTime.parse(map['bill_date'].toString()) 
          : DateTime.now(),
      status: map['status']?.toString() ?? 'Pending',
      description: map['description']?.toString(),
      spentBy: map['spent_by'],
      spentByName: map['spent_by_name']?.toString(),
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'category': category,
      'title': title,
      'amount': amount,
      'bill_date': billDate.toIso8601String().split('T')[0],
      'status': status,
      'description': description,
      'spent_by': spentBy,
      'spent_by_name': spentByName,
    };
  }
}
