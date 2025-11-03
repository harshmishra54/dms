import 'dart:convert';

/// ==================
/// Request Model
/// ==================
class DistributorByIdRequest {
  final String territoryId;

  DistributorByIdRequest({required this.territoryId});

  Map<String, dynamic> toJson() {
    return {"territory_id": territoryId};
  }

  factory DistributorByIdRequest.fromJson(Map<String, dynamic> json) {
    return DistributorByIdRequest(
      territoryId: json["territory_id"]?.toString() ?? "",
    );
  }
}

/// ==================
/// Response Model
/// ==================
class DistributorByIdResponse {
  final int success;
  final String message;
  final List<DistributorData> data;

  DistributorByIdResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DistributorByIdResponse.fromJson(Map<String, dynamic> json) {
    return DistributorByIdResponse(
      success: _toInt(json["success"]) ?? 0,
      message: _toString(json["message"]),
      data: (json["data"] as List<dynamic>? ?? [])
          .map((e) => DistributorData.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "message": message,
      "data": data.map((e) => e.toJson()).toList(),
    };
  }

  /// ==================
  /// Helper Parsers
  /// ==================
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  static String _toString(dynamic value) {
    if (value == null) return "";
    return value.toString();
  }

  static bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == "1" || value.toLowerCase() == "true";
    return null;
  }
}

/// ==================
/// Distributor Data Model
/// ==================
class DistributorData {
  final String id;
  final String? uniqueName;
  final String? name;
  final int? cityId;
  final int? stateId;
  final String? firmName;
  final String? address;
  final bool? transferValidator;
  final bool? salesValidator;
  final bool? allowSync;
  final bool? returnValidator;
  final bool? isCustomer;
  final dynamic financeLocationId;
  final List<dynamic>? financeLocations;
  final dynamic financeCustomerId;
  final bool? customerStatus;
  final bool? isUploaded;
  final bool? isDeleted;
  final bool? isThirdParty;
  final bool? isBlocked;
  final bool? isUpdatedProfile;
  final bool? isSelfOnboarding;
  final int? points;
  final int? availablePoints;
  final int? blockedPoints;
  final int? utilizePoints;
  final int? bonusPoints;
  final String? recordUid;
  final int? expiredPoints;
  final int? revokePoints;
  final String? email;
  final String? lastSyncAt;
  final String? syncError;
  final List<String>? tsmIds;
  final String? phone;
  final String? syncCode;
  final String? fcmToken;
  final String? jwtToken;
  final String? upiNo;
  final String? estDate;
  final String? code;
  final String? gstNo;
  final String? panNo;
  final String? licenseNo;
  final int? useCounter;
  final String? otpDuration;
  final String? dob;
  final String? countryCode;
  final String? profilePicture;
  final String? cityName;
  final String? pinCode;
  final String? zoneId;
  final String? regionId;
  final String? territoryId;
  final String? tenantId;
  final String? apiKey;
  final String? latitude;
  final String? longitude;
  final String? createdAt;
  final String? updatedAt;

  DistributorData({
    required this.id,
    this.uniqueName,
    this.name,
    this.cityId,
    this.stateId,
    this.firmName,
    this.address,
    this.transferValidator,
    this.salesValidator,
    this.allowSync,
    this.returnValidator,
    this.isCustomer,
    this.financeLocationId,
    this.financeLocations,
    this.financeCustomerId,
    this.customerStatus,
    this.isUploaded,
    this.isDeleted,
    this.isThirdParty,
    this.isBlocked,
    this.isUpdatedProfile,
    this.isSelfOnboarding,
    this.points,
    this.availablePoints,
    this.blockedPoints,
    this.utilizePoints,
    this.bonusPoints,
    this.recordUid,
    this.expiredPoints,
    this.revokePoints,
    this.email,
    this.lastSyncAt,
    this.syncError,
    this.tsmIds,
    this.phone,
    this.syncCode,
    this.fcmToken,
    this.jwtToken,
    this.upiNo,
    this.estDate,
    this.code,
    this.gstNo,
    this.panNo,
    this.licenseNo,
    this.useCounter,
    this.otpDuration,
    this.dob,
    this.countryCode,
    this.profilePicture,
    this.cityName,
    this.pinCode,
    this.zoneId,
    this.regionId,
    this.territoryId,
    this.tenantId,
    this.apiKey,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  factory DistributorData.fromJson(Map<String, dynamic> json) {
    return DistributorData(
      id: DistributorByIdResponse._toString(json["id"]),
      uniqueName: DistributorByIdResponse._toString(json["unique_name"]),
      name: DistributorByIdResponse._toString(json["name"]),
      cityId: DistributorByIdResponse._toInt(json["city_id"]),
      stateId: DistributorByIdResponse._toInt(json["state_id"]),
      firmName: DistributorByIdResponse._toString(json["firm_name"]),
      address: DistributorByIdResponse._toString(json["address"]),
      transferValidator: DistributorByIdResponse._toBool(json["transfer_validator"]),
      salesValidator: DistributorByIdResponse._toBool(json["sales_validator"]),
      allowSync: DistributorByIdResponse._toBool(json["allow_sync"]),
      returnValidator: DistributorByIdResponse._toBool(json["return_validator"]),
      isCustomer: DistributorByIdResponse._toBool(json["is_customer"]),
      financeLocationId: json["finance_location_id"],
      financeLocations: json["finance_locations"] != null
          ? List<dynamic>.from(json["finance_locations"])
          : null,
      financeCustomerId: json["finance_customer_id"],
      customerStatus: DistributorByIdResponse._toBool(json["customer_status"]),
      isUploaded: DistributorByIdResponse._toBool(json["is_uploaded"]),
      isDeleted: DistributorByIdResponse._toBool(json["is_deleted"]),
      isThirdParty: DistributorByIdResponse._toBool(json["is_third_party"]),
      isBlocked: DistributorByIdResponse._toBool(json["is_blocked"]),
      isUpdatedProfile: DistributorByIdResponse._toBool(json["is_updated_profile"]),
      isSelfOnboarding: DistributorByIdResponse._toBool(json["is_self_onboarding"]),
      points: DistributorByIdResponse._toInt(json["points"]),
      availablePoints: DistributorByIdResponse._toInt(json["available_points"]),
      blockedPoints: DistributorByIdResponse._toInt(json["blocked_points"]),
      utilizePoints: DistributorByIdResponse._toInt(json["utilize_points"]),
      bonusPoints: DistributorByIdResponse._toInt(json["bonus_points"]),
      recordUid: DistributorByIdResponse._toString(json["record_uid"]),
      expiredPoints: DistributorByIdResponse._toInt(json["expired_points"]),
      revokePoints: DistributorByIdResponse._toInt(json["revoke_points"]),
      email: DistributorByIdResponse._toString(json["email"]),
      lastSyncAt: DistributorByIdResponse._toString(json["last_sync_at"]),
      syncError: DistributorByIdResponse._toString(json["sync_error"]),
      tsmIds: json["tsm_ids"] != null ? List<String>.from(json["tsm_ids"]) : null,
      phone: DistributorByIdResponse._toString(json["phone"]),
      syncCode: DistributorByIdResponse._toString(json["sync_code"]),
      fcmToken: DistributorByIdResponse._toString(json["fcm_token"]),
      jwtToken: DistributorByIdResponse._toString(json["jwt_token"]),
      upiNo: DistributorByIdResponse._toString(json["upi_no"]),
      estDate: DistributorByIdResponse._toString(json["est_date"]),
      code: DistributorByIdResponse._toString(json["code"]),
      gstNo: DistributorByIdResponse._toString(json["gst_no"]),
      panNo: DistributorByIdResponse._toString(json["pan_no"]),
      licenseNo: DistributorByIdResponse._toString(json["license_no"]),
      useCounter: DistributorByIdResponse._toInt(json["use_counter"]),
      otpDuration: DistributorByIdResponse._toString(json["otp_duration"]),
      dob: DistributorByIdResponse._toString(json["dob"]),
      countryCode: DistributorByIdResponse._toString(json["country_code"]),
      profilePicture: DistributorByIdResponse._toString(json["profile_picture"]),
      cityName: DistributorByIdResponse._toString(json["city_name"]),
      pinCode: DistributorByIdResponse._toString(json["pin_code"]),
      zoneId: DistributorByIdResponse._toString(json["zone_id"]),
      regionId: DistributorByIdResponse._toString(json["region_id"]),
      territoryId: DistributorByIdResponse._toString(json["territory_id"]),
      tenantId: DistributorByIdResponse._toString(json["tenant_id"]),
      apiKey: DistributorByIdResponse._toString(json["api_key"]),
      latitude: DistributorByIdResponse._toString(json["latitude"]),
      longitude: DistributorByIdResponse._toString(json["longitude"]),
      createdAt: DistributorByIdResponse._toString(json["created_at"]),
      updatedAt: DistributorByIdResponse._toString(json["updated_at"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "unique_name": uniqueName,
      "name": name,
      "city_id": cityId,
      "state_id": stateId,
      "firm_name": firmName,
      "address": address,
      "transfer_validator": transferValidator,
      "sales_validator": salesValidator,
      "allow_sync": allowSync,
      "return_validator": returnValidator,
      "is_customer": isCustomer,
      "finance_location_id": financeLocationId,
      "finance_locations": financeLocations,
      "finance_customer_id": financeCustomerId,
      "customer_status": customerStatus,
      "is_uploaded": isUploaded,
      "is_deleted": isDeleted,
      "is_third_party": isThirdParty,
      "is_blocked": isBlocked,
      "is_updated_profile": isUpdatedProfile,
      "is_self_onboarding": isSelfOnboarding,
      "points": points,
      "available_points": availablePoints,
      "blocked_points": blockedPoints,
      "utilize_points": utilizePoints,
      "bonus_points": bonusPoints,
      "record_uid": recordUid,
      "expired_points": expiredPoints,
      "revoke_points": revokePoints,
      "email": email,
      "last_sync_at": lastSyncAt,
      "sync_error": syncError,
      "tsm_ids": tsmIds,
      "phone": phone,
      "sync_code": syncCode,
      "fcm_token": fcmToken,
      "jwt_token": jwtToken,
      "upi_no": upiNo,
      "est_date": estDate,
      "code": code,
      "gst_no": gstNo,
      "pan_no": panNo,
      "license_no": licenseNo,
      "use_counter": useCounter,
      "otp_duration": otpDuration,
      "dob": dob,
      "country_code": countryCode,
      "profile_picture": profilePicture,
      "city_name": cityName,
      "pin_code": pinCode,
      "zone_id": zoneId,
      "region_id": regionId,
      "territory_id": territoryId,
      "tenant_id": tenantId,
      "api_key": apiKey,
      "latitude": latitude,
      "longitude": longitude,
      "created_at": createdAt,
      "updated_at": updatedAt,
    };
  }
}
