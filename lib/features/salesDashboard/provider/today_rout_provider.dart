import 'package:TrustTags_DMS/data/models/today_rout_visit_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';

class TodayRouteScheduleProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  TodayRouteScheduleResponse? _schedule;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TodayRouteScheduleResponse? get schedule => _schedule;

  /// Fetch today's route schedule (no loader shown on UI)
  Future<void> fetchTodayRouteSchedule() async {
    try {
      _isLoading = true;
      _errorMessage = null;

      final token = await SharedPrefsHelper.getAccessToken();
      final response = await _dioClient.get(
        ApiEndpoints.todayroutschedule,
        options: Options(
          headers: {"x-access-token": token ?? ""},
        ),
      );

      // Log and parse cleanly
      if (kDebugMode) {
        print("✅ Today route API response: ${response.data}");
      }

      // Pass the full response (not nested)
      _schedule = TodayRouteScheduleResponse.fromJson(
        Map<String, dynamic>.from(response.data),
      );

      if (kDebugMode) {
        print("✅ Parsed route data: total=${_schedule?.data?.total}");
      }
    } catch (e, st) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print("❌ Error fetching today route schedule: $e");
        print(st);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    _schedule = null;
    _errorMessage = null;
    notifyListeners();
  }
}
