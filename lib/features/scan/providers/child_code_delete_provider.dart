import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/child_scan_delete_model.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class DeleteScanProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  ScanDeleteResponse? _deleteResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ScanDeleteResponse? get deleteResponse => _deleteResponse;

  /// 🔥 Call Delete Scan Code API
  Future<void> deleteScanCode({
    required String orderId,
    required String uniqueCode,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      if (token == null || token.isEmpty) {
        throw Exception("No access token found. Please login again.");
      }

      final response = await _dioClient.post(
        ApiEndpoints.deletechildcode,
        data: {
          "orderId": orderId,
          "uniqueCode": uniqueCode,
        },
        options: Options(
          headers: {"x-access-token": token},
        ),
      );

      _deleteResponse = ScanDeleteResponse.fromJson(response.data);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Clear previous data
  void clear() {
    _deleteResponse = null;
    _errorMessage = null;
    notifyListeners();
  }
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _deleteResponse = null;
    notifyListeners();
  }
}
