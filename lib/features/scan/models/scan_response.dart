class ScanResponse {
  final int success;
  final String message;
  final dynamic data;  // ✅ allow String OR object
  final List<Segment>? segments;

  ScanResponse({
    required this.success,
    required this.message,
    this.data,
    this.segments,
  });

  factory ScanResponse.fromJson(Map<String, dynamic> json) {
    return ScanResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'], // ✅ accept any type (string here)
      segments: json['segments'] != null
          ? List<Segment>.from(
        json['segments'].map((x) => Segment.fromJson(x)),
      )
          : null,
    );
  }
}


class SchemeData {
  final String? productName;
  final int? points;
  final String? schemeUID;
  final String? message;
  final String? spinnerId;

  SchemeData({
    this.productName,
    this.points,
    this.schemeUID,
    this.message,
    this.spinnerId

  });

  factory SchemeData.fromJson(Map<String, dynamic> json) {
    return SchemeData(
      productName: json['productName'],
      points: json['points'],
      schemeUID: json['uid'],
      message: json['msg'],
      spinnerId: json['spinner_id'],
    );
  }
}

class Segment {
  final int? point;
  final int? probability;

  Segment({
    this.point,
    this.probability,
  });

  factory Segment.fromJson(Map<String, dynamic> json) {
    return Segment(
      point: json['point'],
      probability: json['probability'],
    );
  }
}
