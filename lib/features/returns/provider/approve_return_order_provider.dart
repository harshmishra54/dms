import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/return_claim_order_post_data.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class ReturnClaimOrderProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ReturnClaimOrderResponse? _response;
  ReturnClaimOrderResponse? get response => _response;

  String? _error;
  String? get error => _error;

  /// Update return claim order status
  Future<void> updateReturnClaimOrderStatus(ReturnClaimOrderPostData postData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get token from shared preferences
      final token = await SharedPrefsHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        _error = "Access token not found.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Make API call
      final Response res = await _dioClient.post(
        ApiEndpoints.approvereturnorder,
        data: postData.toJson(),
        options: Options(
          headers: {
            'x-access-token': token,
          },
        ),
      );

      // Parse response
      _response = ReturnClaimOrderResponse.fromJson(res.data);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    _isLoading = false;
    _response = null;
    _error = null;
    notifyListeners();
  }
}
