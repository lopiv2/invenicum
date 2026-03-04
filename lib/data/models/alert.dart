// lib/models/alert.dart

class Alert {
  final int id;
  final String title;
  final String message;
  final String type; // 'info', 'warning', 'critical'
  final DateTime createdAt;
  bool isRead;
  final bool isEvent;
  final DateTime? scheduledAt;
  final DateTime? notifyAt;

  Alert({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.isEvent = false,
    this.scheduledAt,
    this.notifyAt,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'] as int,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String? ?? 'info',
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      isEvent: json['isEvent'] as bool? ?? false,
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'] as String)
          : null,
      notifyAt: json['notifyAt'] != null
          ? DateTime.parse(json['notifyAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'isEvent': isEvent,
      'scheduledAt': scheduledAt?.toIso8601String(),
      'notifyAt': notifyAt?.toIso8601String(),
    };
  }
}
