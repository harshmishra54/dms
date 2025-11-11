class RouteRequestModel {
  final int pincode;
  final String originLat;
  final String originLng;

  RouteRequestModel({
    required this.pincode,
    required this.originLat,
    required this.originLng,
  });

  Map<String, dynamic> toJson() => {
    "pincode": pincode,
    "origin_lat": originLat,
    "origin_lng": originLng,
  };
}

class RouteResponseModel {
  final int success;
  final String message;
  final int? totalFarmers;
  final String? totalDistanceKm;
  final List<RouteFarmer> route;

  RouteResponseModel({
    required this.success,
    required this.message,
    this.totalFarmers,
    this.totalDistanceKm,
    required this.route,
  });

  factory RouteResponseModel.fromJson(Map<String, dynamic> json) {
    return RouteResponseModel(
      success: json["success"] ?? 0,
      message: json["message"] ?? "",
      totalFarmers: json["total_farmers"],
      totalDistanceKm: json["total_distance_km"],
      route: json["route"] == null
          ? []
          : List<RouteFarmer>.from(
          json["route"].map((x) => RouteFarmer.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "total_farmers": totalFarmers,
    "total_distance_km": totalDistanceKm,
    "route": route.map((e) => e.toJson()).toList(),
  };
}

class RouteFarmer {
  final String id;  // ✅ Changed to String
  final String name;
  final String phone;
  final double latitude;
  final double longitude;
  final double distanceFromPrev;

  RouteFarmer({
    required this.id,
    required this.name,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.distanceFromPrev,
  });

  factory RouteFarmer.fromJson(Map<String, dynamic> json) {
    return RouteFarmer(
      id: json["id"].toString(), // ✅ converted safely to string
      name: json["name"] ?? "",
      phone: json["phone"] ?? "",
      latitude: (json["latitude"] ?? 0).toDouble(),
      longitude: (json["longitude"] ?? 0).toDouble(),
      distanceFromPrev: (json["distanceFromPrev"] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    "latitude": latitude,
    "longitude": longitude,
    "distanceFromPrev": distanceFromPrev,
  };
}
