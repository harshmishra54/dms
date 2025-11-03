class CustomerDetailsResponse {
  final String success;
  final String? data; // encrypted string

  CustomerDetailsResponse({
    required this.success,
    this.data,
  });

  factory CustomerDetailsResponse.fromJson(Map<String, dynamic> json) {
    return CustomerDetailsResponse(
      success: json['success']?.toString() ?? '',
      data: json['data'] as String?,
    );
  }
}

/// After decryption
class CustomerData {
  final String id;
  final String uniqueName;
  final String name;
  final int? cityId;
  final int? stateId;
  final String? firmName;
  final String? address;
  final String? transferValidator;
  final String? salesValidator;
  final String? allowSync;
  final String? returnValidator;
  final bool isCustomer;
  final int? financeLocationId;
  final List<dynamic> financeLocations;
  final int? financeCustomerId;
  final bool customerStatus;
  final bool isUploaded;
  final bool isDeleted;
  final bool isThirdParty;
  final bool isBlocked;
  final bool isUpdatedProfile;
  final int points;
  final int availablePoints;
  final int blockedPoints;
  final int utilizePoints;
  final int bonusPoints;
  final String? recordUid;
  final String? lastSyncAt;
  final String? syncError;
  final List<String?> tsmIds; // allow null inside list
  final String? phone;
  final String? syncCode;
  final String? fcmToken;
  final String? jwtToken;
  final int invalidScan;
  final String? code;
  final String? gstNo;
  final String? panNo;
  final String? licenseNo;
  final int? pinCode;
  final String? zoneId;
  final String? regionId;
  final String? territoryId;
  final String? licenceNo;
  final String? tenantId;
  final String? apiKey;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? cityDistrictId;
  final String? licenseexpiry;

  CustomerData({
    required this.id,
    required this.uniqueName,
    required this.name,
    this.cityId,
    this.stateId,
    this.firmName,
    this.address,
    this.transferValidator,
    this.salesValidator,
    this.allowSync,
    this.returnValidator,
    required this.isCustomer,
    this.financeLocationId,
    required this.financeLocations,
    this.financeCustomerId,
    required this.customerStatus,
    required this.isUploaded,
    required this.isDeleted,
    required this.isThirdParty,
    required this.isBlocked,
    required this.isUpdatedProfile,
    required this.points,
    required this.availablePoints,
    required this.blockedPoints,
    required this.utilizePoints,
    required this.bonusPoints,
    this.recordUid,
    this.lastSyncAt,
    this.syncError,
    required this.tsmIds,
    this.phone,
    this.syncCode,
    this.fcmToken,
    this.jwtToken,
    required this.invalidScan,
    this.code,
    this.gstNo,
    this.panNo,
    this.licenseNo,
    this.pinCode,
    this.zoneId,
    this.regionId,
    this.territoryId,
    this.licenceNo,
    this.tenantId,
    this.apiKey,
    this.createdAt,
    this.updatedAt,
    this.cityDistrictId,
    this.licenseexpiry,
  });

  factory CustomerData.fromJson(Map<String, dynamic> json) {
    return CustomerData(
      id: json['id']?.toString() ?? '',
      uniqueName: json['unique_name']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      cityId: json['city_id'],
      stateId: json['state_id'],
      firmName: json['firm_name'],
      address: json['address'],
      transferValidator: json['transfer_validator'],
      salesValidator: json['sales_validator'],
      allowSync: json['allow_sync'],
      returnValidator: json['return_validator'],
      isCustomer: json['is_customer'] ?? false,
      financeLocationId: json['finance_location_id'],
      financeLocations: json['finance_locations'] ?? [],
      financeCustomerId: json['finance_customer_id'],
      customerStatus: json['customer_status'] ?? false,
      isUploaded: json['is_uploaded'] ?? false,
      isDeleted: json['is_deleted'] ?? false,
      isThirdParty: json['is_third_party'] ?? false,
      isBlocked: json['is_blocked'] ?? false,
      isUpdatedProfile: json['is_updated_profile'] ?? false,
      points: json['points'] ?? 0,
      availablePoints: json['available_points'] ?? 0,
      blockedPoints: json['blocked_points'] ?? 0,
      utilizePoints: json['utilize_points'] ?? 0,
      bonusPoints: json['bonus_points'] ?? 0,
      recordUid: json['record_uid'],
      lastSyncAt: json['last_sync_at'],
      syncError: json['sync_error'],
      tsmIds: (json['tsm_ids'] as List<dynamic>?)
          ?.map((e) => e?.toString())
          .toList() ??
          [], // safe parsing
      phone: (json['phone'] ?? json['mobile_no'])?.toString(),
      syncCode: json['sync_code'],
      fcmToken: json['fcm_token'],
      jwtToken: json['jwt_token'],
      invalidScan: json['invaild_scan'] ?? 0,
      code: json['code'],
      gstNo: json['gst_no'],
      panNo: json['pan_no'],
      licenseNo: json['license_no'],
      pinCode: json['pin_code'],
      zoneId: json['zone_id'],
      regionId: json['region_id'],
      territoryId: json['territory_id'],
      licenceNo: json['license_no'],
      tenantId: json['tenant_id'],
      apiKey: json['api_key'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      cityDistrictId: json['city.district_id'],
      licenseexpiry: json['license_expiry'],
    );
  }
}
