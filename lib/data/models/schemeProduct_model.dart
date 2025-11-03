class SchemeProductsRequest {
  final int roleId;
  final String userId;

  SchemeProductsRequest({
    required this.roleId,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'roleId': roleId,
      'userId': userId,
    };
  }
}
class SchemeProductsResponse {
  final bool success;
  final List<String> skuIds;
  final String? message; // optional, for error messages

  SchemeProductsResponse({
    required this.success,
    required this.skuIds,
    this.message,
  });

  factory SchemeProductsResponse.fromJson(Map<String, dynamic> json) {
    return SchemeProductsResponse(
      success: json['success'] == 1 || json['success'] == true,
      skuIds: json['skuIds'] != null
          ? List<String>.from(json['skuIds'])
          : [],
      message: json['message'],
    );
  }
}
