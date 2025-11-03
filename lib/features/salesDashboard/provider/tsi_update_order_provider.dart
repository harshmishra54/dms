import 'package:TrustTags_DMS/data/models/tsi_update_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';


class UpdateOrderProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  UpdateOrderResponse? _updateOrderResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UpdateOrderResponse? get updateOrderResponse => _updateOrderResponse;

  /// Update Order API
  Future<bool> updateOrder(UpdateOrderRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      final response = await _dioClient.post(
        ApiEndpoints.tsiupdateorder,
        data: request.toJson(),
        options: Options(
          headers: {
            'x-access-token': token ?? '',
          },
        ),
      );

      if (response.statusCode == 200) {
        _updateOrderResponse =
            UpdateOrderResponse.fromJson(response.data);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Something went wrong. Please try again.";
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _updateOrderResponse = null;
    notifyListeners();
  }
}
