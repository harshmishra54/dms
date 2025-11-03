import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../core/utils/shared_prefs_helper.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../data/models/recive_return_claim_post_data.dart';
import '../../data/models/receive_order_response.dart';

class ReceiveReturnClaimProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  List<OrderData> _orders = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<OrderData> get orders => _orders;

  /// Fetch received return claim orders using roleId = 1
  Future<void> fetchReceiveReturnClaims() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      final requestId = await SharedPrefsHelper.getUserId();
      final roleId = await SharedPrefsHelper.getRoleId(); // ✅ fetch from shared prefs

      if (token == null || requestId == null || roleId == null) {
        throw Exception("Missing token, requestId or roleId");
      }

      final requestBody = ReceiveReturnClaimPostData(
        roleId: roleId.toString(),  // ✅ now dynamic from shared prefs
        requestId: requestId.toString(),
      ).toJson();

      final response = await _dioClient.post(
        ApiEndpoints.listReturnClaim,
        data: requestBody,
        options: Options(
          headers: {
            'x-access-token': token,
          },
        ),
      );

      if (response.statusCode == 200) {
        final parsed = ReceiveOrderResponse.fromJson(response.data);
        if (parsed.success == 1) {
          _orders = parsed.data;
        } else {
          _errorMessage = parsed.message;
        }
      } else {
        _errorMessage = "Server error: ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = "Something went wrong: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}
