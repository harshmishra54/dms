class OfferPoint {
  final String success;
  final String message;
  final OfferData? data;

  OfferPoint({required this.success, required this.message, this.data});

  // Factory method to create an OfferPoint object from a map
  factory OfferPoint.fromJson(Map<String, dynamic> json) {
    return OfferPoint(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? OfferData.fromJson(json['data']) : null,
    );
  }

  // Method to convert OfferPoint object to map
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class OfferData {
  final String points;
  final String availablePoints;
  final String utilizePoints;

  OfferData({
    required this.points,
    required this.availablePoints,
    required this.utilizePoints,
  });

  // Factory method to create OfferData from map
  factory OfferData.fromJson(Map<String, dynamic> json) {
    return OfferData(
      points: json['points'],
      availablePoints: json['available_points'],
      utilizePoints: json['utilize_points'],
    );
  }

  // Method to convert OfferData to map
  Map<String, dynamic> toJson() {
    return {
      'points': points,
      'available_points': availablePoints,
      'utilize_points': utilizePoints,
    };
  }
}
