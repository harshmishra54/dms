/// Request Model
class GetDoctorHistoryRequest {
  final String id;

  GetDoctorHistoryRequest({required this.id});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}

/// Response Model
class GetDoctorHistoryResponse {
  final int success;
  final List<DoctorHistoryData> data;

  GetDoctorHistoryResponse({
    required this.success,
    required this.data,
  });

  factory GetDoctorHistoryResponse.fromJson(Map<String, dynamic> json) {
    return GetDoctorHistoryResponse(
      success: json['success'] as int,
      data: (json['data'] as List<dynamic>)
          .map((e) => DoctorHistoryData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DoctorHistoryData {
  final String id;
  final String createdBy;
  final String farmerId;
  final String farmerName;
  final List<Recommendation> recommendations;

  DoctorHistoryData({
    required this.id,
    required this.createdBy,
    required this.farmerId,
    required this.farmerName,
    required this.recommendations,
  });

  factory DoctorHistoryData.fromJson(Map<String, dynamic> json) {
    return DoctorHistoryData(
      id: json['id'] as String,
      createdBy: json['created_by'] as String,
      farmerId: json['farmerId'] as String,
      farmerName: json['farmerName'] as String,
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => Recommendation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_by': createdBy,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'recommendations': recommendations.map((e) => e.toJson()).toList(),
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

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      productName: json['product_name'] as String,
      crop: json['crop'] as String,
      quantity: json['quantity'] as String,
      reason: json['reason'] as String,
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
