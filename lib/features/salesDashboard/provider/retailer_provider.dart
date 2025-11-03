import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/tsi_retailer_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';


class RetailerProvider with ChangeNotifier {
  bool _isLoading = false;
  RetailerResponse? _retailerResponse;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  RetailerResponse? get retailerResponse => _retailerResponse;
  String? get errorMessage => _errorMessage;

  final DioClient _dioClient = DioClient();

  /// Register Retailer API Call
  Future<void> registerRetailer(RetailerRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token from SharedPrefs
      String? token = await SharedPrefsHelper.getAccessToken();

      Response response = await _dioClient.post(
        ApiEndpoints.tsiRetailerregistration,
        data: request.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'x-access-token': token ?? '',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Use your RetailerResponse model here
        _retailerResponse = RetailerResponse.fromJson(response.data);
      } else {
        _errorMessage = "Failed with status code: ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset response and error
  void reset() {
    _retailerResponse = null;
    _errorMessage = null;
    notifyListeners();
  }
}
