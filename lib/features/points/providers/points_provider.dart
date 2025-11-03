import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/scan_history_response.dart';

class PointsProvider with ChangeNotifier {
  bool isLoading = false;

  /// Use the corrected model
  List<ScanHistoryItem> scanHistory = [];

  /// Fetch scan history from API
  Future<void> fetchScanHistory(String startDate, String endDate) async {
    isLoading = true;
    notifyListeners();

    try {
      // Get access token from shared preferences
      final token = await SharedPrefsHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        print("❌ No access token found. Cannot fetch scan history.");
        scanHistory = [];
        return;
      }

      print("➡️ Fetching scan history: start=$startDate, end=$endDate");

      final response = await DioClient().get(
        ApiEndpoints.scanHistory,
        options: Options(headers: {'x-access-token': token}),
        queryParameters: {
          'startDate': startDate,
          'endDate': endDate,
        },
      );

      print("⬅️ Scan history API raw response: ${response.data}");

      final res = ScanHistoryResponse.fromJson(response.data);

      if (res.success == 1) {
        scanHistory = res.data;
      } else {
        scanHistory = [];
      }
    } catch (e, stack) {
      print("❌ Error fetching scan history: $e");
      print(stack);
      scanHistory = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
