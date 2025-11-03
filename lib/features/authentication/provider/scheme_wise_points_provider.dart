import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/data/models/scheme_wise_points_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';

class OfferPointProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  OfferPoint? _offerPoint;   // Store the OfferPoint data
  bool _isLoading = false;   // Track loading state
  String _errorMessage = ''; // Track errors

  // Getters
  OfferPoint? get offerPoint => _offerPoint;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  /// 🔹 Reset points before fetching (so UI shows 0,0,0)
  void clearPoints() {
    _offerPoint = null;
    _errorMessage = '';
    notifyListeners();
  }

  /// 🔹 Fetch points for a selected scheme
  Future<void> fetchOfferPoints(String schemeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get token from SharedPreferences
      final token = await SharedPrefsHelper.getAccessToken();

      if (token == null || token.isEmpty) {
        _errorMessage = 'Token is missing';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // API call
      final response = await _dioClient.get(
        ApiEndpoints.schemewisePoints,
        queryParameters: {'scheme_id': schemeId},
        options: Options(
          headers: {'x-access-token': token},
        ),
      );

      // Parse response into model
      _offerPoint = OfferPoint.fromJson(response.data);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
      _offerPoint = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
