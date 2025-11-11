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

  List<FarmerPurchase> _repeatPurchaseList = [];
  List<FarmerPurchase> get repeatPurchaseList => _repeatPurchaseList;

  /// ✅ Fetch purchase data using userId from SharedPrefs
  Future<void> fetchPurchaseData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      final userId = await SharedPrefsHelper.getUserId();

      final response = await _dioClient.post(
        ApiEndpoints.getpurchaseData,
        data: {'id': userId},
        options: Options(
          headers: {
            'x-access-token': token ?? '',
          },
        ),
      );

      if (response.statusCode == 200) {
        final purchaseResponse = PurchaseDataResponse.fromJson(response.data);

        if (purchaseResponse.success == 1) {
          // ✅ Correctly assign both lists
          _purchaseList = purchaseResponse.data.allFarmersWithPurchases;
          _repeatPurchaseList = purchaseResponse.data.repeatPurchaseFarmers;
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
    _repeatPurchaseList = [];
    _errorMessage = null;
    notifyListeners();
  }
}
