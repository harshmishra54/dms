// Request model
class ProductLevelRequest {
  final String uniqueCode;

  ProductLevelRequest({required this.uniqueCode});

  Map<String, dynamic> toJson() {
    return {
      "uniqueCode": uniqueCode,
    };
  }
}

// Response model
class ProductLevelResponse {
  final int success;
  final String message;
  final String level;
  final String uniqueCode;
  final String codeUID;

  ProductLevelResponse({
    required this.success,
    required this.message,
    required this.level,
    required this.uniqueCode,
    required this.codeUID,
  });

  factory ProductLevelResponse.fromJson(Map<String, dynamic> json) {
    return ProductLevelResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      level: json['level'] ?? '',
      uniqueCode: json['uniqueCode'] ?? '',
      codeUID: json['codeUID'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'level': level,
      'uniqueCode': uniqueCode,
      'codeUID': codeUID,
    };
  }
}
