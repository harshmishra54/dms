import 'dart:convert';

GetActivityTimelineRequest getActivityTimelineRequestFromJson(String str) =>
    GetActivityTimelineRequest.fromJson(json.decode(str));

String getActivityTimelineRequestToJson(GetActivityTimelineRequest data) =>
    json.encode(data.toJson());

class GetActivityTimelineRequest {
  final String? id;
  GetActivityTimelineRequest({this.id});

  factory GetActivityTimelineRequest.fromJson(Map<String, dynamic> json) =>
      GetActivityTimelineRequest(id: json["id"]?.toString());

  Map<String, dynamic> toJson() => {"id": id};
}

// ====================================================
// ✅ RESPONSE MODEL (FIXED SAFE TYPES)
// ====================================================

ActivityTimelineResponse activityTimelineResponseFromJson(String str) =>
    ActivityTimelineResponse.fromJson(json.decode(str));

String activityTimelineResponseToJson(ActivityTimelineResponse data) =>
    json.encode(data.toJson());

class ActivityTimelineResponse {
  final int? success;
  final String? message;
  final List<ActivityData>? data;
  final int? count;

  ActivityTimelineResponse({this.success, this.message, this.data, this.count});

  factory ActivityTimelineResponse.fromJson(Map<String, dynamic> json) =>
      ActivityTimelineResponse(
        success: json["success"],
        message: json["message"]?.toString(),
        count: json["count"],
        data: json["data"] == null
            ? []
            : List<ActivityData>.from(
            json["data"].map((x) => ActivityData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "count": count,
    "data": data?.map((x) => x.toJson()).toList() ?? [],
  };
}

class ActivityData {
  final String? id;
  final int? roleId;
  final String? name;
  final String? countryCode;
  final String? phone;
  final String? email;
  final DateTime? dob;
  final String? gender;
  final String? pinCode;
  final int? cityId;
  final int? stateId;
  final String? address;
  final String? jwtToken;
  final String? fcmToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? points;
  final int? availablePoints;
  final int? blockedPoints;
  final int? utilizePoints;
  final int? bonusPoints;
  final String? recordUid;
  final bool? isDeleted;
  final bool? isUpdatedProfile;
  final bool? isBlocked;
  final bool? isUpdatedVersion;
  final String? area;
  final String? latitude;
  final String? longitude;
  final String? createdBy;
  final String? referralCode;
  final String? referredBy;

  ActivityData({
    this.id,
    this.roleId,
    this.name,
    this.countryCode,
    this.phone,
    this.email,
    this.dob,
    this.gender,
    this.pinCode,
    this.cityId,
    this.stateId,
    this.address,
    this.jwtToken,
    this.fcmToken,
    this.createdAt,
    this.updatedAt,
    this.points,
    this.availablePoints,
    this.blockedPoints,
    this.utilizePoints,
    this.bonusPoints,
    this.recordUid,
    this.isDeleted,
    this.isUpdatedProfile,
    this.isBlocked,
    this.isUpdatedVersion,
    this.area,
    this.latitude,
    this.longitude,
    this.createdBy,
    this.referralCode,
    this.referredBy,
  });

  factory ActivityData.fromJson(Map<String, dynamic> json) => ActivityData(
    id: json["id"]?.toString(),
    roleId: json["role_id"],
    name: json["name"]?.toString(),
    countryCode: json["country_code"]?.toString(),
    phone: json["phone"]?.toString(),
    email: json["email"]?.toString(),
    dob: json["dob"] == null ? null : DateTime.tryParse(json["dob"]),
    gender: json["gender"]?.toString(),
    pinCode: json["pin_code"]?.toString(), // ✅ FIX
    cityId: json["city_id"],
    stateId: json["state_id"],
    address: json["address"]?.toString(),
    jwtToken: json["jwt_token"]?.toString(),
    fcmToken: json["fcm_token"]?.toString(),
    createdAt: json["createdAt"] == null ? null : DateTime.tryParse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.tryParse(json["updatedAt"]),
    points: json["points"],
    availablePoints: json["available_points"],
    blockedPoints: json["blocked_points"],
    utilizePoints: json["utilize_points"],
    bonusPoints: json["bonus_points"],
    recordUid: json["record_uid"]?.toString(),
    isDeleted: json["is_deleted"],
    isUpdatedProfile: json["is_updated_profile"],
    isBlocked: json["is_blocked"],
    isUpdatedVersion: json["is_updated_version"],
    area: json["area"]?.toString(),
    latitude: json["latitude"]?.toString(), // ✅ FIX
    longitude: json["longitude"]?.toString(), // ✅ FIX
    createdBy: json["created_by"]?.toString(),
    referralCode: json["refferal_code"]?.toString(),
    referredBy: json["reffered_by"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "role_id": roleId,
    "name": name,
    "country_code": countryCode,
    "phone": phone,
    "email": email,
    "dob": dob?.toIso8601String(),
    "gender": gender,
    "pin_code": pinCode,
    "city_id": cityId,
    "state_id": stateId,
    "address": address,
    "jwt_token": jwtToken,
    "fcm_token": fcmToken,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "points": points,
    "available_points": availablePoints,
    "blocked_points": blockedPoints,
    "utilize_points": utilizePoints,
    "bonus_points": bonusPoints,
    "record_uid": recordUid,
    "is_deleted": isDeleted,
    "is_updated_profile": isUpdatedProfile,
    "is_blocked": isBlocked,
    "is_updated_version": isUpdatedVersion,
    "area": area,
    "latitude": latitude,
    "longitude": longitude,
    "created_by": createdBy,
    "refferal_code": referralCode,
    "reffered_by": referredBy,
  };
}
