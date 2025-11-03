class ProfileUpdateResponse {
  final int success;
  final String message;

  ProfileUpdateResponse({required this.success, required this.message});

  factory ProfileUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateResponse(
      success: int.tryParse(json['success'].toString()) ?? 0,
      message: json['message']?.toString() ?? '',
    );
  }
}
