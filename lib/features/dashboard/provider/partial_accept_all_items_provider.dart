import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import 'package:TrustTags_DMS/data/models/partial_accept_all_order_items_model.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';

class PartialAcceptOrderProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  PartialAcceptOrderResponse? _response;
  PartialAcceptOrderResponse? get response => _response;

  /// API call for Partial Accept
  Future<void> partialAcceptOrder(PartialAcceptOrderRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    _response = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      final response = await _dioClient.post(
        ApiEndpoints.partialacceptallorderItem,
        data: request.toJson(),
        options: Options(
          headers: {
            'x-access-token': token ?? '',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        _response = PartialAcceptOrderResponse.fromJson(response.data);
      } else {
        _errorMessage = "Unexpected status code: ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print("PartialAcceptOrder Error: $e");
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Convenience wrapper (optional)
  Future<void> partialAccept({
    required String orderId,
    required List<String> orderDetailsIds,
  }) {
    final request = PartialAcceptOrderRequest(
      orderId: orderId,
      orderDetailsIds: orderDetailsIds,
    );
    return partialAcceptOrder(request);
  }

  /// Reset state
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _response = null;
    notifyListeners();
  }
}
