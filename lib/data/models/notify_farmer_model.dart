// models/notification_request.dart
class NotificationRequest {
  List<String> ids;
  String message;
  String title;

  NotificationRequest({
    required this.ids,
    required this.message,
    required this.title,
  });

  Map<String, dynamic> toJson() {
    return {
      'ids': ids,
      'message': message,
      'title': title,
    };
  }
}
// models/notification_response.dart
class NotificationResponse {
  int success;
  String message;

  NotificationResponse({
    required this.success,
    required this.message,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      success: json['success'],
      message: json['message'],
    );
  }
}
