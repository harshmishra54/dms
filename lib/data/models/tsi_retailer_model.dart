class RetailerRequest {
  String? type;
  String? name;
  String? dob;
  int? phone;
  String? address;
  String? zoneId;
  String? regionId;
  String? territoryId;
  String? districtId;
  String? talukaId;
  String? stateId;
  String? cityId;
  double? latitude;  // ✅ added
  double? longitude; // ✅ added
  List<RetailerDistributor>? distributorIds;
  String? panNo;
  String? gstNo;
  String? priFirm;
  List<String>? secFirms;
  List<String>? secNums;
  String? estDate;
  bool? isZrtBased;
  String? requestedId;
  String? area;
  String? licenseNo;
  String? Pincode;
  String? requestId;

  RetailerRequest({
    this.type,
    this.name,
    this.dob,
    this.phone,
    this.address,
    this.zoneId,
    this.regionId,
    this.territoryId,
    this.districtId,
    this.talukaId,
    this.stateId,
    this.cityId,
    this.latitude,  // ✅ added
    this.longitude, // ✅ added
    this.distributorIds,
    this.panNo,
    this.gstNo,
    this.priFirm,
    this.secFirms,
    this.secNums,
    this.estDate,
    this.isZrtBased,
    this.requestedId,
    this.area,
    this.licenseNo,
    this.Pincode,
    this.requestId,

  });

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "name": name,
      "dob": dob,
      "phone": phone,
      "address": address,
      "zone_id": zoneId,
      "region_id": regionId,
      "territory_id": territoryId,
      "districtId": districtId,
      "talukaId": talukaId,
      "state_id": stateId,
      "city_id": cityId,
      "latitude": latitude,   // ✅ added
      "longitude": longitude, // ✅ added
      "distributor_ids": distributorIds?.map((e) => e.toJson()).toList(),
      "pan_no": panNo,
      "gst_no": gstNo,
      "pri_firm": priFirm,
      "sec_firms": secFirms,
      "sec_nums": secNums,
      "est_date": estDate,
      "isZrtBased": isZrtBased,
      "area": area,
      "license_no": licenseNo,
      "pin_code": Pincode,
      "request_id": requestId,
    };
  }
}

class RetailerDistributor {
  String id;
  String name;

  RetailerDistributor({required this.id, required this.name});

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name};
  }
}

class RetailerResponse {
  String success;
  String? message;

  RetailerResponse({required this.success, required this.message});

  factory RetailerResponse.fromJson(Map<String, dynamic> json) {
    return RetailerResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}
