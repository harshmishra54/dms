class ProductRecommendationRequestbody {
  final String farmerId;
  final String createdby;
  final List<Recommendation> recommendations;

  ProductRecommendationRequestbody({
    required this.farmerId,
    required this.createdby,
    required this.recommendations,
  });

  Map<String, dynamic> toJson() {
    return {
      "farmerId": farmerId,
      "created_by": createdby,
      "recommendations": recommendations.map((e) => e.toJson()).toList(),
    };
  }
}

// -------------------------------
// ✅ Shared model used for both request & response
// -------------------------------
class Recommendation {
  final String productName;
  final String crop;
  final String quantity;
  final String reason;

  Recommendation({
    required this.productName,
    required this.crop,
    required this.quantity,
    required this.reason,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      productName: json['product_name'] ?? '',
      crop: json['crop'] ?? '',
      quantity: json['quantity'] ?? '',
      reason: json['reason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "product_name": productName,
      "crop": crop,
      "quantity": quantity,
      "reason": reason,
    };
  }
}

// -------------------------------
// ✅ Response models
// -------------------------------
class ProductRecommendationResponse {
  final int success;
  final String message;
  final ProductRecommendationData? data;

  ProductRecommendationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ProductRecommendationResponse.fromJson(Map<String, dynamic> json) {
    return ProductRecommendationResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? ProductRecommendationData.fromJson(json['data'])
          : null,
    );
  }
}

class ProductRecommendationData {
  final Farmer farmer;
  final List<Recommendation> recommendations;

  ProductRecommendationData({
    required this.farmer,
    required this.recommendations,
  });

  factory ProductRecommendationData.fromJson(Map<String, dynamic> json) {
    return ProductRecommendationData(
      farmer: Farmer.fromJson(json['farmer']),
      recommendations: (json['recommendations'] as List<dynamic>?)
          ?.map((e) => Recommendation.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class Farmer {
  final String id;
  final String name;
  final String phone;
  final String countryCode;

  Farmer({
    required this.id,
    required this.name,
    required this.phone,
    required this.countryCode,
  });

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      countryCode: json['country_code'] ?? '',
    );
  }
}
