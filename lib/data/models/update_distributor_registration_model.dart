// update_retail_rsm_model.dart

// Request Model
class UpdateRetailerStatusRequest {
  final String id;
  final bool status;

  UpdateRetailerStatusRequest({
    required this.id,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "status": status,
    };
  }
}

// Response Model
class UpdateRetailerStatusResponse {
  final int success;
  final String message;

  UpdateRetailerStatusResponse({
    required this.success,
    required this.message,
  });

  factory UpdateRetailerStatusResponse.fromJson(Map<String, dynamic> json) {
    return UpdateRetailerStatusResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}
