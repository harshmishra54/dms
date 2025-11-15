import 'dart:convert';

FarmerFunnelResponse farmerFunnelResponseFromJson(String str) =>
    FarmerFunnelResponse.fromJson(json.decode(str));

String farmerFunnelResponseToJson(FarmerFunnelResponse data) =>
    json.encode(data.toJson());

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
  final String? farmerName;
  final String? mobileNumber;
  final List<FunnelEntry>? entries;

  FarmerFunnelData({
    this.farmerName,
    this.mobileNumber,
    this.entries,
  });

  factory FarmerFunnelData.fromJson(Map<String, dynamic> json) =>
      FarmerFunnelData(
        farmerName: json["farmer_name"],
        mobileNumber: json["mobile_number"],
        entries: json["entries"] == null
            ? []
            : List<FunnelEntry>.from(
            json["entries"].map((x) => FunnelEntry.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "farmer_name": farmerName,
    "mobile_number": mobileNumber,
    "entries": entries == null
        ? []
        : List<dynamic>.from(entries!.map((x) => x.toJson())),
  };
}

/// EACH ENTRY
class FunnelEntry {
  final String? id;
  final List<Crop>? crops;
  final String? status;
  final String? latitude;
  final String? longitude;
  final String? meetingId;
  final String? createdAt;

  FunnelEntry({
    this.id,
    this.crops,
    this.status,
    this.latitude,
    this.longitude,
    this.meetingId,
    this.createdAt,
  });

  factory FunnelEntry.fromJson(Map<String, dynamic> json) => FunnelEntry(
    id: json["id"],
    crops: json["crops"] == null
        ? []
        : List<Crop>.from(json["crops"].map((x) => Crop.fromJson(x))),
    status: json["status"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    meetingId: json["meeting_id"],
    createdAt: json["created_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "crops": crops == null
        ? []
        : List<dynamic>.from(crops!.map((x) => x.toJson())),
    "status": status,
    "latitude": latitude,
    "longitude": longitude,
    "meeting_id": meetingId,
    "created_at": createdAt,
  };
}

/// CROPS MODEL
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

/// PRODUCT MODEL
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
