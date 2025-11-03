import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/scheme_response.dart';


class SchemeProvider with ChangeNotifier {
  bool isLoading = false;
  List<SchemeItem> schemes = [];

  /// Fetch scheme catalog
  Future<void> fetchSchemes() async {
    isLoading = true;
    notifyListeners();

    try {
      // Get token from SharedPreferences
      final token = await SharedPrefsHelper.getAccessToken();

      if (token == null || token.isEmpty) {
        print("❌ No token found");
        schemes = [];
        isLoading = false;
        notifyListeners();
        return;
      }

      print("➡️ Fetching scheme catalog");

      final response = await DioClient().get(
        ApiEndpoints.pointCatalogue, // Make sure endpoint constant is correct
        options: Options(headers: {'x-access-token': token}),
      );

      print("⬅️ Scheme API response: ${response.data}");

      final res = SchemeResponse.fromJson(response.data);

      if (res.success.toString() == "1" && res.data.isNotEmpty) {
        schemes = res.data;
      } else {
        schemes = [];
      }

    } catch (e) {
      print("❌ Error fetching schemes: $e");
      schemes = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle expand/collapse for a specific scheme item
  void toggleExpand(int index) {
    schemes[index].isExpanded = !schemes[index].isExpanded;
    notifyListeners();
  }
}
