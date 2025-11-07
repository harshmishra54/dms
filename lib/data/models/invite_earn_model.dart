// Request model
class InviteEarnRequest {
  final String userId;

  InviteEarnRequest({required this.userId});

  Map<String, dynamic> toJson() {
    return {
      'id': userId, // matches your request example
    };
  }
}

// Response model
class InviteEarnResponse {
  final int success;
  final String message;
  final String referralCode;

  InviteEarnResponse({
    required this.success,
    required this.message,
    required this.referralCode,
  });

  factory InviteEarnResponse.fromJson(Map<String, dynamic> json) {
    return InviteEarnResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      referralCode: json['refferal_code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'refferal_code': referralCode,
    };
  }
}
