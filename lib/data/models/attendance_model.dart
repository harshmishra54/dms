// attendance_model.dart

class AttendanceRequest {
  int type;
  String reason;
  String latLong;
  String attendancePhoto;

  AttendanceRequest({
    required this.type,
    required this.reason,
    required this.latLong,
    required this.attendancePhoto,
  });

  factory AttendanceRequest.fromJson(Map<String, dynamic> json) {
    return AttendanceRequest(
      type: json['type'],
      reason: json['reason'],
      latLong: json['lat_long'],
      attendancePhoto: json['attendance_photo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'reason': reason,
      'lat_long': latLong,
      'attendance_photo': attendancePhoto,
    };
  }
}

class AttendanceResponse {
  int success;
  String message;

  AttendanceResponse({
    required this.success,
    required this.message,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      success: json['success'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
}
