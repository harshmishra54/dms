import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/inward_scan_details_model.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';


class InwardScanProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  InwardScanData? _scanData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  InwardScanData? get scanData => _scanData;

  /// Fetch inward scan details
  Future<void> fetchInwardScanDetails(InwardScanDetails request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception("User not logged in. Token missing.");
      }

      final response = await _dioClient.post(
        ApiEndpoints.inwardcodescandetail,
        data: request.toJson(),
        options: Options(headers: {
          "x-access-token": token,
        }),
      );

      final result = InwardScanDetailsResponse.fromJson(response.data);

      if (result.success == 1) {
        _scanData = result.data;
      } else {
        _errorMessage = result.message;
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearData() {
    _scanData = null;
    _errorMessage = null;
    notifyListeners();
  }
}
