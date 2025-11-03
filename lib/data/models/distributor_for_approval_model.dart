import 'dart:convert';

/// Top-level response model
class GetDisRsmResponse {
  final int success;
  final List<Distributor> data;

  GetDisRsmResponse({
    required this.success,
    required this.data,
  });

  factory GetDisRsmResponse.fromJson(Map<String, dynamic> json) {
    return GetDisRsmResponse(
      success: json['success'] ?? 0,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => Distributor.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'data': data.map((e) => e.toJson()).toList(),
  };

  static GetDisRsmResponse fromRawJson(String str) =>
      GetDisRsmResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
}

/// Distributor item model
class Distributor {
  final String? id;
  final String? uniqueName;
  final String? name;
  final int? cityId;
  final int? stateId;
  final String? firmName;
  final String? address;
  final bool? isCustomer;
  final bool? isUploaded;
  final bool? isDeleted;
  final bool? isThirdParty;
  final bool? isBlocked;
  final int? points;
  final int? availablePoints;
  final int? blockedPoints;
  final int? utilizePoints;
  final int? bonusPoints;
  final String? expiredPoints;
  final String? revokePoints;
  final String? email;
  final String? phone;
  final String? gstNo;
  final String? panNo;
  final String? licenseNo;
  final int? useCounter;
  final String? otpDuration;
  final String? dob;
  final String? cityName;
  final String? pinCode;
  final int? pending;
  final int? accepted;
  final int? approved;
  final int? rejected;
  final String? createdAt;
  final String? updatedAt;

  Distributor({
    this.id,
    this.uniqueName,
    this.name,
    this.cityId,
    this.stateId,
    this.firmName,
    this.address,
    this.isCustomer,
    this.isUploaded,
    this.isDeleted,
    this.isThirdParty,
    this.isBlocked,
    this.points,
    this.availablePoints,
    this.blockedPoints,
    this.utilizePoints,
    this.bonusPoints,
    this.expiredPoints,
    this.revokePoints,
    this.email,
    this.phone,
    this.gstNo,
    this.panNo,
    this.licenseNo,
    this.useCounter,
    this.otpDuration,
    this.dob,
    this.cityName,
    this.pinCode,
    this.pending,
    this.accepted,
    this.approved,
    this.rejected,
    this.createdAt,
    this.updatedAt,
  });

  factory Distributor.fromJson(Map<String, dynamic> json) {
    String? toStringSafe(dynamic value) {
      if (value == null) return null;
      return value.toString();
    }

    return Distributor(
      id: toStringSafe(json['id']),
      uniqueName: toStringSafe(json['unique_name']),
      name: toStringSafe(json['name']),
      cityId: json['city_id'] != null ? int.tryParse(json['city_id'].toString()) : null,
      stateId: json['state_id'] != null ? int.tryParse(json['state_id'].toString()) : null,
      firmName: toStringSafe(json['firm_name']),
      address: toStringSafe(json['address']),
      isCustomer: json['is_customer'],
      isUploaded: json['is_uploaded'],
      isDeleted: json['is_deleted'],
      isThirdParty: json['is_third_party'],
      isBlocked: json['is_blocked'],
      points: json['points'] != null ? int.tryParse(json['points'].toString()) : null,
      availablePoints: json['available_points'] != null ? int.tryParse(json['available_points'].toString()) : null,
      blockedPoints: json['blocked_points'] != null ? int.tryParse(json['blocked_points'].toString()) : null,
      utilizePoints: json['utilize_points'] != null ? int.tryParse(json['utilize_points'].toString()) : null,
      bonusPoints: json['bonus_points'] != null ? int.tryParse(json['bonus_points'].toString()) : null,
      expiredPoints: toStringSafe(json['expired_points']),
      revokePoints: toStringSafe(json['revoke_points']),
      email: toStringSafe(json['email']),
      phone: toStringSafe(json['phone']),
      gstNo: toStringSafe(json['gst_no']),
      panNo: toStringSafe(json['pan_no']),
      licenseNo: toStringSafe(json['license_no']),
      useCounter: json['use_counter'] != null ? int.tryParse(json['use_counter'].toString()) : null,
      otpDuration: toStringSafe(json['otp_duration']),
      dob: toStringSafe(json['dob']),
      cityName: toStringSafe(json['city_name']),
      pinCode: toStringSafe(json['pin_code']),
      pending: json['pending'] != null ? int.tryParse(json['pending'].toString()) : null,
      accepted: json['accepted'] != null ? int.tryParse(json['accepted'].toString()) : null,
      approved: json['approved'] != null ? int.tryParse(json['approved'].toString()) : null,
      rejected: json['rejected'] != null ? int.tryParse(json['rejected'].toString()) : null,
      createdAt: toStringSafe(json['createdAt']),
      updatedAt: toStringSafe(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'unique_name': uniqueName,
    'name': name,
    'city_id': cityId,
    'state_id': stateId,
    'firm_name': firmName,
    'address': address,
    'is_customer': isCustomer,
    'is_uploaded': isUploaded,
    'is_deleted': isDeleted,
    'is_third_party': isThirdParty,
    'is_blocked': isBlocked,
    'points': points,
    'available_points': availablePoints,
    'blocked_points': blockedPoints,
    'utilize_points': utilizePoints,
    'bonus_points': bonusPoints,
    'expired_points': expiredPoints,
    'revoke_points': revokePoints,
    'email': email,
    'phone': phone,
    'gst_no': gstNo,
    'pan_no': panNo,
    'license_no': licenseNo,
    'use_counter': useCounter,
    'otp_duration': otpDuration,
    'dob': dob,
    'city_name': cityName,
    'pin_code': pinCode,
    'pending': pending,
    'accepted': accepted,
    'approved': approved,
    'rejected': rejected,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}
/// Request body model for GetDisRsm API
class GetDisRsmRequest {
  final String id;

  GetDisRsmRequest({required this.id});

  /// Convert object to JSON (for API request body)
  Map<String, dynamic> toJson() => {
    "id": id,
  };

  /// If needed, create from JSON (not always required for request models)
  factory GetDisRsmRequest.fromJson(Map<String, dynamic> json) {
    return GetDisRsmRequest(
      id: json['id'] ?? "",
    );
  }

  /// Encode to raw JSON string
  String toRawJson() => json.encode(toJson());
}
