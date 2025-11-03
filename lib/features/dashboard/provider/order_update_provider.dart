import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/order_update_model.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';


class OrderUpdateProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  AddOrderResponses? _orderResponse; // ✅ Correct model class

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AddOrderResponses? get orderResponse => _orderResponse;

  /// Update order status
  Future<void> updateOrderStatus(OrderUpdateRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    _orderResponse = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      final response = await _dioClient.post(
        ApiEndpoints.updateOrderStatus,
        data: request.toJson(),
        options: Options(
          headers: {
            "x-access-token": token ?? "",
          },
        ),
      );

      if (response.statusCode == 200) {
        _orderResponse = AddOrderResponses.fromJson(response.data);
      } else {
        _errorMessage = "Failed with status code: ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
