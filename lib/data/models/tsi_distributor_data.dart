class TsiDistributorData {
  final String? id;
  final String? name;
  final String? firmName;
  final String? phone;

  TsiDistributorData({
    this.id,
    this.name,
    this.firmName,
    this.phone,
  });

  factory TsiDistributorData.fromJson(Map<String, dynamic> json) {
    return TsiDistributorData(
      id: json['id'],
      name: json['name'],
      firmName: json['firm_name'],
      phone: json['phone'],
    );
  }
}

class TsiDistributorResponse {
  final int? success;
  final String? message;
  final List<TsiDistributorData>? data;

  TsiDistributorResponse({
    this.success,
    this.message,
    this.data,
  });

  factory TsiDistributorResponse.fromJson(Map<String, dynamic> json) {
    return TsiDistributorResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? List<TsiDistributorData>.from(
          json['data'].map((item) => TsiDistributorData.fromJson(item)))
          : [],
    );
  }
}
