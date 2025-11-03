class RouteDetailsRequest {
  final String dailyRouteId;
  final String locationId;

  RouteDetailsRequest({
    required this.dailyRouteId,
    required this.locationId,
  });

  Map<String, dynamic> toJson() {
    return {
      'daily_route_id': dailyRouteId,
      'location_id': locationId,
    };
  }
}
