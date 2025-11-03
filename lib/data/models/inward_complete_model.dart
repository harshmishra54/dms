// request model
class SubmitPostData {
  final String? orderId;
  final String? userName;

  SubmitPostData({this.orderId, this.userName});

  Map<String, dynamic> toJson() {
    return {
      "orderId": orderId,
      "userName": userName,
    };
  }
}

// response model
class SubmitResponse {
  final int success;
  final String message;

  SubmitResponse({required this.success, required this.message});

  factory SubmitResponse.fromJson(Map<String, dynamic> json) {
    return SubmitResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}
