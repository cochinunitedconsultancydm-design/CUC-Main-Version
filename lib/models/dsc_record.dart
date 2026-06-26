class DscRecord {
  final int? id;
  final String? clientName;
  final String? emailId;
  final String? phoneNo;
  final String? username;
  final String? password;
  final DateTime? dscTakenDate;
  final DateTime? dscExpiryDate;

  DscRecord({
    this.id,
    this.clientName,
    this.emailId,
    this.phoneNo,
    this.username,
    this.password,
    this.dscTakenDate,
    this.dscExpiryDate,
  });

  factory DscRecord.fromMap(Map<String, dynamic> map) {
    return DscRecord(
      id: map['id'],
      clientName: map['client_name'],
      emailId: map['email_id'],
      phoneNo: map['phone_no'],
      username: map['username'],
      password: map['password'],
      dscTakenDate: map['dsc_taken_date'] != null
          ? DateTime.tryParse(map['dsc_taken_date'].toString())
          : null,
      dscExpiryDate: map['dsc_expiry_date'] != null
          ? DateTime.tryParse(map['dsc_expiry_date'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'client_name': clientName,
      'email_id': emailId,
      'phone_no': phoneNo,
      'username': username,
      'password': password,
      'dsc_taken_date': dscTakenDate?.toIso8601String(),
      'dsc_expiry_date': dscExpiryDate?.toIso8601String(),
    };
  }
}
