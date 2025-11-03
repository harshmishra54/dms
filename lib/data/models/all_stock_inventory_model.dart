// focus_product_stock_model.dart
// focus_product_stock_request.dart

class FocusProductStockRequest {
  final String locationId;

  FocusProductStockRequest({required this.locationId});

  Map<String, dynamic> toJson() {
    return {
      'locationId': locationId,
    };
  }
}

class FocusProductStockResponse {
  final int success;
  final String message;
  final FocusProductStockData data;

  FocusProductStockResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory FocusProductStockResponse.fromJson(Map<String, dynamic> json) {
    return FocusProductStockResponse(
      success: json['success'],
      message: json['message'],
      data: FocusProductStockData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class FocusProductStockData {
  final int F;
  final int B;
  final int S;

  FocusProductStockData({
    required this.F,
    required this.B,
    required this.S,
  });

  factory FocusProductStockData.fromJson(Map<String, dynamic> json) {
    return FocusProductStockData(
      F: json['Focus'],
      B: json['Seasonal'],
      S: json['Scheme'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Focus': F,
      'Seasonal': B,
      'Scheme': S,
    };
  }
}
