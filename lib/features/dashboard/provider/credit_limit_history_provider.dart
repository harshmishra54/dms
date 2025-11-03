// credit_limit_history_provider.dart

import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/data/models/credit_limit_history_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';


class CreditLimitHistoryProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  List<CreditLimitHistory> _creditHistory = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<CreditLimitHistory> get creditHistory => _creditHistory;

  /// Fetch credit limit history
  /// requestBody should be passed from the UI
  Future<void> fetchCreditHistory(Map<String, dynamic> requestBody, {String? token}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (token == null) {
        _errorMessage = "Authorization token is missing";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _dioClient.post(
        ApiEndpoints.creditlimitHistory,
        data: requestBody,
        options: Options(
          headers: {
            'x-access-token': token,
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final respModel = CreditLimitHistoryResponse.fromJson(response.data);
        _creditHistory = respModel.data;
      } else {
        _errorMessage =
        "Failed to fetch credit history. Status code: ${response.statusCode}";
      }
    } on DioException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Optional: clear previous data
  void clearHistory() {
    _creditHistory = [];
    _errorMessage = null;
    notifyListeners();
  }
}
