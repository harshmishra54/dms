import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/activity_timeline_model.dart';

class GetActivityTimelineProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  ActivityTimelineResponse? _activityTimelineResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ActivityTimelineResponse? get activityTimelineResponse =>
      _activityTimelineResponse;

  /// ✅ Fetch activity timeline
  Future<void> fetchActivityTimeline({bool forceRefresh = false}) async {
    // 🔁 Always clear old data before fresh call
    if (forceRefresh || _activityTimelineResponse != null) {
      _activityTimelineResponse = null;
      _errorMessage = null;
      notifyListeners();
    }

    _isLoading = true;
    notifyListeners();

    try {
      final userId = await SharedPrefsHelper.getUserId();
      final token = await SharedPrefsHelper.getAccessToken();

      if (userId == null || token == null) {
        _errorMessage = "User not logged in";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final request = GetActivityTimelineRequest(id: userId);

      final response = await _dioClient.client.post(
        ApiEndpoints.activitytimeline,
        data: getActivityTimelineRequestToJson(request),
        options: Options(headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "x-access-token": token,
          "Cache-Control": "no-cache", // 🚫 prevent HTTP caching
        }),
      );

      if (response.statusCode == 200) {
        final data = ActivityTimelineResponse.fromJson(response.data);

        // ✅ Clear old data if response is null or empty
        if (data.data == null || data.data!.isEmpty) {
          _activityTimelineResponse = null;
          _errorMessage = "No activities found";
        } else {
          _activityTimelineResponse = data;
        }
      } else {
        _errorMessage = "Failed to load timeline: ${response.statusMessage}";
        _activityTimelineResponse = null;
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data?["message"] ?? "Network error";
      _activityTimelineResponse = null;
    } catch (e) {
      _errorMessage = "Something went wrong: $e";
      _activityTimelineResponse = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// ✅ Clear data manually
  void clear() {
    _activityTimelineResponse = null;
    _errorMessage = null;
    notifyListeners();
  }
}
