import 'dart:convert';

FarmerFunnelResponse farmerFunnelResponseFromJson(String str) =>
    FarmerFunnelResponse.fromJson(json.decode(str));

String farmerFunnelResponseToJson(FarmerFunnelResponse data) =>
    json.encode(data.toJson());
class FarmerFunnelRequest {
  final String createdBy;

  FarmerFunnelRequest({required this.createdBy});

  Map<String, dynamic> toJson() => {
    "created_by": createdBy,
  };
}


class FarmerFunnelResponse {
  final int? success;
  final String? message;
  final List<FarmerFunnelData>? data;

  FarmerFunnelResponse({
    this.success,
    this.message,
    this.data,
  });

  factory FarmerFunnelResponse.fromJson(Map<String, dynamic> json) =>
      FarmerFunnelResponse(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<FarmerFunnelData>.from(
            json["data"].map((x) => FarmerFunnelData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class FarmerFunnelData {
  final String? id;
  final String? farmerName;
  final String? mobileNumber;
  final String? villageName;
  final String? createdBy;
  final List<Crop>? crops;
  final String? status;
  final String? latitude;
  final String? longitude;
  final String? meetingId;
  final String? createdAt;
  final List<Query>? queries;
  final List<dynamic>? recommendedProducts;

  FarmerFunnelData({
    this.id,
    this.farmerName,
    this.mobileNumber,
    this.villageName,
    this.createdBy,
    this.crops,
    this.status,
    this.latitude,
    this.longitude,
    this.meetingId,
    this.createdAt,
    this.queries,
    this.recommendedProducts,
  });

  factory FarmerFunnelData.fromJson(Map<String, dynamic> json) =>
      FarmerFunnelData(
        id: json["id"],
        farmerName: json["farmer_name"],
        mobileNumber: json["mobile_number"],
        villageName: json["village_name"],
        createdBy: json["created_by"],
        crops: json["crops"] == null
            ? []
            : List<Crop>.from(json["crops"].map((x) => Crop.fromJson(x))),
        status: json["status"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        meetingId: json["meeting_id"],
        createdAt: json["created_at"],
        queries: json["queries"] == null
            ? []
            : List<Query>.from(json["queries"].map((x) => Query.fromJson(x))),
        recommendedProducts: json["recommended_products"] ?? [],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "farmer_name": farmerName,
    "mobile_number": mobileNumber,
    "village_name": villageName,
    "created_by": createdBy,
    "crops":
    crops == null ? [] : List<dynamic>.from(crops!.map((x) => x.toJson())),
    "status": status,
    "latitude": latitude,
    "longitude": longitude,
    "meeting_id": meetingId,
    "created_at": createdAt,
    "queries": queries == null
        ? []
        : List<dynamic>.from(queries!.map((x) => x.toJson())),
    "recommended_products": recommendedProducts ?? [],
  };
}

class Crop {
  final List<Product>? products;
  final String? cropName;
  final dynamic areaAcres;
  final String? durationMonths;

  Crop({
    this.products,
    this.cropName,
    this.areaAcres,
    this.durationMonths,
  });

  factory Crop.fromJson(Map<String, dynamic> json) => Crop(
    products: json["products"] == null
        ? []
        : List<Product>.from(
        json["products"].map((x) => Product.fromJson(x))),
    cropName: json["crop_name"],
    areaAcres: json["area_acres"],
    durationMonths: json["duration_months"],
  );

  Map<String, dynamic> toJson() => {
    "products": products == null
        ? []
        : List<dynamic>.from(products!.map((x) => x.toJson())),
    "crop_name": cropName,
    "area_acres": areaAcres,
    "duration_months": durationMonths,
  };
}

class Product {
  final String? remarks;
  final String? productName;
  final String? expectedMonth;
  final String? interestLevel;
  final bool? currentlyUsing;
  final String? expectedDealer;
  final dynamic expectedQuantity;

  Product({
    this.remarks,
    this.productName,
    this.expectedMonth,
    this.interestLevel,
    this.currentlyUsing,
    this.expectedDealer,
    this.expectedQuantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    remarks: json["remarks"],
    productName: json["product_name"],
    expectedMonth: json["expected_month"],
    interestLevel: json["interest_level"],
    currentlyUsing: json["currently_using"],
    expectedDealer: json["expected_dealer"]?.toString(),
    expectedQuantity: json["expected_quantity"],
  );

  Map<String, dynamic> toJson() => {
    "remarks": remarks,
    "product_name": productName,
    "expected_month": expectedMonth,
    "interest_level": interestLevel,
    "currently_using": currentlyUsing,
    "expected_dealer": expectedDealer,
    "expected_quantity": expectedQuantity,
  };
}

class Query {
  final String? id;
  final String? createdBy;
  final String? farmerId;
  final List<QueryDetail>? details;

  Query({
    this.id,
    this.createdBy,
    this.farmerId,
    this.details,
  });

  factory Query.fromJson(Map<String, dynamic> json) => Query(
    id: json["id"],
    createdBy: json["created_by"],
    farmerId: json["farmer_id"],
    details: json["details"] == null
        ? []
        : List<QueryDetail>.from(
        json["details"].map((x) => QueryDetail.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "created_by": createdBy,
    "farmer_id": farmerId,
    "details": details == null
        ? []
        : List<dynamic>.from(details!.map((x) => x.toJson())),
  };
}

class QueryDetail {
  final String? productName;
  final String? crop;
  final String? quantity;
  final String? reason;

  QueryDetail({
    this.productName,
    this.crop,
    this.quantity,
    this.reason,
  });

  factory QueryDetail.fromJson(Map<String, dynamic> json) => QueryDetail(
    productName: json["product_name"],
    crop: json["crop"],
    quantity: json["quantity"],
    reason: json["reason"],
  );

  Map<String, dynamic> toJson() => {
    "product_name": productName,
    "crop": crop,
    "quantity": quantity,
    "reason": reason,
  };
}
