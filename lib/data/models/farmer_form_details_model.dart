class GetDetailsByCreatorRequest {
  final String createdBy;

  GetDetailsByCreatorRequest({required this.createdBy});

  factory GetDetailsByCreatorRequest.fromJson(Map<String, dynamic> json) {
    return GetDetailsByCreatorRequest(
      createdBy: json['created_by'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_by': createdBy,
    };
  }
}

// ---------------------------

class FarmerApiResponse {
  final int success;
  final String message;
  final List<FarmerDetail> data;

  FarmerApiResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory FarmerApiResponse.fromJson(Map<String, dynamic> json) {
    final dataList = (json['data'] as List<dynamic>?)
        ?.map((e) => FarmerDetail.fromJson(e as Map<String, dynamic>))
        .toList() ??
        [];

    return FarmerApiResponse(
      success: json['success'] is int
          ? json['success'] as int
          : int.tryParse(json['success'].toString()) ?? 0,
      message: json['message'] as String? ?? 'No message',
      data: dataList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

// ---------------------------

class FarmerDetail {
  final String id;
  final String farmerName;
  final String mobileNumber;
  final String? villageName;
  final String createdBy;
  final String status;
  final List<CropDetail> crops;
  final double latitude;
  final double longitude;
  final String? meetingId;
  final DateTime? createdAt;

  FarmerDetail({
    required this.id,
    required this.farmerName,
    required this.mobileNumber,
    this.villageName,
    required this.createdBy,
    required this.status,
    required this.crops,
    required this.latitude,
    required this.longitude,
    this.meetingId,
    this.createdAt,
  });

  factory FarmerDetail.fromJson(Map<String, dynamic> json) {
    var cropsList = <CropDetail>[];
    if (json['crops'] != null) {
      cropsList = List<Map<String, dynamic>>.from(json['crops'])
          .map((c) => CropDetail.fromJson(c))
          .toList();
    }

    return FarmerDetail(
      id: json['id']?.toString() ?? '',
      farmerName: json['farmer_name']?.toString() ?? 'N/A',
      mobileNumber: json['mobile_number']?.toString() ?? 'N/A',
      villageName: json['village_name']?.toString(),
      createdBy: json['created_by']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      crops: cropsList,
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0,
      meetingId: json['meeting_id']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmer_name': farmerName,
      'mobile_number': mobileNumber,
      'village_name': villageName,
      'created_by': createdBy,
      'status': status,
      'crops': crops.map((c) => c.toJson()).toList(),
      'latitude': latitude,
      'longitude': longitude,
      'meeting_id': meetingId,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

// ---------------------------

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

  factory CropDetail.fromJson(Map<String, dynamic> json) {
    var productList = <ProductDetail>[];
    if (json['products'] != null) {
      productList = List<Map<String, dynamic>>.from(json['products'])
          .map((p) => ProductDetail.fromJson(p))
          .toList();
    }

    return CropDetail(
      cropName: json['crop_name']?.toString() ?? '',
      areaAcres: (json['area_acres'] as num?)?.toDouble() ?? 0,
      durationMonths: json['duration_months']?.toString() ?? '',
      products: productList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crop_name': cropName,
      'area_acres': areaAcres,
      'duration_months': durationMonths,
      'products': products.map((p) => p.toJson()).toList(),
    };
  }
}

// ---------------------------

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

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      productName: json['product_name']?.toString() ?? '',
      currentlyUsing: json['currently_using'] ?? false,
      interestLevel: json['interest_level']?.toString() ?? '',
      expectedQuantity: json['expected_quantity'] ?? 0,
      expectedMonth: json['expected_month']?.toString() ?? '',
      expectedDealer: json['expected_dealer']?.toString() ?? '',
      remarks: json['remarks']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_name': productName,
      'currently_using': currentlyUsing,
      'interest_level': interestLevel,
      'expected_quantity': expectedQuantity,
      'expected_month': expectedMonth,
      'expected_dealer': expectedDealer,
      'remarks': remarks,
    };
  }
}
