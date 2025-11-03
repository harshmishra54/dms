import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/taluka_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';


class TalukaProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _loading = false;
  String? _error;
  List<TalukaData> _talukaList = [];

  bool get loading => _loading;
  String? get error => _error;
  List<TalukaData> get talukaList => _talukaList;

  /// Fetch Taluka by Territory & District IDs
  Future<void> fetchTaluka({
    required String territoryId,
    required String districtId,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // Get token from SharedPreferences
      final token = await SharedPrefsHelper.getAccessToken();

      // Prepare request
      final request = TalukaRequest(
        territoryId: territoryId,
        districtId: districtId,
      );

      // Make POST API call with token in headers
      final response = await _dioClient.post(
        ApiEndpoints.talukabyId,
        data: request.toJson(),
        options: Options(
          headers: {
            'x-access-token': token ?? '',
            'Content-Type': 'application/json',
          },
        ),
      );

      // Parse response
      final talukaResponse =
      TalukaResponse.fromJson(response.data as Map<String, dynamic>);

      if (talukaResponse.success == 1) {
        _talukaList = talukaResponse.data;
      } else {
        _error = talukaResponse.message;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Clear Taluka list
  void clear() {
    _talukaList = [];
    _error = null;
    notifyListeners();
  }
}
