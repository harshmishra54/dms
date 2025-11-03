import 'package:TrustTags_DMS/data/models/ipt_order_details_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';

class IptOrderDetailsProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  IptOrderDetailsResponse? _orderDetails;
  bool _isLoading = false;
  String? _errorMessage;

  IptOrderDetailsResponse? get orderDetails => _orderDetails;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch IPT Order Details
  Future<void> fetchOrderDetails(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token from SharedPreferences
      final token = await SharedPrefsHelper.getAccessToken();
      if (token == null) {
        throw Exception("Token not found");
      }

      // Prepare headers with x-access-token
      final options = Options(
        headers: {
          'x-access-token': token,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      // Prepare request body
      final requestBody = IptOrderDetailsRequest(orderId: orderId).toJson();

      // Make POST request
      final response = await _dioClient.post(
        ApiEndpoints.iptorderdetails,
        data: requestBody,
        options: options,
      );

      // Parse response
      _orderDetails = IptOrderDetailsResponse.fromJson(response.data);
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print("Error fetching IPT Order Details: $e");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear provider data
  void clear() {
    _orderDetails = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
