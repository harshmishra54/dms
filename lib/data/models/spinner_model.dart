class SpinnerRewardRequest {
  final String id;

  SpinnerRewardRequest({required this.id});

  Map<String, dynamic> toJson() {
    return {
      "id": id,
    };
  }
}
class SpinnerRewardResponse {
  final int success;
  final String message;
  final int points;

  SpinnerRewardResponse({
    required this.success,
    required this.message,
    required this.points,
  });

  factory SpinnerRewardResponse.fromJson(Map<String, dynamic> json) {
    return SpinnerRewardResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      points: json['points'] ?? 0,
    );
  }
}
