import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class IptOrderUpdateProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Update IPT order status
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Get token from SharedPreferences
      final token = await SharedPrefsHelper.getAccessToken();

      if (token == null || token.isEmpty) {
        _errorMessage = "User token not found!";
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Prepare request body
      final data = {
        "order_id": orderId,
        "status": status,
      };

      // Call API
      final response = await DioClient().client.post(
        ApiEndpoints.iptorderupate,
        data: data,
        options: Options(
          headers: {
            'x-access-token': token,
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == 1) {
        _successMessage = response.data['message'] ?? "Status updated!";
      } else {
        _errorMessage = response.data['message'] ?? "Failed to update status.";
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
}
