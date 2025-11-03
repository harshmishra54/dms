class ScanCodeResponse {
  final int success;
  final String message;

  ScanCodeResponse({
    required this.success,
    required this.message,
  });

  factory ScanCodeResponse.fromJson(Map<String, dynamic> json) {
    return ScanCodeResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}
