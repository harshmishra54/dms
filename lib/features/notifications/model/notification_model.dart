// lib/features/notifications/model/notification_model.dart

class AppNotification {
  final String id;
  final String consumerId;
  final String title;
  final String message;
  final int type;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppNotification({
    required this.id,
    required this.consumerId,
    required this.title,
    required this.message,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      consumerId: json['consumer_id'] ?? '',
      title: json['title'] ?? '',
      message: json['desc'] ?? '', // <-- desc is your "message"
      type: json['type'] ?? 0,
      status: json['status'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
  DateTime get timestamp => createdAt;
}

class NotificationResponse {
  final int success;
  final List<AppNotification> notifications;

  NotificationResponse({
    required this.success,
    required this.notifications,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List? ?? [];
    return NotificationResponse(
      success: json['success'] ?? 0,
      notifications:
      list.map((item) => AppNotification.fromJson(item)).toList(),
    );
  }
}
