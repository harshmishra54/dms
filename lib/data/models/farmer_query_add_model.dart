class FarmerQueryRequest {
  final String queries;
  final List<String> suggestedProducts;
  final String createdBy;
  final double? latitude;
  final double? longitude;
  final String? farmerId;
  final bool? flag;


  FarmerQueryRequest({
    required this.queries,
    required this.suggestedProducts,
    required this.createdBy,
    this.latitude,
    this.longitude,
    this.flag,
    this.farmerId,
  });

  Map<String, dynamic> toJson() {
    return {
      "queries": queries,
      "suggested_products": suggestedProducts,
      "created_by": createdBy,
      "latitude": latitude,
      "longitude": longitude,
      "flag": flag,
      "farmer_id": farmerId,
    };
  }
}
class FarmerQueryResponse {
  final int success;
  final String message;
  final String? queryId;

  FarmerQueryResponse({
    required this.success,
    required this.message,
    this.queryId,
  });

  factory FarmerQueryResponse.fromJson(Map<String, dynamic> json) {
    return FarmerQueryResponse(
      success: json["success"] ?? 0,
      message: json["message"] ?? "",
      queryId: json["queryId"],
    );
  }
}
