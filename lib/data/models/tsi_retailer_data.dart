class TsiRetailerRequest {
  final String tsmId;

  TsiRetailerRequest({required this.tsmId});

  Map<String, dynamic> toJson() => {
    "tsm_id": tsmId,
  };
}
//
class TsiRetailerResponse {
  final int success;
  final String message;
  final List<TsiRetailerData>? data;

  TsiRetailerResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory TsiRetailerResponse.fromJson(Map<String, dynamic> json) {
    return TsiRetailerResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? List<TsiRetailerData>.from(
          json['data'].map((x) => TsiRetailerData.fromJson(x)))
          : null,
    );
  }
}

class TsiRetailerData {
  final String? id;
  final String? uniqueName;
  final String? name;
  final String? firmName;
  final String? phone;

  TsiRetailerData({
    this.id,
    this.uniqueName,
    this.name,
    this.firmName,
    this.phone,
  });

  factory TsiRetailerData.fromJson(Map<String, dynamic> json) {
    return TsiRetailerData(
      id: json['id'],
      uniqueName: json['unique_name'],
      name: json['name'],
      firmName: json['firm_name'],
      phone: json['phone'],
    );
  }
}
