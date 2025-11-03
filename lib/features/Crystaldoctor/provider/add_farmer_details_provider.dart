import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/data/models/add_farmer_details_model.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';

class AddFarmerProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  AddFarmerResponse? _response;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AddFarmerResponse? get response => _response;

  /// Call Add Farmer API
  Future<void> addFarmer(AddFarmerRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    _response = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      // Dio Options
      final options = Options(
        headers: {
          'x-access-token': token ?? '',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      // **Send Map directly, do NOT jsonEncode manually**
      final res = await _dioClient.post(
        ApiEndpoints.addfarmerdetails,
        data: request.toJson(),
        options: options,
      );

      // Check if backend returned proper JSON
      if (res.statusCode == 200 && res.data != null) {
        _response = AddFarmerResponse.fromJson(res.data);
      } else {
        _errorMessage = "Unexpected server response";
      }
    } on DioError catch (dioError) {
      // Better error handling for Dio
      if (dioError.response != null && dioError.response!.data != null) {
        _errorMessage = dioError.response!.data['message'] ?? dioError.message;
      } else {
        _errorMessage = dioError.message;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
