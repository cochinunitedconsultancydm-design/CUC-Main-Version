class ClientLicense {
  final int? id;
  final int? clientId;
  final int? licenseTypeId;
  final DateTime? serviceDate;
  final DateTime? expiryDate;
  final String? fileNo;
  final String? notes;
  final String? manualClientName;
  final String? status;

  // Joined fields
  final String? clientName;
  final String? licenseTypeName;

  ClientLicense({
    this.id,
    this.clientId,
    this.licenseTypeId,
    this.serviceDate,
    this.expiryDate,
    this.fileNo,
    this.notes,
    this.manualClientName,
    this.status,
    this.clientName,
    this.licenseTypeName,
  });

  factory ClientLicense.fromMap(Map<String, dynamic> map) {
    return ClientLicense(
      id: map['id'],
      clientId: map['client_id'],
      licenseTypeId: map['license_type_id'],
      serviceDate: map['service_date'] != null
          ? DateTime.tryParse(map['service_date'].toString())
          : null,
      expiryDate: map['expiry_date'] != null
          ? DateTime.tryParse(map['expiry_date'].toString())
          : null,
      fileNo: map['file_no'],
      notes: map['notes'],
      manualClientName: map['manual_client_name'],
      status: map['status'],
      clientName: map['client_name'],
      licenseTypeName: map['license_type_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'client_id': clientId,
      'license_type_id': licenseTypeId,
      'service_date': serviceDate?.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'file_no': fileNo,
      'notes': notes,
      'manual_client_name': manualClientName,
      'status': status,
    };
  }
}
