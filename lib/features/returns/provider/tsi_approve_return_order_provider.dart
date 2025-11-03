import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/tsi_approve_return_models.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';


class TsiReturnApproveOrderProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  TsiApproveReturnOrderResponse? _response;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TsiApproveReturnOrderResponse? get response => _response;

  /// Approve/Reject Return Order
  Future<void> approveReturnOrder(TsiApproveReturnClaimRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    _response = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      final res = await _dioClient.post(
        ApiEndpoints.updateReturnOrder,
        data: request.toJson(),
        options: Options(
          headers: {"x-access-token": token},
        ),
      );

      _response = TsiApproveReturnOrderResponse.fromJson(res.data);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
