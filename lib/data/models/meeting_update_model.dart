class UpdateMeetingStatusRequest {
  final String userId;
  final String id;
  final bool successfull;

  UpdateMeetingStatusRequest({
    required this.userId,
    required this.id,
    required this.successfull,
  });

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "id": id,
      "successfull": successfull, // ✅ boolean only
    };
  }
}
class UpdateMeetingStatusResponse {
  final int success;
  final String message;

  UpdateMeetingStatusResponse({
    required this.success,
    required this.message,
  });

  factory UpdateMeetingStatusResponse.fromJson(
      Map<String, dynamic> json) {
    return UpdateMeetingStatusResponse(
      success: json["success"],
      message: json["message"],
    );
  }
}
