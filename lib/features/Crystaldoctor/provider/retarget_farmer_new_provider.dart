// retarget_farmer_provider.dart
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/retarget_farmer_new_model.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class RetargetFarmerNewProvider with ChangeNotifier {
  final DioClient _dioClient;

  RetargetFarmerNewProvider({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<FarmerData> _farmers = [];
  List<FarmerData> get farmers => _farmers;

  Future<void> fetchRetargetFarmers(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      if (token == null || token.isEmpty) {
        throw "Access token not found";
      }

      final response = await _dioClient.post(
        ApiEndpoints.retargetfarmer,
        data: RetargetFarmerRequest(id: userId).toJson(),
        // ✅ Request body
        options: Options(
          headers: {"x-access-token": token},
        ),
      );

      if (response.data["success"] == 1) {
        final res = RetargetFarmerResponse.fromJson(response.data);
        _farmers = res.data;
      } else {
        _error = response.data["message"] ?? "Failed to fetch farmers";
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearFarmers() {
    _farmers = [];
    notifyListeners();
  }
}
