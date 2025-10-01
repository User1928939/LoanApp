
class Notification {
  final int id;
  final int loanId;
  final String type; // Backend uses string
  final DateTime scheduledAt;
  final DateTime? sentAt;
  final Map<String, dynamic> payload;

  Notification({
    required this.id,
    required this.loanId,
    required this.type,
    required this.scheduledAt,
    this.sentAt,
    required this.payload,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      loanId: json['loan_id'],
      type: json['type'],
      scheduledAt: DateTime.parse(json['scheduled_at']),
      sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at']) : null,
      payload: json['payload'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loan_id': loanId,
      'type': type,
      'scheduled_at': scheduledAt.toIso8601String(),
      'sent_at': sentAt?.toIso8601String(),
      'payload': payload,
    };
  }
}
