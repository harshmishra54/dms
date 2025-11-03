import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/tsi_approved_reject_model.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class TsiApproveOrderProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  TsiApproveOrderResponse? _response;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TsiApproveOrderResponse? get response => _response;

  Future<void> tsiApprovePlaceOrderList({
    required String orderId,
    required String requestId,   // ✅ now passed from page
    required int decision,
    String? reason,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _response = null;
    notifyListeners();

    try {
      // 🔹 Get token & roleId only
      final token = await SharedPrefsHelper.getAccessToken();
      final roleId = await SharedPrefsHelper.getRoleId();

      if (token == null) {
        throw Exception("Missing token in SharedPreferences");
      }

      // Prepare request payload
      final request = OrderTsiApproveRequest(
        roleId: roleId?.toString() ?? '1',
        requestId: requestId,   // ✅ coming from UI page
        orderId: orderId,
        decision: decision,
        reason: reason,
      );

      // API call
      final res = await _dioClient.post(
        ApiEndpoints.tsiApprovePlaceOrder,
        data: request.toJson(),
        options: Options(
          headers: {
            'x-access-token': token,
          },
        ),
      );

      // Parse response
      _response = TsiApproveOrderResponse.fromJson(res.data);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
