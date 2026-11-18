import 'dart:convert';

enum PostStatus { pendingConfirmation, confirmedReceived }

class InwardPost {
  final String id;
  final String senderName;
  final String recipientName;
  final String receivedBy;
  final DateTime receivedDate;
  PostStatus status;
  final String description;

  // Extended fields for Outward / Sent Letters & Acknowledgements:
  final String postType; // 'inward' (received) or 'outward' (sent)
  final String? workfileId; // Deal ID
  final String? workfileName; // Deal name / title
  final String? workfileNumber; // Deal file/register number
  final String? letterStoragePath; // Storage S3 path for sent letter
  final String? letterFileName; // File name of sent letter
  final bool hasAcknowledgement; // Toggle: requires acknowledgement
  final String ackStatus; // 'none', 'pending', 'received'
  final String? ackStoragePath; // Storage S3 path for acknowledgement
  final String? ackFileName; // File name of acknowledgement
  final DateTime? ackReceivedDate; // Timestamp when acknowledgement was received

  InwardPost({
    required this.id,
    required this.senderName,
    required this.recipientName,
    required this.receivedBy,
    required this.receivedDate,
    required this.status,
    required this.description,
    this.postType = 'inward',
    this.workfileId,
    this.workfileName,
    this.workfileNumber,
    this.letterStoragePath,
    this.letterFileName,
    this.hasAcknowledgement = false,
    this.ackStatus = 'none',
    this.ackStoragePath,
    this.ackFileName,
    this.ackReceivedDate,
  });

  bool get isSentLetter => postType == 'outward' || postType == 'sent';
  bool get isAwaitingAck => hasAcknowledgement && ackStatus == 'pending';
  bool get isAckReceived => hasAcknowledgement && ackStatus == 'received';

  /// Serializes description + extended metadata into a single string for storage
  String toStoredDescription() {
    final map = <String, dynamic>{
      'text': description,
      'post_type': postType,
      'workfile_id': workfileId,
      'workfile_name': workfileName,
      'workfile_number': workfileNumber,
      'letter_storage_path': letterStoragePath,
      'letter_file_name': letterFileName,
      'has_ack': hasAcknowledgement,
      'ack_status': ackStatus,
      'ack_storage_path': ackStoragePath,
      'ack_file_name': ackFileName,
      'ack_date': ackReceivedDate?.toIso8601String(),
    };
    return json.encode(map);
  }

  /// Recreates InwardPost from raw DB description + base model fields
  static InwardPost fromDb({
    required String id,
    required String senderName,
    required String recipientName,
    required String receivedBy,
    required DateTime receivedDate,
    required PostStatus status,
    required String? rawDescription,
  }) {
    String descText = rawDescription ?? '';
    String postType = 'inward';
    String? workfileId;
    String? workfileName;
    String? workfileNumber;
    String? letterStoragePath;
    String? letterFileName;
    bool hasAck = false;
    String ackStatus = 'none';
    String? ackStoragePath;
    String? ackFileName;
    DateTime? ackReceivedDate;

    if (descText.startsWith('{') && descText.endsWith('}')) {
      try {
        final map = json.decode(descText) as Map<String, dynamic>;
        descText = map['text']?.toString() ?? '';
        postType = map['post_type']?.toString() ?? 'inward';
        workfileId = map['workfile_id']?.toString();
        workfileName = map['workfile_name']?.toString();
        workfileNumber = map['workfile_number']?.toString();
        letterStoragePath = map['letter_storage_path']?.toString();
        letterFileName = map['letter_file_name']?.toString();
        hasAck = map['has_ack'] == true;
        ackStatus = map['ack_status']?.toString() ?? (hasAck ? 'pending' : 'none');
        ackStoragePath = map['ack_storage_path']?.toString();
        ackFileName = map['ack_file_name']?.toString();
        if (map['ack_date'] != null) {
          ackReceivedDate = DateTime.tryParse(map['ack_date'].toString());
        }
      } catch (_) {
        // Fallback to plain string
      }
    }

    return InwardPost(
      id: id,
      senderName: senderName,
      recipientName: recipientName,
      receivedBy: receivedBy,
      receivedDate: receivedDate,
      status: status,
      description: descText,
      postType: postType,
      workfileId: workfileId,
      workfileName: workfileName,
      workfileNumber: workfileNumber,
      letterStoragePath: letterStoragePath,
      letterFileName: letterFileName,
      hasAcknowledgement: hasAck,
      ackStatus: ackStatus,
      ackStoragePath: ackStoragePath,
      ackFileName: ackFileName,
      ackReceivedDate: ackReceivedDate,
    );
  }

  InwardPost copyWith({
    String? senderName,
    String? recipientName,
    String? receivedBy,
    DateTime? receivedDate,
    PostStatus? status,
    String? description,
    String? postType,
    String? workfileId,
    String? workfileName,
    String? workfileNumber,
    String? letterStoragePath,
    String? letterFileName,
    bool? hasAcknowledgement,
    String? ackStatus,
    String? ackStoragePath,
    String? ackFileName,
    DateTime? ackReceivedDate,
  }) {
    return InwardPost(
      id: id,
      senderName: senderName ?? this.senderName,
      recipientName: recipientName ?? this.recipientName,
      receivedBy: receivedBy ?? this.receivedBy,
      receivedDate: receivedDate ?? this.receivedDate,
      status: status ?? this.status,
      description: description ?? this.description,
      postType: postType ?? this.postType,
      workfileId: workfileId ?? this.workfileId,
      workfileName: workfileName ?? this.workfileName,
      workfileNumber: workfileNumber ?? this.workfileNumber,
      letterStoragePath: letterStoragePath ?? this.letterStoragePath,
      letterFileName: letterFileName ?? this.letterFileName,
      hasAcknowledgement: hasAcknowledgement ?? this.hasAcknowledgement,
      ackStatus: ackStatus ?? this.ackStatus,
      ackStoragePath: ackStoragePath ?? this.ackStoragePath,
      ackFileName: ackFileName ?? this.ackFileName,
      ackReceivedDate: ackReceivedDate ?? this.ackReceivedDate,
    );
  }
}
