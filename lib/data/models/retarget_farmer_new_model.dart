class RetargetFarmerRequest {
  final String id;

  RetargetFarmerRequest({required this.id});

  Map<String, dynamic> toJson() {
    return {
      "id": id,
    };
  }
}
class RetargetFarmerResponse {
  final int success;
  final String message;
  final List<FarmerData> data;

  RetargetFarmerResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RetargetFarmerResponse.fromJson(Map<String, dynamic> json) {
    return RetargetFarmerResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? "",
      data: json['data'] != null
          ? List<FarmerData>.from(
          json['data'].map((x) => FarmerData.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "message": message,
      "data": data.map((e) => e.toJson()).toList(),
    };
  }
}

class FarmerData {
  final String farmerId;
  final String farmerName;

  FarmerData({
    required this.farmerId,
    required this.farmerName,
  });

  factory FarmerData.fromJson(Map<String, dynamic> json) {
    return FarmerData(
      farmerId: json['farmer_id'] ?? "",
      farmerName: json['farmer_name'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "farmer_id": farmerId,
      "farmer_name": farmerName,
    };
  }
}
