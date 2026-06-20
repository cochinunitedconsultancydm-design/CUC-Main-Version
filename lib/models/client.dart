class Client {
  final int? id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? typeOfWork;
  final String? caseNumber;
  final String? dob;
  final String? fileNo;
  final String? fileDate;
  final bool isContacted;
  final String? managedBy;
  final int reviewRating;
  final String? balanceDue;

  Client({
    this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.typeOfWork,
    this.caseNumber,
    this.dob,
    this.fileNo,
    this.fileDate,
    this.isContacted = false,
    this.managedBy,
    this.reviewRating = 0,
    this.balanceDue,
  });

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'] ?? '',
      email: map['email'],
      phone: map['phone'],
      address: map['address'],
      typeOfWork: map['type_of_work'],
      caseNumber: map['case_number'],
      dob: map['dob'],
      fileNo: map['file_no'],
      fileDate: map['file_date'],
      isContacted: map['is_contacted'] ?? false,
      managedBy: map['managed_by'],
      reviewRating: map['review_rating'] ?? 0,
      balanceDue: map['balance_due'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'type_of_work': typeOfWork,
      'case_number': caseNumber,
      'dob': dob,
      'file_no': fileNo,
      'file_date': fileDate,
      'is_contacted': isContacted,
      'managed_by': managedBy,
      'review_rating': reviewRating,
      'balance_due': balanceDue,
    };
  }
}
