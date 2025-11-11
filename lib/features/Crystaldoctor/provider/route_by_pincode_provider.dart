import 'package:TrustTags_DMS/data/models/route_by_pincode_model.dart';
import 'package:flutter/material.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:dio/dio.dart';

class RouteByPincodeProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  RouteResponseModel? _routeResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RouteResponseModel? get routeResponse => _routeResponse;

  /// ✅ Fetch Route By Pincode API
  Future<void> fetchRouteByPincode(RouteRequestModel request) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      // ✅ Get token from SharedPrefs
      final token = await SharedPrefsHelper.getAccessToken();

      final response = await _dioClient.post(
        ApiEndpoints.getRoutebyPincode,
        data: request.toJson(),
        options: token != null
            ? Options(
          headers: {
            "x-access-token": token,
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
        )
            : null,
      );

      if (response.statusCode == 200 && response.data != null) {
        _routeResponse = RouteResponseModel.fromJson(response.data);
      } else {
        _errorMessage = "Failed to fetch route.";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearData() {
    _routeResponse = null;
    _errorMessage = null;
    notifyListeners();
  }
}
