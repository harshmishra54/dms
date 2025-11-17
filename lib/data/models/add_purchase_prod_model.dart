class AddPurchaseProdRequest {
  final String userId;
  final String cropName;
  final int roleId;

  AddPurchaseProdRequest({
    required this.userId,
    required this.cropName,
    required this.roleId,
  });

  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "crop_name": cropName,
      "role_id": roleId,
    };
  }
}
class AddPurchaseProdResponse {
  final int success;
  final String message;

  AddPurchaseProdResponse({
    required this.success,
    required this.message,
  });

  factory AddPurchaseProdResponse.fromJson(Map<String, dynamic> json) {
    return AddPurchaseProdResponse(
      success: json["success"] ?? 0,
      message: json["message"] ?? "",
    );
  }
}
