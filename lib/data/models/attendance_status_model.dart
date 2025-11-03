// attendance_status_model.dart

class AttendanceStatusModel {
  final int success;
  final String message;
  final bool data;

  AttendanceStatusModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AttendanceStatusModel.fromJson(Map<String, dynamic> json) {
    return AttendanceStatusModel(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
    };
  }
}
