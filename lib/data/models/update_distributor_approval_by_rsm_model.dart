// request model
class UpdateDistributorStatusRequest {
  final String id;
  final bool status;

  UpdateDistributorStatusRequest({
    required this.id,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
    };
  }
}

// response model
class UpdateDistributorStatusResponse {
  final int success;
  final String message;

  UpdateDistributorStatusResponse({
    required this.success,
    required this.message,
  });

  factory UpdateDistributorStatusResponse.fromJson(Map<String, dynamic> json) {
    return UpdateDistributorStatusResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}
