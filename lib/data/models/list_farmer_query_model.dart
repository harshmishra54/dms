// file: list_farmer_query_model.dart

/// =========================
/// Request Model
/// =========================
class ListFarmerQueryRequest {
  final String createdBy;

  ListFarmerQueryRequest({required this.createdBy});

  Map<String, dynamic> toJson() {
    return {
      "id": createdBy,
    };
  }

  factory ListFarmerQueryRequest.fromJson(Map<String, dynamic> json) {
    return ListFarmerQueryRequest(
      createdBy: json['id'],
    );
  }
}

/// =========================
/// Response Model
/// =========================
class ListFarmerQueryResponse {
  final int success;
  final List<FarmerQueryData> data;

  ListFarmerQueryResponse({required this.success, required this.data});

  factory ListFarmerQueryResponse.fromJson(Map<String, dynamic> json) {
    return ListFarmerQueryResponse(
      success: json['success'],
      data: (json['data'] as List)
          .map((e) => FarmerQueryData.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "data": data.map((e) => e.toJson()).toList(),
    };
  }
}

/// =========================
/// Suggested Product Model
/// =========================
class SuggestedProduct {
  final String id;
  final String name;

  SuggestedProduct({
    required this.id,
    required this.name,
  });

  factory SuggestedProduct.fromJson(Map<String, dynamic> json) {
    return SuggestedProduct(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
    };
  }
}

/// =========================
/// Farmer Query Data Model
/// =========================
class FarmerQueryData {
  final String id;
  final List<SuggestedProduct> suggestedProducts;
  final String queries;
  final String createdBy;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;

  FarmerQueryData({
    required this.id,
    required this.suggestedProducts,
    required this.queries,
    required this.createdBy,
    required this.createdAt,
    this.latitude,
    this.longitude,
  });

  factory FarmerQueryData.fromJson(Map<String, dynamic> json) {
    return FarmerQueryData(
      id: json['id'],
      suggestedProducts: (json['suggested_products'] as List)
          .map((e) => SuggestedProduct.fromJson(e))
          .toList(),
      queries: json['queries'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "suggested_products": suggestedProducts.map((e) => e.toJson()).toList(),
      "queries": queries,
      "created_by": createdBy,
      "created_at": createdAt.toIso8601String(),
      "latitude": latitude,
      "longitude": longitude,
    };
  }
}
