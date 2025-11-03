import 'package:TrustTags_DMS/data/models/inward_complete_model.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';  // ✅ import for Options
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';

class SubmitScanProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  SubmitResponse? _response;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SubmitResponse? get response => _response;

  /// Call API
  Future<void> submitScan({required String orderId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      final userName = await SharedPrefsHelper.getUserName();

      if (token == null || token.isEmpty) {
        throw Exception("No access token found");
      }

      final request = SubmitPostData(orderId: orderId, userName: userName);

      final dio = DioClient().client;

      final res = await dio.post(
        ApiEndpoints.retailerInwardComplete,
        data: request.toJson(),
        options: Options(headers: {"x-access-token": token}), // ✅ Now works
      );

      _response = SubmitResponse.fromJson(res.data);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _response = null;
    notifyListeners();
  }
}
