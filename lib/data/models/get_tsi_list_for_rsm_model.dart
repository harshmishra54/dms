// Request Model
class GetTsiListRequest {
  final String id;

  GetTsiListRequest({required this.id});

  factory GetTsiListRequest.fromJson(Map<String, dynamic> json) {
    return GetTsiListRequest(
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
    };
  }
}

// Response Model
class GetTsiListResponse {
  final int success;
  final List<TsiUser> data;

  GetTsiListResponse({
    required this.success,
    required this.data,
  });

  factory GetTsiListResponse.fromJson(Map<String, dynamic> json) {
    return GetTsiListResponse(
      success: json['success'] ?? 0,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => TsiUser.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "data": data.map((e) => e.toJson()).toList(),
    };
  }
}

// TSI User Model
class TsiUser {
  final String id;
  final String? randomId;
  final int? roleId;
  final String? companyId;
  final String? name;
  final String? mobileNo;
  final String? email;
  final bool? isEmailVerified;
  final bool? isDeleted;
  final bool? isApproved;
  final bool? isUpdatedProfile;
  final bool? isBlocked;
  final bool? isPasswordUpdated;
  final int? points;
  final int? availablePoints;
  final int? blockedPoints;
  final int? utilizePoints;
  final int? bonusPoints;
  final String? jwtToken;
  final String? fcmToken;
  final String? address;
  final int? stateId;
  final int? pinCode;
  final String? zoneId;
  final String? regionId;
  final String? territoryId;
  final String? createdAt;
  final String? updatedAt;
  final String? lastActivityAt;


  TsiUser({
    required this.id,
    this.randomId,
    this.roleId,
    this.companyId,
    this.name,
    this.mobileNo,
    this.email,
    this.isEmailVerified,
    this.isDeleted,
    this.isApproved,
    this.isUpdatedProfile,
    this.isBlocked,
    this.isPasswordUpdated,
    this.points,
    this.availablePoints,
    this.blockedPoints,
    this.utilizePoints,
    this.bonusPoints,
    this.jwtToken,
    this.fcmToken,
    this.address,
    this.stateId,
    this.pinCode,
    this.zoneId,
    this.regionId,
    this.territoryId,
    this.createdAt,
    this.updatedAt,
    this.lastActivityAt,

  });

  factory TsiUser.fromJson(Map<String, dynamic> json) {
    return TsiUser(
      id: json['id'] ?? '',
      randomId: json['random_id'],
      roleId: json['role_id'],
      companyId: json['company_id'],
      name: json['name'],
      mobileNo: json['mobile_no'],
      email: json['email'],
      isEmailVerified: json['is_email_verified'],
      isDeleted: json['is_deleted'],
      isApproved: json['is_approved'],
      isUpdatedProfile: json['is_updated_profile'],
      isBlocked: json['is_blocked'],
      isPasswordUpdated: json['is_password_updated'],
      points: json['points'],
      availablePoints: json['available_points'],
      blockedPoints: json['blocked_points'],
      utilizePoints: json['utilize_points'],
      bonusPoints: json['bonus_points'],
      jwtToken: json['jwt_token'],
      fcmToken: json['fcm_token'],
      address: json['address'],
      stateId: json['state_id'],
      pinCode: json['pin_code'],
      zoneId: json['zone_id'],
      regionId: json['region_id'],
      territoryId: json['territory_id'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      lastActivityAt: json['last_activity_at'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "random_id": randomId,
      "role_id": roleId,
      "company_id": companyId,
      "name": name,
      "mobile_no": mobileNo,
      "email": email,
      "is_email_verified": isEmailVerified,
      "is_deleted": isDeleted,
      "is_approved": isApproved,
      "is_updated_profile": isUpdatedProfile,
      "is_blocked": isBlocked,
      "is_password_updated": isPasswordUpdated,
      "points": points,
      "available_points": availablePoints,
      "blocked_points": blockedPoints,
      "utilize_points": utilizePoints,
      "bonus_points": bonusPoints,
      "jwt_token": jwtToken,
      "fcm_token": fcmToken,
      "address": address,
      "state_id": stateId,
      "pin_code": pinCode,
      "zone_id": zoneId,
      "region_id": regionId,
      "territory_id": territoryId,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "last_activity_at": lastActivityAt,

    };
  }
}
