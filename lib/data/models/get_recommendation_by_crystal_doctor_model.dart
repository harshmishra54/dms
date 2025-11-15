// recommended_products_model.dart

class GetRecommendedProductsRequest {
  final String id;

  GetRecommendedProductsRequest({required this.id});

  factory GetRecommendedProductsRequest.fromJson(Map<String, dynamic>? json) {
    return GetRecommendedProductsRequest(
      id: json?['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}

/// Response model for /get-recommended-products API
class RecommendedProductsResponse {
  final int success;
  final List<RecommendedProduct> data;

  RecommendedProductsResponse({
    required this.success,
    required this.data,
  });

  factory RecommendedProductsResponse.fromJson(Map<String, dynamic>? json) {
    final List<dynamic>? dataList = json?['data'] as List<dynamic>?;
    return RecommendedProductsResponse(
      success: json?['success'] ?? 0,
      data: dataList != null
          ? dataList.map((e) => RecommendedProduct.fromJson(e)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class RecommendedProduct {
  final String id;
  final String farmerId;
  final String createdBy;
  final List<Recommendation> recommendations;
  bool? interested; // <--- must be mutable for UI

  RecommendedProduct({
    required this.id,
    required this.farmerId,
    required this.createdBy,
    required this.recommendations,
    this.interested,
  });

  factory RecommendedProduct.fromJson(Map<String, dynamic>? json) {
    final List<dynamic>? recList = json?['details'] as List<dynamic>?;

    return RecommendedProduct(
      id: json?['id'] ?? '',
      farmerId: json?['farmer_id'] ?? '',
      createdBy: json?['created_by'] ?? '',
      recommendations: recList != null
          ? recList.map((e) => Recommendation.fromJson(e)).toList()
          : [],
      interested: json?['interested_in'],
      // <--- FIXED (backend spelling)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmer_id': farmerId,
      'created_by': createdBy,
      'details': recommendations.map((e) => e.toJson()).toList(),
      'intrested_in': interested, // <--- return same key to backend
    };
  }
}

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

  factory Recommendation.fromJson(Map<String, dynamic>? json) {
    return Recommendation(
      productName: json?['product_name'] ?? '',
      crop: json?['crop'] ?? '',
      quantity: json?['quantity'] ?? '',
      reason: json?['reason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_name': productName,
      'crop': crop,
      'quantity': quantity,
      'reason': reason,
    };
  }
}
