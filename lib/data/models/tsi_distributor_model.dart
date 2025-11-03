class TsiDistributorModel {
  // Request fields
  String? name;
  String? uniqueName;
  int? phoneNo;
  String? excelFile;
  bool? isCustomer;
  List<String>? tsmIds;
  List<String>? financeLocation;
  List<String>? financeLocations;
  String? firmName;
  String? address;
  String? pinCode;
  int? stateId;
  int? districtId;
  String? panNo;
  String? cityName;
  String? gstNo;
  String? licenseNo;
  double? latitude;
  double? longitude;
  String? licenseexpiry;
  String? img;

  String? zoneId;       // made nullable
  String? regionId;     // made nullable
  String? territoryId;  // made nullable

  // Response fields
  int? success;
  String? message;

  TsiDistributorModel({
    this.name,
    this.uniqueName,
    this.phoneNo,
    this.excelFile,
    this.isCustomer,
    this.tsmIds,
    this.financeLocation,
    this.financeLocations,
    this.firmName,
    this.address,
    this.pinCode,
    this.stateId,
    this.districtId,
    this.panNo,
    this.cityName,
    this.gstNo,
    this.licenseNo,
    this.latitude,
    this.longitude,
    this.zoneId,
    this.regionId,
    this.territoryId,
    this.success,
    this.message,
    this.licenseexpiry,
    this.img,
  });

  factory TsiDistributorModel.fromJson(Map<String, dynamic> json) {
    return TsiDistributorModel(
      name: json['name'],
      uniqueName: json['uniqueName'],
      phoneNo: json['phoneNo'],
      excelFile: json['excelFile'],
      isCustomer: json['is_customer'],
      tsmIds: json['tsm_ids'] != null ? List<String>.from(json['tsm_ids']) : null,
      financeLocation: json['financeLocation'] != null
          ? List<String>.from(json['financeLocation'])
          : null,
      financeLocations: json['finance_locations'] != null
          ? List<String>.from(json['finance_locations'])
          : null,
      firmName: json['firm_name'],
      address: json['address'],
      pinCode: json['pin_code'],
      stateId: json['state_id'],
      districtId: json['district_id'],
      panNo: json['pan_no'],
      cityName: json['city_name'],
      gstNo: json['gst_no'],
      licenseNo: json['license_no'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      licenseexpiry: json['licence_expiry'],
      img: json['img'],
      zoneId: json['zone_id'],
      regionId: json['region_id'],
      territoryId: json['territory_id'],
      success: json['success'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'uniqueName': uniqueName,
      'phoneNo': phoneNo,
      'excelFile': excelFile,
      'is_customer': isCustomer,
      'tsm_ids': tsmIds,
      'financeLocation': financeLocation,
      'finance_locations': financeLocations,
      'firm_name': firmName,
      'address': address,
      'pin_code': pinCode,
      'zone_id': zoneId,
      'region_id': regionId,
      'territory_id': territoryId,
      'state_id': stateId,
      'district_id': districtId,
      'pan_no': panNo,
      'city_name': cityName,
      'gst_no': gstNo,
      'license_no': licenseNo,
      'latitude': latitude,
      'longitude': longitude,
      'licence_expiry': licenseexpiry,
      'img': img,
      // 🚫 success & message removed from request JSON
    };
  }
}
