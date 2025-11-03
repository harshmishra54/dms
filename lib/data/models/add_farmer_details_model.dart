class ProductDetail {
  final String productName;
  final bool currentlyUsing;
  final String interestLevel;
  final int expectedQuantity;
  final String expectedMonth;
  final String expectedDealer;
  final String remarks;

  ProductDetail({
    required this.productName,
    required this.currentlyUsing,
    required this.interestLevel,
    required this.expectedQuantity,
    required this.expectedMonth,
    required this.expectedDealer,
    required this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      "product_name": productName,
      "currently_using": currentlyUsing,
      "interest_level": interestLevel,
      "expected_quantity": expectedQuantity,
      "expected_month": expectedMonth,
      "expected_dealer": expectedDealer,
      "remarks": remarks,
    };
  }

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      productName: json['product_name'],
      currentlyUsing: json['currently_using'] ?? false,
      interestLevel: json['interest_level'],
      expectedQuantity: json['expected_quantity'],
      expectedMonth: json['expected_month'],
      expectedDealer: json['expected_dealer'],
      remarks: json['remarks'],
    );
  }
}

class CropDetail {
  final String cropName;
  final double areaAcres;
  final String durationMonths;
  final List<ProductDetail> products;

  CropDetail({
    required this.cropName,
    required this.areaAcres,
    required this.durationMonths,
    required this.products,
  });

  Map<String, dynamic> toJson() {
    return {
      "crop_name": cropName,
      "area_acres": areaAcres,
      "duration_months": durationMonths,
      "products": products.map((p) => p.toJson()).toList(),
    };
  }

  factory CropDetail.fromJson(Map<String, dynamic> json) {
    var productList = <ProductDetail>[];
    if (json['products'] != null) {
      productList = List<Map<String, dynamic>>.from(json['products'])
          .map((p) => ProductDetail.fromJson(p))
          .toList();
    }
    return CropDetail(
      cropName: json['crop_name'],
      areaAcres: (json['area_acres'] as num).toDouble(),
      durationMonths: json['duration_months'] ?? "",
      products: productList,
    );
  }
}

class AddFarmerRequest {
  final String farmerName;
  final String mobileNumber;
  final List<CropDetail> crops;
  final String createdBy;
  final double longitude;
  final double latitude;
  final String season;

  AddFarmerRequest({
    required this.farmerName,
    required this.mobileNumber,
    required this.crops,
    required this.createdBy,
    required this.longitude,
    required this.latitude,
    required this.season,
  });

  Map<String, dynamic> toJson() {
    return {
      "farmer_name": farmerName,
      "mobile_number": mobileNumber,
      "crops": crops.map((c) => c.toJson()).toList(),
      "created_by": createdBy,
      "longitude": longitude,
      "latitude": latitude,
      "season": season,
    };
  }
}
class AddFarmerResponse {
  final int success;
  final String message;
  final String farmerId;

  AddFarmerResponse({
    required this.success,
    required this.message,
    required this.farmerId,
  });

  factory AddFarmerResponse.fromJson(Map<String, dynamic> json) {
    return AddFarmerResponse(
      success: json['success'],
      message: json['message'],
      farmerId: json['farmerId'],
    );
  }
}
