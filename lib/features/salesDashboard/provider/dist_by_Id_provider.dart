import 'package:TrustTags_DMS/data/models/dist_by_Id_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/shared_prefs_helper.dart';
import '../../../core/network/api_endpoints.dart';

class DistributorByIdProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  DistributorByIdResponse? _response;

  // ✅ List to store selected distributors
  List<DistributorData> selectedDistributors = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DistributorByIdResponse? get response => _response;

  /// Fetch Distributor(s) by logged in user (id from token, not request body)
  Future<void> fetchDistributorById(String territoryId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      final response = await _dioClient.post(
        ApiEndpoints.distributorbyterritory,
        data: {"id": territoryId},
        options: Options(
          headers: {
            "x-access-token": token ?? "",
          },
        ),
      );

      _response = DistributorByIdResponse.fromJson(response.data);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update selected distributors from dropdown
  void setSelectedDistributors(List<DistributorData> distributors) {
    selectedDistributors = distributors;
    notifyListeners();
  }

  /// Clear state
  void clear() {
    _isLoading = false;
    _errorMessage = null;
    _response = null;
    selectedDistributors = [];
    notifyListeners();
  }
}
