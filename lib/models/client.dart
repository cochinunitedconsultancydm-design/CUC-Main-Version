class Client {
  final dynamic id;
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
  final List<String>? companies;
  final String? registrationNumber;
  final String? createdBy;
  final String? bankAccountDetails;
  final List<String>? customFields;

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
    this.companies,
    this.registrationNumber,
    this.createdBy,
    this.bankAccountDetails,
    this.customFields,
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
      registrationNumber: map['registration_number'],
      bankAccountDetails: map['bank_account_details'],
      customFields: (map['custom_fields'] as List?)?.map((e) => e.toString()).toList(),
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
      'registration_number': registrationNumber,
      'bank_account_details': bankAccountDetails,
      'custom_fields': customFields,
    };
  }
}
