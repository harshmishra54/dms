import 'package:TrustTags_DMS/data/models/complete_return_model.dart';
import 'package:flutter/material.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:dio/dio.dart';

class CompleteReturnOrderProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  CompleteReturnOrderResponse? _response;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CompleteReturnOrderResponse? get response => _response;

  /// Create Complete Return Order API Call
  Future<void> createCompleteReturnOrder(CompleteReturnOrderRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      final response = await _dioClient.client.post(
        ApiEndpoints.completereturnorder,
        data: request.toJson(),
        options: Options(
          headers: {
            'x-access-token': token ?? '',
          },
        ),
      );

      if (response.statusCode == 200) {
        _response = CompleteReturnOrderResponse.fromJson(response.data);
      } else {
        _errorMessage = "Unexpected error: ${response.statusCode}";
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data?['message'] ??
          "Something went wrong. Please try again.";
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset state (optional helper)
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _response = null;
    notifyListeners();
  }
}
