import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/data/models/leave_calender_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';

class LeaveCalendarProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  LeaveCalendarResponse? _leaveCalendar;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  LeaveCalendarResponse? get leaveCalendar => _leaveCalendar;
  String? get errorMessage => _errorMessage;

  /// Fetch leave calendar
  Future<void> fetchLeaveCalendar({required String userId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token from SharedPreferences
      final token = await SharedPrefsHelper.getAccessToken();

      if (token == null || token.isEmpty) {
        _errorMessage = "User not authenticated";
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Prepare request body
      final requestBody = LeaveCalendarRequest(id: userId).toJson();

      // Set headers including x-access-token
      final Options options = Options(
        headers: {
          'x-access-token': token,
          'Content-Type': 'application/json',
        },
      );

      // API call
      final Response response = await _dioClient.post(
        ApiEndpoints.leavecalenderlist,
        data: requestBody,
        options: options,
      );

      if (response.statusCode == 200) {
        _leaveCalendar = LeaveCalendarResponse.fromJson(response.data);
      } else {
        _errorMessage = "Failed to load data: ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear previous data
  void clear() {
    _leaveCalendar = null;
    _errorMessage = null;
    notifyListeners();
  }
}
