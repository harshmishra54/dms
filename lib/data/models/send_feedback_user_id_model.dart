class SendFeedbackUserIdModel {
  final String userId;
  final String? message;

  SendFeedbackUserIdModel({
    required this.userId,
    this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "message": message,
    };
  }
}
class FeedbackScheduleResponseModel {
  final int success;
  final String message;

  FeedbackScheduleResponseModel({
    required this.success,
    required this.message,
  });

  factory FeedbackScheduleResponseModel.fromJson(Map<String, dynamic> json) {
    return FeedbackScheduleResponseModel(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}
