// add_farmer_points_request.dart
class AddFarmerPointsRequest {
  final List<String> ids;
  final String points;

  AddFarmerPointsRequest({
    required this.ids,
    required this.points,
  });

  Map<String, dynamic> toJson() {
    return {
      "ids": ids,
      "points": points,
    };
  }
}
// add_farmer_points_response.dart
class AddFarmerPointsResponse {
  final int success;
  final String message;

  AddFarmerPointsResponse({
    required this.success,
    required this.message,
  });

  factory AddFarmerPointsResponse.fromJson(Map<String, dynamic> json) {
    return AddFarmerPointsResponse(
      success: json["success"],
      message: json["message"],
    );
  }
}
