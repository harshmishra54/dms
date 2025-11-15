class UpdateRecommendationRequest {
  final String queryId;
  final bool interestedIn;

  UpdateRecommendationRequest({
    required this.queryId,
    required this.interestedIn,
  });

  Map<String, dynamic> toJson() {
    return {
      "query_id": queryId,
      "interested_in": interestedIn,
    };
  }
}
class UpdateRecommendationResponse {
  final int success;
  final String message;
  final UpdatedRecommendationData? data;

  UpdateRecommendationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory UpdateRecommendationResponse.fromJson(Map<String, dynamic> json) {
    return UpdateRecommendationResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? UpdatedRecommendationData.fromJson(json['data'])
          : null,
    );
  }
}

class UpdatedRecommendationData {
  final String queryId;
  final bool interestedIn;

  UpdatedRecommendationData({
    required this.queryId,
    required this.interestedIn,
  });

  factory UpdatedRecommendationData.fromJson(Map<String, dynamic> json) {
    return UpdatedRecommendationData(
      queryId: json['query_id'] ?? '',
      interestedIn: json['interested_in'] ?? false,
    );
  }
}
