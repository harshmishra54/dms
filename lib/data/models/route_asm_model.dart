/// route_asm_model.dart

class RouteAsmRequest {
  final int typeOf;
  final List<String>? date; // only for type_of = 0
  final List<LocationItem>? distributorLocations;
  final List<LocationItem>? retailerLocations;
  final String name;

  RouteAsmRequest({
    required this.typeOf,
    this.date,
    this.distributorLocations,
    this.retailerLocations,
    required this.name
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['type_of'] = typeOf;
    data['name'] = name;


    if (typeOf == 0) {
      // Date → Users
      if (date != null) data['date'] = date;
      if (distributorLocations != null) {
        data['distributor_locations'] =
            distributorLocations!.map((e) => e.toJson(typeOf)).toList();
      }
      if (retailerLocations != null) {
        data['retailer_locations'] =
            retailerLocations!.map((e) => e.toJson(typeOf)).toList();
      }
    } else if (typeOf == 1) {
      // User → Dates
      if (distributorLocations != null) {
        data['distributor_locations'] =
            distributorLocations!.map((e) => e.toJson(typeOf)).toList();
      }
      if (retailerLocations != null) {
        data['retailer_locations'] =
            retailerLocations!.map((e) => e.toJson(typeOf)).toList();
      }
    }

    return data;
  }
}

/// Universal location model that can be used for both
class LocationItem {
  final String id;
  final List<String>? dates; // only required when type_of = 1

  LocationItem({required this.id, this.dates});

  Map<String, dynamic> toJson(int typeOf) {
    final Map<String, dynamic> map = {'id': id};   // 👈 Fix
    if (typeOf == 1 && dates != null && dates!.isNotEmpty) {
      map['dates'] = dates; // ✅ Now allowed
    }
    return map;
  }
}

/// Response model
class RouteAsmResponse {
  final int success;
  final String message;

  RouteAsmResponse({required this.success, required this.message});

  factory RouteAsmResponse.fromJson(Map<String, dynamic> json) {
    return RouteAsmResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}
