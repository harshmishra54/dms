// attendance_provider.dart
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/attendance_status_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class AttendanceProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AttendanceStatusModel? _attendanceStatus;
  AttendanceStatusModel? get attendanceStatus => _attendanceStatus;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Check Attendance Status
  Future<void> checkAttendanceStatus() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token from SharedPreferences
      final token = await SharedPrefsHelper.getAccessToken();

      // Make API call with x-access-token header
      Response response = await _dioClient.get(
        ApiEndpoints.attendancestatus,
        options: Options(
          headers: {
            'x-access-token': token ?? '',
          },
        ),
      );

      if (response.statusCode == 200) {
        _attendanceStatus = AttendanceStatusModel.fromJson(response.data);
      } else {
        _errorMessage =
        'Failed to fetch attendance. Status Code: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
