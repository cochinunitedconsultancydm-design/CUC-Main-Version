enum PostStatus { pendingConfirmation, confirmedReceived }

class InwardPost {
  final String id;
  final String senderName;
  final String recipientName;
  final String receivedBy;
  final DateTime receivedDate;
  PostStatus status;
  final String description;

  InwardPost({
    required this.id,
    required this.senderName,
    required this.recipientName,
    required this.receivedBy,
    required this.receivedDate,
    required this.status,
    required this.description,
  });
}
