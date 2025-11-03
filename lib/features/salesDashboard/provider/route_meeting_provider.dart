// route_meeting_provider.dart

import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/rout_meeting_list_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class RouteMeetingProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  List<RouteMeetingData> _meetings = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<RouteMeetingData> get meetings => _meetings;

  /// Fetch route meetings with dynamic request body
  Future<void> fetchRouteMeetings({required Map<String, dynamic> requestBody}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String? token = await SharedPrefsHelper.getAccessToken();

      if (token == null) {
        _errorMessage = "Access token not found.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _dioClient.post(
        ApiEndpoints.meetinghistory,
        data: requestBody,
        options: Options(
          headers: {
            "x-access-token": token,
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = RouteMeetingResponse.fromJson(response.data);
        if (data.success == 1) {
          _meetings = data.data;
        } else {
          _errorMessage = data.message ?? "Failed to fetch meetings.";
        }
      } else {
        _errorMessage = "Failed to fetch meetings. Status code: ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear meetings
  void clear() {
    _meetings = [];
    _errorMessage = null;
    notifyListeners();
  }
}
