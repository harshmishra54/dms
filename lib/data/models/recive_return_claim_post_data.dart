class ReceiveReturnClaimPostData {
  final String roleId;
  final String requestId;

  ReceiveReturnClaimPostData({
    required this.roleId,
    required this.requestId,
  });

  Map<String, dynamic> toJson() {
    return {
      "role_id": roleId,
      "request_id": requestId,
    };
  }
}
