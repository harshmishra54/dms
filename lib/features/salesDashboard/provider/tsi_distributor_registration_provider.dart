// tsi_distributor_provider.dart
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/tsi_distributor_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class TsiDistributorProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  TsiDistributorModel? _distributorResponse;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  TsiDistributorModel? get distributorResponse => _distributorResponse;
  String? get errorMessage => _errorMessage;

  /// ✅ Public setter so UI can trigger loader instantly
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Register distributor
  Future<void> registerDistributor(TsiDistributorModel distributorModel) async {
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token and userId from SharedPreferences
      String? token = await SharedPrefsHelper.getAccessToken();
      String? userId = await SharedPrefsHelper.getUserId();

      if (token == null || userId == null) {
        _errorMessage = "Token or User ID not found in SharedPreferences";
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Add tsmId to the request if not already added
      distributorModel.tsmIds ??= [];
      if (!distributorModel.tsmIds!.contains(userId)) {
        distributorModel.tsmIds!.add(userId);
      }

      // Make API call
      Response response = await _dioClient.client.post(
        ApiEndpoints.tsiDistributorregistration,
        data: distributorModel.toJson(),
        options: Options(
          headers: {
            'x-access-token': token,
            'Content-Type': 'application/json',
          },
        ),
      );

      // Parse response
      _distributorResponse = TsiDistributorModel.fromJson(response.data);
    } on DioException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    _distributorResponse = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
