class ScanResponse {
  final int success;
  final String message;
  final SchemeData? data;

  ScanResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ScanResponse.fromJson(Map<String, dynamic> json) {
    return ScanResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? SchemeData.fromJson(json['data']) : null,
    );
  }
}

class SchemeData {
  final String? productName; // name of the scheme
  final int? points;        // points earned
  final String? schemeUID;  // UID of the scheme
  final String? message;

  SchemeData({this.productName, this.points, this.schemeUID,this.message});

  factory SchemeData.fromJson(Map<String, dynamic> json) {
    return SchemeData(
      productName: json['productName'],   // make sure this matches API key
      points: json['points'],           // make sure this matches API key
      schemeUID: json['uid'],
      message: json['msg']// make sure this matches API key
    );
  }
}
