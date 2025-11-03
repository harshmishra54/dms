// attendance_provider.dart
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/attendance_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';


class AttendanceSubmitProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  AttendanceResponse? _attendanceResponse;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  AttendanceResponse? get attendanceResponse => _attendanceResponse;

  final DioClient _dioClient = DioClient();

  Future<void> submitAttendance(AttendanceRequest request) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Get token from shared prefs
      String? token = await SharedPrefsHelper.getAccessToken();

      Options options = Options(
        headers: {
          'x-access-token': token ?? '',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      Response response = await _dioClient.post(
        ApiEndpoints.attendancesubmit,
        data: request.toJson(),
        options: options,
      );

      // Parse response
      _attendanceResponse = AttendanceResponse.fromJson(response.data);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearResponse() {
    _attendanceResponse = null;
    _errorMessage = '';
    notifyListeners();
  }
}
