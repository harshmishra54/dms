import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/add_return_claim_models.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';


class AddReturnClaimProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  AddReturnClaimResponse? _response;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AddReturnClaimResponse? get response => _response;

  /// Submit Return Claim
  Future<void> addReturnClaim(AddReturnClaimPostData requestData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token from SharedPrefs
      final token = await SharedPrefsHelper.getAccessToken();

      if (token == null) {
        throw Exception("Authentication required. Token missing.");
      }

      // ✅ Use roleId from requestData, do NOT overwrite
      final body = requestData.toJson();

      // Optional: ensure roleId is not 0
      if ((body["role_id"] as int?) == null || body["role_id"] == 0) {
        final storedRoleId = await SharedPrefsHelper.getRoleId() ?? 0;
        body["role_id"] = storedRoleId;
      }

      final response = await _dioClient.post(
        ApiEndpoints.addreturnorder,
        data: body,
        options: Options(
          headers: {"x-access-token": token},
        ),
      );

      _response = AddReturnClaimResponse.fromJson(response.data);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
