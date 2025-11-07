// lib/providers/retarget_gap_farmer_provider.dart
import 'package:TrustTags_DMS/data/models/retarget_gap_farmer_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';

class RetargetGapFarmerProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _loading = false;
  bool get loading => _loading;

  RetargetGapFarmerResponse? _response;
  RetargetGapFarmerResponse? get response => _response;

  String? _error;
  String? get error => _error;

  /// ✅ Fetch farmers who have not purchased within given duration
  Future<void> fetchGapFarmers(RetargetGapFarmerRequest request) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      final response = await _dioClient.client.post(
        ApiEndpoints.retargetgapfarmer,
        data: request.toJson(),
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "x-access-token": token ?? "",
          },
        ),
      );

      if (response.statusCode == 200) {
        _response = RetargetGapFarmerResponse.fromJson(response.data);
      } else {
        _error = "Failed with status code: ${response.statusCode}";
      }
    } on DioException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Clear previous response/error
  void clear() {
    _response = null;
    _error = null;
    notifyListeners();
  }
}
