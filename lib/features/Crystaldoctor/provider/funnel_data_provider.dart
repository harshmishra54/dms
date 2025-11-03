import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/farmer_funnel_model.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';

class FarmerFunnelProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  FarmerFunnelResponse? _farmerFunnel;
  bool _isLoading = false;
  String? _errorMessage;

  FarmerFunnelResponse? get farmerFunnel => _farmerFunnel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch Farmer Funnel Data
  Future<void> fetchFarmerFunnel() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      final userId = await SharedPrefsHelper.getUserId();

      if (token == null || userId == null) {
        _errorMessage = "User not logged in.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Prepare headers
      final headers = {
        'x-access-token': token,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Prepare request body
      final requestBody = {
        "created_by": userId,
      };

      // Make API call
      final response = await _dioClient.post(
        ApiEndpoints.getfunneldata,
        data: requestBody,
        options: Options(
          headers: headers,
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == 1) {
        _farmerFunnel = FarmerFunnelResponse.fromJson(response.data);
      } else {
        _errorMessage = response.data['message'] ?? "Something went wrong.";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
