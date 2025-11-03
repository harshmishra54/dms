class UpdateRouteStatusRequest {
  final String dailyRouteId;
  final String tsmId;
  final bool isUnfollow;

  UpdateRouteStatusRequest({
    required this.dailyRouteId,
    required this.tsmId,
    required this.isUnfollow,
  });

  Map<String, dynamic> toJson() {
    return {
      'daily_route_id': dailyRouteId,
      'tsm_id': tsmId,
      'is_unfollow': isUnfollow,
    };
  }
}
