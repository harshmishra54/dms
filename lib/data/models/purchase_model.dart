// models/purchase_data_model.dart
class PurchaseDataResponse {
  final int success;
  final String message;
  final PurchaseData data;

  PurchaseDataResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PurchaseDataResponse.fromJson(Map<String, dynamic> json) {
    return PurchaseDataResponse(
      success: json['success'],
      message: json['message'],
      data: PurchaseData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class PurchaseData {
  final List<FarmerPurchase> allFarmersWithPurchases;
  final List<FarmerPurchase> repeatPurchaseFarmers;

  PurchaseData({
    required this.allFarmersWithPurchases,
    required this.repeatPurchaseFarmers,
  });

  factory PurchaseData.fromJson(Map<String, dynamic> json) {
    return PurchaseData(
      allFarmersWithPurchases: json['allFarmersWithPurchases'] != null
          ? List<FarmerPurchase>.from(json['allFarmersWithPurchases']
          .map((x) => FarmerPurchase.fromJson(x)))
          : [],
      repeatPurchaseFarmers: json['repeatPurchaseFarmers'] != null
          ? List<FarmerPurchase>.from(json['repeatPurchaseFarmers']
          .map((x) => FarmerPurchase.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allFarmersWithPurchases':
      allFarmersWithPurchases.map((x) => x.toJson()).toList(),
      'repeatPurchaseFarmers':
      repeatPurchaseFarmers.map((x) => x.toJson()).toList(),
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
