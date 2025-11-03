class FarmerDetailsRequest {
  final String phone;

  FarmerDetailsRequest({required this.phone});

  Map<String, dynamic> toJson() => {"phone": phone};
}

class FarmerDetailsResponse {
  final int? success;
  final String? message; // ✅ Added this line
  final FarmerData? data;

  FarmerDetailsResponse({
    this.success,
    this.message, // ✅ Added this line
    this.data,
  });

  factory FarmerDetailsResponse.fromJson(Map<String, dynamic> json) {
    return FarmerDetailsResponse(
      success: json['success'],
      message: json['message'], // ✅ Parse message if present
      data: json['data'] != null ? FarmerData.fromJson(json['data']) : null,
    );
  }
}

class FarmerData {
  final String id;
  final String name;
  final String phone;
  final double? latitude;
  final double? longitude;
  final NearestRetailer? nearestRetailer; // ✅ Added this field

  FarmerData({
    required this.id,
    required this.name,
    required this.phone,
    this.latitude,
    this.longitude,
    this.nearestRetailer,
  });

  factory FarmerData.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return FarmerData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      nearestRetailer: json['nearestRetailer'] != null
          ? NearestRetailer.fromJson(json['nearestRetailer'])
          : null,
    );
  }
}

/// ✅ New model for nearest retailer
class NearestRetailer {
  final String name;
  final String phone;
  final double? distanceKm;

  NearestRetailer({
    required this.name,
    required this.phone,
    this.distanceKm,
  });

  factory NearestRetailer.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return NearestRetailer(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      distanceKm: parseDouble(json['distance_km']),
    );
  }
}
