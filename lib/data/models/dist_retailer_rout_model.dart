// file: lib/data/models/dist_retailer_rout_model.dart
import 'dart:convert';

/// Helpers
int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  final s = v.toString();
  return int.tryParse(s);
}

String? _parseString(dynamic v) {
  if (v == null) return null;
  return v.toString();
}

bool? _parseBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  final s = v.toString().toLowerCase();
  if (s == 'true' || s == '1') return true;
  if (s == 'false' || s == '0') return false;
  return null;
}

List<String>? _parseStringList(dynamic v) {
  if (v == null) return null;
  if (v is List) return v.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
  return null;
}

/// Top-level response model
class TerritoryResponse {
  final int success;
  final String message;
  final List<TerritoryData> data;

  TerritoryResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TerritoryResponse.fromJson(Map<String, dynamic> json) {
    return TerritoryResponse(
      success: _parseInt(json['success']) ?? 0,
      message: _parseString(json['message']) ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => TerritoryData.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

/// Individual Distributor/Retailer data (robust parsing)
class TerritoryData {
  final String id;
  final String? uniqueName;
  final String? name;
  final int? cityId;
  final int? stateId;
  final String? firmName;
  final String? address;
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
  final String? licenceNo;
  final String? tenantId;
  final String? apiKey;
  final String? createdAt;
  final String? updatedAt;
  final int? accepted;
  final int? pending;
  final int? rejected;
  final int? approved;

  // Some extra common flags / fields that appear in responses
  final bool? isCustomer;
  final bool? isDeleted;
  final int? points;
  final int? availablePoints;
  final List<String>? tsmIds;
  final List<dynamic>? financeLocations; // keep dynamic in case it is list of maps

  TerritoryData({
    required this.id,
    this.uniqueName,
    this.name,
    this.cityId,
    this.stateId,
    this.firmName,
    this.address,
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
    this.licenceNo,
    this.tenantId,
    this.apiKey,
    this.createdAt,
    this.updatedAt,
    this.isCustomer,
    this.isDeleted,
    this.points,
    this.availablePoints,
    this.tsmIds,
    this.financeLocations,
    this.accepted,
    this.approved,
    this.pending,
    this.rejected,
  });

  factory TerritoryData.fromJson(Map<String, dynamic> json) {
    return TerritoryData(
      id: _parseString(json['id']) ?? '',
      uniqueName: _parseString(json['unique_name']),
      name: _parseString(json['name']),
      cityId: _parseInt(json['city_id']),
      stateId: _parseInt(json['state_id']),
      firmName: _parseString(json['firm_name']),
      address: _parseString(json['address']),
      phone: _parseString(json['phone']),
      syncCode: _parseString(json['sync_code']),
      fcmToken: _parseString(json['fcm_token']),
      jwtToken: _parseString(json['jwt_token']),
      upiNo: _parseString(json['upi_no']),
      estDate: _parseString(json['est_date']),
      code: _parseString(json['code']),
      gstNo: _parseString(json['gst_no']),
      panNo: _parseString(json['pan_no']),
      licenseNo: _parseString(json['license_no']),
      useCounter: _parseInt(json['use_counter']),
      otpDuration: _parseString(json['otp_duration']),
      dob: _parseString(json['dob']),
      countryCode: _parseString(json['country_code']),
      profilePicture: _parseString(json['profile_picture']),
      cityName: _parseString(json['city_name']),
      pinCode: _parseString(json['pin_code']),
      zoneId: _parseString(json['zone_id']),
      regionId: _parseString(json['region_id']),
      territoryId: _parseString(json['territory_id']),
      licenceNo: _parseString(json['licence_no']),
      tenantId: _parseString(json['tenant_id']),
      apiKey: _parseString(json['api_key']),
      createdAt: _parseString(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseString(json['updatedAt'] ?? json['updated_at']),
      isCustomer: _parseBool(json['is_customer']),
      isDeleted: _parseBool(json['is_deleted']),
      points: _parseInt(json['points']),
      availablePoints: _parseInt(json['available_points']),
      tsmIds: _parseStringList(json['tsm_ids']),
      financeLocations: json['finance_locations'] as List<dynamic>?,
      accepted: json['accepted'],
      pending: json['pending'],
      approved: json['approved'],
      rejected: json['rejected'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unique_name': uniqueName,
      'name': name,
      'city_id': cityId,
      'state_id': stateId,
      'firm_name': firmName,
      'address': address,
      'phone': phone,
      'sync_code': syncCode,
      'fcm_token': fcmToken,
      'jwt_token': jwtToken,
      'upi_no': upiNo,
      'est_date': estDate,
      'code': code,
      'gst_no': gstNo,
      'pan_no': panNo,
      'license_no': licenseNo,
      'use_counter': useCounter,
      'otp_duration': otpDuration,
      'dob': dob,
      'country_code': countryCode,
      'profile_picture': profilePicture,
      'city_name': cityName,
      'pin_code': pinCode,
      'zone_id': zoneId,
      'region_id': regionId,
      'territory_id': territoryId,
      'licence_no': licenceNo,
      'tenant_id': tenantId,
      'api_key': apiKey,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'is_customer': isCustomer,
      'is_deleted': isDeleted,
      'points': points,
      'available_points': availablePoints,
      'tsm_ids': tsmIds,
      'finance_locations': financeLocations,
      "accepted": accepted,
      "approved": approved,
      "rejected": rejected,
      "pending": pending,
    };
  }
}

/// Helper to parse raw JSON string if needed
TerritoryResponse territoryResponseFromJson(String str) =>
    TerritoryResponse.fromJson(json.decode(str) as Map<String, dynamic>);

String territoryResponseToJson(TerritoryResponse data) =>
    json.encode(data.toJson());
