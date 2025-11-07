// add_farmer_points_provider.dart
import 'package:TrustTags_DMS/data/models/give_points_farmer_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';


class AddFarmerPointsProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AddFarmerPointsResponse? _response;
  AddFarmerPointsResponse? get response => _response;

  String? _error;
  String? get error => _error;

  /// Add points to farmers
  Future<void> addPoints(AddFarmerPointsRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      final responseData = await _dioClient.client.post(
        ApiEndpoints.givepointstofarmer,
        data: request.toJson(),
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "x-access-token": token ?? "",
          },
        ),
      );

      _response = AddFarmerPointsResponse.fromJson(responseData.data);
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print("Error in addPoints API: $_error");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset provider state
  void reset() {
    _response = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
