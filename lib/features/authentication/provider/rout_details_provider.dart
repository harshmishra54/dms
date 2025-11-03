import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../data/models/rout_details_request.dart';
import '../../../../data/models/rout_details_response.dart';
import '../../../../core/utils/shared_prefs_helper.dart';

class RouteDetailsProviders extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool isLoading = false;
  String errorMessage = '';
  RouteDetails? routeDetails;

  Future<void> fetchRouteDetails() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      final dailyRouteId = await SharedPrefsHelper.getDailyRouteId();
      final locationId = await SharedPrefsHelper.getDailylocationId();

      if (token == null || dailyRouteId == null) {
        errorMessage = "Missing required data from local storage.";
        isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _dioClient.post(
        ApiEndpoints.routeDetails,
        data: RouteDetailsRequest(
          dailyRouteId: dailyRouteId,
          locationId: locationId ?? '', // Send empty string if null
        ).toJson(),
        options: Options(
          headers: {
            'x-access-token': token,
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == 1) {
        final data = response.data['data'];
        routeDetails = RouteDetails.fromJson(data);

        // Save the location from response to SharedPreferences
        final locationFromResponse = data['location'] as String?;
        if (locationFromResponse != null && locationFromResponse.isNotEmpty) {
          await SharedPrefsHelper.setDailylocationIdKey(locationFromResponse);
        }

      } else {
        errorMessage = response.data['message'] ?? 'Something went wrong';
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        errorMessage = e.response?.data['message'] ?? 'Server error';
      } else {
        errorMessage = 'Failed to fetch route details';
      }
    }

    isLoading = false;
    notifyListeners();
  }

  void clear() {
    routeDetails = null;
    errorMessage = '';
    isLoading = false;
    notifyListeners();
  }
}
