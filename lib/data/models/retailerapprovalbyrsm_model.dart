import 'dart:convert';

/// Top-level response model
class GetRetailRsmResponse {
  final int success;
  final List<RetailRsm> data;

  GetRetailRsmResponse({
    required this.success,
    required this.data,
  });

  factory GetRetailRsmResponse.fromJson(Map<String, dynamic> json) {
    return GetRetailRsmResponse(
      success: json['success'] is int
          ? json['success']
          : int.tryParse(json['success'].toString()) ?? 0,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => RetailRsm.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }

  static GetRetailRsmResponse fromRawJson(String str) =>
      GetRetailRsmResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
}

/// Model for each retailer RSM
class RetailRsm {
  final String id;
  final String? name;
  final String? dob;
  final String? countryCode;
  final String? phone;
  final String? firmName;
  final String? estDate;
  final String? address;
  final int? zoneId;
  final int? regionId;
  final int? territoryId;
  final int? stateId;
  final int? cityId;
  final int? pinCode;
  final String? licenseNo;
  final bool isDeleted;
  final String? createdAt;
  final String? updatedAt;
  final String? email;
  final String? jwtToken;
  final String? fcmToken;
  final String? gender;
  final String? gstNo;
  final String? panNo;
  final List<String>? distributorIds; // Fixed: API might send List
  final String? recordUid;
  final int? roleId;
  final int? points;
  final int? availablePoints;
  final int? blockedPoints;
  final int? utilizePoints;
  final int? bonusPoints;
  final bool isBlocked;
  final bool isUpdatedVersion;
  final bool? isUpdatedProfile;
  final String? latitude;
  final String? longitude;
  final int? pending;
  final int? accepted;
  final int? approved;
  final int? rejected;
  final String? licenseExpiry;

  RetailRsm({
    required this.id,
    this.name,
    this.dob,
    this.countryCode,
    this.phone,
    this.firmName,
    this.estDate,
    this.address,
    this.zoneId,
    this.regionId,
    this.territoryId,
    this.stateId,
    this.cityId,
    this.pinCode,
    this.licenseNo,
    required this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.email,
    this.jwtToken,
    this.fcmToken,
    this.gender,
    this.gstNo,
    this.panNo,
    this.distributorIds,
    this.recordUid,
    this.roleId,
    this.points,
    this.availablePoints,
    this.blockedPoints,
    this.utilizePoints,
    this.bonusPoints,
    required this.isBlocked,
    required this.isUpdatedVersion,
    this.isUpdatedProfile,
    this.latitude,
    this.longitude,
    this.pending,
    this.accepted,
    this.approved,
    this.rejected,
    this.licenseExpiry,
  });

  factory RetailRsm.fromJson(Map<String, dynamic> json) {
    List<String>? parseDistributorIds(dynamic value) {
      if (value == null) return null;
      if (value is String) return [value];
      if (value is List) return value.map((e) => e.toString()).toList();
      return null;
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value.toLowerCase() == 'true';
      return false;
    }

    return RetailRsm(
      id: json['id'] ?? '',
      name: json['name'],
      dob: json['dob'],
      countryCode: json['country_code'],
      phone: json['phone'],
      firmName: json['firm_name'],
      estDate: json['est_date'],
      address: json['address'],
      zoneId: parseInt(json['zone_id']),
      regionId: parseInt(json['region_id']),
      territoryId: parseInt(json['territory_id']),
      stateId: parseInt(json['state_id']),
      cityId: parseInt(json['city_id']),
      pinCode: parseInt(json['pin_code']),
      licenseNo: json['license_no'],
      isDeleted: parseBool(json['is_deleted']),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      email: json['email'],
      jwtToken: json['jwt_token'],
      fcmToken: json['fcm_token'],
      gender: json['gender'],
      gstNo: json['gst_no'],
      panNo: json['pan_no'],
      distributorIds: parseDistributorIds(json['distributor_ids']),
      recordUid: json['record_uid'],
      roleId: parseInt(json['role_id']),
      points: parseInt(json['points']),
      availablePoints: parseInt(json['available_points']),
      blockedPoints: parseInt(json['blocked_points']),
      utilizePoints: parseInt(json['utilize_points']),
      bonusPoints: parseInt(json['bonus_points']),
      isBlocked: parseBool(json['is_blocked']),
      isUpdatedVersion: parseBool(json['is_updated_version']),
      isUpdatedProfile: json['is_updated_profile'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      pending: parseInt(json['pending']),
      accepted: parseInt(json['accepted']),
      approved: parseInt(json['approved']),
      rejected: parseInt(json['rejected']),
      licenseExpiry: json['license_expiry'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dob': dob,
      'country_code': countryCode,
      'phone': phone,
      'firm_name': firmName,
      'est_date': estDate,
      'address': address,
      'zone_id': zoneId,
      'region_id': regionId,
      'territory_id': territoryId,
      'state_id': stateId,
      'city_id': cityId,
      'pin_code': pinCode,
      'license_no': licenseNo,
      'is_deleted': isDeleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'email': email,
      'jwt_token': jwtToken,
      'fcm_token': fcmToken,
      'gender': gender,
      'gst_no': gstNo,
      'pan_no': panNo,
      'distributor_ids': distributorIds,
      'record_uid': recordUid,
      'role_id': roleId,
      'points': points,
      'available_points': availablePoints,
      'blocked_points': blockedPoints,
      'utilize_points': utilizePoints,
      'bonus_points': bonusPoints,
      'is_blocked': isBlocked,
      'is_updated_version': isUpdatedVersion,
      'is_updated_profile': isUpdatedProfile,
      'latitude': latitude,
      'longitude': longitude,
      'pending': pending,
      'accepted': accepted,
      'approved': approved,
      'rejected': rejected,
      'license_expiry': licenseExpiry,
    };
  }
}
// Request body model for GetDisRsm API
class GetRetailRsmRequest {
  final String id;

  GetRetailRsmRequest({required this.id});

  /// Convert object to JSON (for API request body)
  Map<String, dynamic> toJson() => {
    "id": id,
  };

  /// If needed, create from JSON (not always required for request models)
  factory GetRetailRsmRequest.fromJson(Map<String, dynamic> json) {
    return GetRetailRsmRequest(
      id: json['id'] ?? "",
    );
  }

  /// Encode to raw JSON string
  String toRawJson() => json.encode(toJson());
}