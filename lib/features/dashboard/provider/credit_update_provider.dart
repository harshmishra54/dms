import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../data/models/credit_update_model.dart';
import '../../../core/utils/shared_prefs_helper.dart';

class CreditUpdateProvider with ChangeNotifier {
  bool _isLoading = false;
  String _responseMessage = '';

  bool get isLoading => _isLoading;
  String get responseMessage => _responseMessage;

  /// Submits a credit limit update request
  Future<bool> submitCreditLimit({
    required CreditUpdateRequest request,
  }) async {
    _isLoading = true;
    _responseMessage = '';
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      if (token == null || token.isEmpty) {
        _responseMessage = 'Token not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await DioClient().post(
        ApiEndpoints.creditLimitUpdate,
        data: request.toJson(),
        options: Options(
          headers: {
            'x-access-token': token,
          },
        ),
      );

      final parsed = CreditUpdateResponse.fromJson(response.data);
      _responseMessage = parsed.message;
      _isLoading = false;
      notifyListeners();

      return parsed.success == 1;
    } catch (e) {
      _responseMessage = 'Failed to send request. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _isLoading = false;
    _responseMessage = '';
    notifyListeners();
  }
}
