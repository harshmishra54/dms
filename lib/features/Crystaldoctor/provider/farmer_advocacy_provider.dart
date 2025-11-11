import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/data/models/farmer_advocacy_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';


class AdvocacyProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  GetAdvocacyResponse? _advocacyResponse;
  GetAdvocacyResponse? get advocacyResponse => _advocacyResponse;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// ✅ ADD THIS GETTER
  int get advocacyCount => _advocacyResponse?.totalReferredFarmers ?? 0;

  Future<void> fetchAdvocacy() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userId = await SharedPrefsHelper.getUserId();
      if (userId == null) {
        _errorMessage = "User ID not found!";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final request = GetAdvocacyRequest(id: userId);

      final Response response = await _dioClient.post(
        ApiEndpoints.getAdvocacy,
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        _advocacyResponse = GetAdvocacyResponse.fromJson(response.data);
      } else {
        _errorMessage = "Something went wrong!";
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}

