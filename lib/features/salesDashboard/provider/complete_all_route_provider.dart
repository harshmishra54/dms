import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/complete_all_routes_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';


class RouteProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  RouteResponse? _routeResponse;
  RouteResponse? get routeResponse => _routeResponse;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> completeRoute(String routeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token from SharedPreferences
      final token = await SharedPrefsHelper.getAccessToken();

      if (token == null || token.isEmpty) {
        throw Exception("User not authenticated");
      }

      // Make POST request with token in headers
      final response = await _dioClient.post(
        ApiEndpoints.completeAllRoute,
        data: {
          'route_id': routeId,
        },
        options: Options(
          headers: {
            'x-access-token': token,
          },
        ),
      );

      // Parse response
      _routeResponse = RouteResponse.fromJson(response.data);

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
