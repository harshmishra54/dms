import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/add_return_scan_code_models.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class IPTScanProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  List<Data> _scannedItems = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<Data> get scannedItems => _scannedItems;
  String? get errorMessage => _errorMessage;

  Future<void> scanIPTCode(AddReturnScanCodePostData postData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      Response response = await _dioClient.post(
        ApiEndpoints.IPTscancode,
        data: postData.toJson(),
        options: Options(
          headers: {'x-access-token': token ?? ''},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final scanResponse = AddReturnScanCodeResponse.fromJson(response.data);

        // ⚠ API success message
        _errorMessage = scanResponse.message;

        if (scanResponse.data != null) {
          _scannedItems.add(scanResponse.data!);
        }
      } else {
        // ⚠ API error message
        _errorMessage = response.data["message"] ?? "Something went wrong";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _scannedItems.clear();
    _errorMessage = null;
    notifyListeners();
  }
}
