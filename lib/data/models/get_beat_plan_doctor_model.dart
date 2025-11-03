import 'dart:convert';

/// =========================
/// 🔹 REQUEST MODEL
/// =========================

GetBeatPlanDoctorRequest getBeatPlanDoctorRequestFromJson(String str) =>
    GetBeatPlanDoctorRequest.fromJson(json.decode(str));

String getBeatPlanDoctorRequestToJson(GetBeatPlanDoctorRequest data) =>
    json.encode(data.toJson());

class GetBeatPlanDoctorRequest {
  final String? userId;

  GetBeatPlanDoctorRequest({this.userId});

  factory GetBeatPlanDoctorRequest.fromJson(Map<String, dynamic> json) =>
      GetBeatPlanDoctorRequest(
        userId: json["user_id"],
      );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
  };
}

/// =========================
/// 🔹 RESPONSE MODEL
/// =========================

GetBeatPlanDoctorResponse getBeatPlanDoctorResponseFromJson(String str) =>
    GetBeatPlanDoctorResponse.fromJson(json.decode(str));

String getBeatPlanDoctorResponseToJson(GetBeatPlanDoctorResponse data) =>
    json.encode(data.toJson());

class GetBeatPlanDoctorResponse {
  final int? success;
  final String? message;
  final List<BeatPlanDoctorData>? data;
  final int? totalCount;

  GetBeatPlanDoctorResponse({
    this.success,
    this.message,
    this.data,
    this.totalCount,
  });

  factory GetBeatPlanDoctorResponse.fromJson(Map<String, dynamic> json) =>
      GetBeatPlanDoctorResponse(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<BeatPlanDoctorData>.from(
            json["data"].map((x) => BeatPlanDoctorData.fromJson(x))),
        totalCount: json["total_count"],
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
    "total_count": totalCount,
  };
}

class BeatPlanDoctorData {
  final String? id;
  final String? date;
  final String? userId;
  final String? routeName; // ✅ newly added field
  final List<Farmer>? farmers;
  final String? status;

  BeatPlanDoctorData({
    this.id,
    this.date,
    this.userId,
    this.routeName,
    this.farmers,
    this.status,
  });

  factory BeatPlanDoctorData.fromJson(Map<String, dynamic> json) =>
      BeatPlanDoctorData(
        id: json["id"],
        date: json["date"],
        userId: json["user_id"],
        routeName: json["route_name"], // ✅ mapped from API
        status: json["status"],
        farmers: json["farmers"] == null
            ? []
            : List<Farmer>.from(
            json["farmers"].map((x) => Farmer.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "date": date,
    "user_id": userId,
    "route_name": routeName, // ✅ included in toJson
    "status": status,
    "farmers": farmers == null
        ? []
        : List<dynamic>.from(farmers!.map((x) => x.toJson())),
  };
}

class Farmer {
  final String? id;
  final String? name;
  final String? phone;
  final String? area;
  final String? address;
  final String? status;

  Farmer({
    this.id,
    this.name,
    this.phone,
    this.area,
    this.address,
    this.status,
  });

  factory Farmer.fromJson(Map<String, dynamic> json) => Farmer(
    id: json["id"],
    name: json["name"],
    phone: json["phone"],
    area: json["area"],
    address: json["address"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone": phone,
    "area": area,
    "address": address,
    "status":status,
  };
}
