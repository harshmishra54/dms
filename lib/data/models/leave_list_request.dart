class LeaveListRequest {
  final int roleId;
  final String requestId;

  LeaveListRequest({
    required this.roleId,
    required this.requestId,
  });

  Map<String, dynamic> toJson() => {
    "role_id": roleId,
    "request_id": requestId,
  };
}
