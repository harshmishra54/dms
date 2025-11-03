import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/cancel_order_%20model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class CancelUpdateOrderProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _loading = false;
  bool get loading => _loading;

  CancelUpdateOrderResponse? _response;
  CancelUpdateOrderResponse? get response => _response;

  String? _error;
  String? get error => _error;

  /// Cancel or update order
  Future<void> cancelOrUpdateOrder({
    required String orderId,
    required String roleId,
    required String requestId,
    required List<CancelProduct> products,
    bool? cancel,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // Build request
      final request = CancelUpdateOrderRequest(
        id: orderId,
        roleId: roleId,
        requestId: requestId,
        products: products,
        cancel: cancel,
      );

      // Get access token
      final token = await SharedPrefsHelper.getAccessToken();

      final response = await _dioClient.client.post(
        ApiEndpoints.cancelorderbeforeaccepted,
        data: request.toJson(),
        options: Options(
          headers: {
            "x-access-token": token ?? '',
          },
        ),
      );

      _response = CancelUpdateOrderResponse.fromJson(response.data);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
