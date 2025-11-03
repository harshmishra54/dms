import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/recieve_return_order_model.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';


class RecieveReturnOrderListProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  ReceiveReturnClaimResponse? _response;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ReceiveReturnClaimResponse? get response => _response;

  /// Call API
  Future<void> receiveReturnClaim() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token, userId (requestId), roleId from SharedPrefs
      final token = await SharedPrefsHelper.getAccessToken();
      final requestId = await SharedPrefsHelper.getUserId();
      final roleId = await SharedPrefsHelper.getRoleId();

      if (token == null || requestId == null || roleId == null) {
        throw Exception("Missing authentication data");
      }

      final postData = ReceiveReturnClaimPostData(
        roleId: roleId.toString(),
        requestId: requestId,
      );

      final response = await _dioClient.post(
        ApiEndpoints.recievereturnorderofdistributor,
        data: postData.toJson(),
        options: Options(headers: {"x-access-token": token}),
      );

      _response = ReceiveReturnClaimResponse.fromJson(response.data);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
