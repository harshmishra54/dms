// Request Model
class GetMyFarmersRequest {
  final String createdBy;

  GetMyFarmersRequest({required this.createdBy});

  factory GetMyFarmersRequest.fromJson(Map<String, dynamic> json) {
    return GetMyFarmersRequest(
      createdBy: json['created_by'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_by': createdBy,
    };
  }
}

// Response Model
class GetMyFarmersResponse {
  final bool success;
  final String message;
  final FarmerData? data;

  GetMyFarmersResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory GetMyFarmersResponse.fromJson(Map<String, dynamic> json) {
    return GetMyFarmersResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? FarmerData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class FarmerData {
  final List<Farmer> farmers;
  final int totalCount;

  FarmerData({
    required this.farmers,
    required this.totalCount,
  });

  factory FarmerData.fromJson(Map<String, dynamic> json) {
    var list = (json['farmers'] as List<dynamic>?)
        ?.map((item) => Farmer.fromJson(item))
        .toList() ??
        [];

    return FarmerData(
      farmers: list,
      totalCount: json['total_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'farmers': farmers.map((f) => f.toJson()).toList(),
      'total_count': totalCount,
    };
  }
}

class Farmer {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String address;
  final String area;
  final String latitude;
  final String longitude;

  Farmer({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.address,
    required this.area,
    required this.latitude,
    required this.longitude,
  });

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      address: json['address'] ?? '',
      area: json['area'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'area': area,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
