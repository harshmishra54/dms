import 'package:TrustTags_DMS/data/models/crop_list_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';

class CropProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  CropResponse? _cropResponse;
  CropResponse? get cropResponse => _cropResponse;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Fetch Crop List API
  Future<void> fetchCropList() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // ✅ Get token from SharedPrefs
      final token = await SharedPrefsHelper.getAccessToken();

      final response = await _dioClient.client.get(
        ApiEndpoints.getcropslist,
        options: Options(
          headers: {
            'x-access-token': token ?? '',
          },
        ),
      );

      if (response.statusCode == 200) {
        _cropResponse = CropResponse.fromJson(response.data);
      } else {
        _errorMessage = "Failed to load crop list (Code: ${response.statusCode})";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Optional helper to refresh / clear data
  void clearData() {
    _cropResponse = null;
    _errorMessage = null;
    notifyListeners();
  }
}
