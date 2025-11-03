// file: lib/features/Crystaldoctor/provider/farmer_details_provider.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/farmer_details_model.dart';

class FarmerDetailsProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  FarmerDetailsResponse? _farmerDetails;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  FarmerDetailsResponse? get farmerDetails => _farmerDetails;

  /// ✅ Fetch farmer details by phone
  Future<void> fetchFarmerDetails(String phone) async {
    _isLoading = true;
    _errorMessage = null;
    _farmerDetails = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      final request = FarmerDetailsRequest(phone: phone);

      final response = await _dioClient.post(
        ApiEndpoints.getfarmerdetails,
        data: request.toJson(),
        options: Options(
          headers: {
            'x-access-token': token ?? '',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        _farmerDetails = FarmerDetailsResponse.fromJson(response.data);
      } else {
        _errorMessage = "Failed to fetch farmer details.";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Helper to reset state
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _farmerDetails = null;
    notifyListeners();
  }

}
