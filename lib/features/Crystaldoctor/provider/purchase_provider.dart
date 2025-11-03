// providers/purchase_data_provider.dart
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/purchase_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class PurchaseDataProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<FarmerPurchase> _purchaseList = [];
  List<FarmerPurchase> get purchaseList => _purchaseList;

  /// Fetch purchase data using farmer id
  Future<void> fetchPurchaseData(String farmerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token from SharedPreferences
      final token = await SharedPrefsHelper.getAccessToken();
      final requestId=await SharedPrefsHelper.getUserId();

      final response = await _dioClient.post(
        ApiEndpoints.getpurchaseData,
        data: {'id': requestId},
        options: Options(
          headers: {
            'x-access-token': token ?? '',
          },
        ),
      );

      if (response.statusCode == 200) {
        final purchaseResponse = PurchaseDataResponse.fromJson(response.data);
        if (purchaseResponse.success == 1) {
          _purchaseList = purchaseResponse.data;
        } else {
          _errorMessage = purchaseResponse.message;
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Clear the data
  void clearData() {
    _purchaseList = [];
    _errorMessage = null;
    notifyListeners();
  }
}
