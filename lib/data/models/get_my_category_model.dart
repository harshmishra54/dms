class GetMyCategoryRequest {
  final int points;

  GetMyCategoryRequest({required this.points});

  Map<String, dynamic> toJson() {
    return {
      "points": points,
    };
  }
}
class GetMyCategoryResponse {
  final int success;
  final String message;
  final CategoryData? data;

  GetMyCategoryResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory GetMyCategoryResponse.fromJson(Map<String, dynamic> json) {
    return GetMyCategoryResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? CategoryData.fromJson(json['data']) : null,
    );
  }
}
class CategoryData {
  final String currentCategory;
  final int currentMinimumPoints;
  final String nextCategory;
  final int pointsRequiredForNextCategory;

  CategoryData({
    required this.currentCategory,
    required this.currentMinimumPoints,
    required this.nextCategory,
    required this.pointsRequiredForNextCategory,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      currentCategory: json['current_category'] ?? "",
      currentMinimumPoints: json['current_minimum_points'] ?? 0,
      nextCategory: json['next_category'] ?? "",
      pointsRequiredForNextCategory:
      json['points_required_for_next_category'] ?? 0,
    );
  }
}
