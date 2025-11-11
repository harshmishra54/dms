class GetAdvocacyRequest {
  final String id;

  GetAdvocacyRequest({required this.id});

  Map<String, dynamic> toJson() => {
    "id": id,
  };
}

class GetAdvocacyResponse {
  final int success;
  final String message;
  final int totalReferredFarmers;
  final List<ReferredFarmer> data;

  GetAdvocacyResponse({
    required this.success,
    required this.message,
    required this.totalReferredFarmers,
    required this.data,
  });

  factory GetAdvocacyResponse.fromJson(Map<String, dynamic> json) {
    return GetAdvocacyResponse(
      success: json["success"] ?? 0,
      message: json["message"] ?? "",
      totalReferredFarmers: json["total_referred_farmers"] ?? 0,
      data: (json["data"] as List<dynamic>? ?? [])
          .map((item) => ReferredFarmer.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "message": message,
      "total_referred_farmers": totalReferredFarmers,
      "data": data.map((e) => e.toJson()).toList(),
    };
  }
}

class ReferredFarmer {
  final String id;
  final String name;
  final String refferedBy;
  final String refferedByName;

  ReferredFarmer({
    required this.id,
    required this.name,
    required this.refferedBy,
    required this.refferedByName,
  });

  factory ReferredFarmer.fromJson(Map<String, dynamic> json) {
    return ReferredFarmer(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      refferedBy: json["reffered_by"] ?? "",
      refferedByName: json["reffered_by_name"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "reffered_by": refferedBy,
      "reffered_by_name": refferedByName,
    };
  }
}
