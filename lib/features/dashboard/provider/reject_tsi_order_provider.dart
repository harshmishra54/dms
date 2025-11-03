import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/data/models/cancel_tsi_created_order_model.dart';

class RejectTsiOrderProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  RejectTsiOrderResponse? _response;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RejectTsiOrderResponse? get response => _response;

  /// Reject an order (UI will pass full request body)
  Future<bool> rejectOrder(Map<String, dynamic> requestBody) async {
    _isLoading = true;
    _errorMessage = null;
    _response = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      if (token == null) throw Exception("Missing authentication token");

      final response = await _dioClient.post(
        ApiEndpoints.cancelTsiCreatedOrder,
        data: requestBody,
        options: Options(
          headers: {"x-access-token": token},
        ),
      );

      _response = RejectTsiOrderResponse.fromJson(response.data);

      if (_response?.success == 1) {
        return true;
      } else {
        _errorMessage = _response?.message ?? "Failed to reject order";
        return false;
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data is Map<String, dynamic>
          ? e.response?.data['message'] ?? 'Failed to reject order'
          : 'Failed to reject order';
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
