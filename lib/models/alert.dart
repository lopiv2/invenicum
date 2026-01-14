// lib/models/alert.dart

class Alert {
  final int id;
  final String title;
  final String message;
  final String type; // 'info', 'warning', 'critical'
  final DateTime createdAt;
  bool isRead;

  Alert({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'] as int,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String? ?? 'info',
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
    };
  }
}