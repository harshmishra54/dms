import 'dart:convert';

/// ======== REQUEST MODEL ========

class UpdateBeatPlanDoctorRequest {
  final String id;
  final String status;
  final String? reason;

  UpdateBeatPlanDoctorRequest({
    required this.id,
    required this.status,
    this.reason,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
    "reason": reason,
  };

  factory UpdateBeatPlanDoctorRequest.fromJson(Map<String, dynamic> json) =>
      UpdateBeatPlanDoctorRequest(
        id: json["id"],
        status: json["status"],
        reason: json["reason"],
      );
}

/// ======== RESPONSE MODEL ========

UpdateBeatPlanDoctorResponse updateBeatPlanDoctorResponseFromJson(String str) =>
    UpdateBeatPlanDoctorResponse.fromJson(json.decode(str));

String updateBeatPlanDoctorResponseToJson(UpdateBeatPlanDoctorResponse data) =>
    json.encode(data.toJson());

class UpdateBeatPlanDoctorResponse {
  final int? success;
  final String? message;
  final BeatPlanDoctorData? data;

  UpdateBeatPlanDoctorResponse({
    this.success,
    this.message,
    this.data,
  });

  factory UpdateBeatPlanDoctorResponse.fromJson(Map<String, dynamic> json) =>
      UpdateBeatPlanDoctorResponse(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : BeatPlanDoctorData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class BeatPlanDoctorData {
  final String? id;
  final List<Farmer>? farmers;
  final String? date;
  final String? userId;
  final String? status;
  final String? routeName;
  final String? createdAt;
  final String? updatedAt;

  BeatPlanDoctorData({
    this.id,
    this.farmers,
    this.date,
    this.userId,
    this.status,
    this.routeName,
    this.createdAt,
    this.updatedAt,
  });

  factory BeatPlanDoctorData.fromJson(Map<String, dynamic> json) =>
      BeatPlanDoctorData(
        id: json["id"],
        farmers: json["farmers"] == null
            ? []
            : List<Farmer>.from(
            json["farmers"].map((x) => Farmer.fromJson(x))),
        date: json["date"],
        userId: json["user_id"],
        status: json["status"],
        routeName: json["route_name"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "farmers": farmers == null
        ? []
        : List<dynamic>.from(farmers!.map((x) => x.toJson())),
    "date": date,
    "user_id": userId,
    "status": status,
    "route_name": routeName,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}

class Farmer {
  final String? id;
  final String? status;

  Farmer({
    this.id,
    this.status,
  });

  factory Farmer.fromJson(Map<String, dynamic> json) => Farmer(
    id: json["id"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
  };
}
