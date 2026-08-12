class ClientDocument {
  final String id;
  final String clientId;

  final String clientName;
  final String documentName;
  final String storagePath;
  final String ogCopy;
  final String remarks;
  final String verificationStatus;
  final String rejectionReason;
  final DateTime createdAt;

  ClientDocument({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.documentName,
    required this.storagePath,
    required this.ogCopy,
    required this.remarks,
    required this.verificationStatus,
    required this.rejectionReason,
    required this.createdAt,
  });

  factory ClientDocument.fromMap(Map<String, dynamic> map) {
    return ClientDocument(
      id: map['id'] ?? '',
      clientId: map['client_id'] ?? '',
      clientName: map['client_name'] ?? 'Unknown',
      documentName: map['document_name'] ?? '',
      storagePath: map['storage_path'] ?? '',
      ogCopy: map['og_copy'] ?? 'Copy',
      remarks: map['remarks'] ?? 'File OK',
      verificationStatus: map['verification_status'] ?? 'Under Verification',
      rejectionReason: map['rejection_reason'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at']).toLocal()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'client_id': clientId,
      'client_name': clientName,
      'document_name': documentName,
      'storage_path': storagePath,
      'og_copy': ogCopy,
      'remarks': remarks,
      'verification_status': verificationStatus,
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
