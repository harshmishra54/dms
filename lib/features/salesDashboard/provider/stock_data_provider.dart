// dist_stock_provider.dart

import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/dist_stock_models.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';


class DistStockProvider with ChangeNotifier {
  final DioClient dioClient;

  DistStockProvider({required this.dioClient});

  List<DistStockItem> _stockList = [];
  List<DistStockItem> get stockList => _stockList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Fetch stock data
  Future<void> fetchDistStock({required DistStockRequest request}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token from SharedPreferences
      final token = await SharedPrefsHelper.getAccessToken();

      // Send API request
      Response response = await dioClient.post(
        ApiEndpoints.stockslist,
        data: request.toJson(),
        options: Options(
          headers: {
            'x-access-token': token ?? '',
          },
        ),
      );

      if (response.statusCode == 200) {
        DistStockResponse distStockResponse =
        DistStockResponse.fromJson(response.data);
        _stockList = distStockResponse.data;
      } else {
        _errorMessage =
        'Failed to fetch stock. Status code: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear current stock list
  void clearStock() {
    _stockList = [];
    notifyListeners();
  }
}
