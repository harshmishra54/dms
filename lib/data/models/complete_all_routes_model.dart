// route_response_model.dart
class RouteResponse {
  final int success;
  final String message;

  RouteResponse({required this.success, required this.message});

  // Factory constructor to create an instance from JSON
  factory RouteResponse.fromJson(Map<String, dynamic> json) {
    return RouteResponse(
      success: json['success'],
      message: json['message'],
    );
  }

  // Convert instance to JSON (if needed)
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
}

// Optional: request model
class SubmitRouteRequest {
  final String routeId;
  final String? reason;

  SubmitRouteRequest({required this.routeId,this.reason});

  Map<String, dynamic> toJson() {
    return {
      'route_id': routeId,
      'reason': reason,
    };
  }
}
