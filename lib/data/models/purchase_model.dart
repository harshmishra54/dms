// models/purchase_data_model.dart
class PurchaseDataResponse {
  final int success;
  final String message;
  final List<FarmerPurchase> data;

  PurchaseDataResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PurchaseDataResponse.fromJson(Map<String, dynamic> json) {
    return PurchaseDataResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? List<FarmerPurchase>.from(
          json['data'].map((x) => FarmerPurchase.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((x) => x.toJson()).toList(),
    };
  }
}

class FarmerPurchase {
  final String farmerId;
  final String farmerName;
  final int purchaseCount;

  FarmerPurchase({
    required this.farmerId,
    required this.farmerName,
    required this.purchaseCount,
  });

  factory FarmerPurchase.fromJson(Map<String, dynamic> json) {
    return FarmerPurchase(
      farmerId: json['farmerId'],
      farmerName: json['farmerName'],
      purchaseCount: json['purchaseCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'farmerId': farmerId,
      'farmerName': farmerName,
      'purchaseCount': purchaseCount,
    };
  }
}

// models/purchase_request_model.dart
class PurchaseRequest {
  final String id;

  PurchaseRequest({required this.id});

  factory PurchaseRequest.fromJson(Map<String, dynamic> json) {
    return PurchaseRequest(id: json['id']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}


