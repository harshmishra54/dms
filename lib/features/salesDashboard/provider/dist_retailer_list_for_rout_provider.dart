import 'package:TrustTags_DMS/data/models/dist_retailer_rout_model.dart'; // <-- new request model
import 'package:TrustTags_DMS/data/models/distributor_under_tsi_request_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/utils/shared_prefs_helper.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';

class TerritoryProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  List<TerritoryData> _distributors = [];
  List<TerritoryData> _retailers = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TerritoryData> get distributors => _distributors;
  List<TerritoryData> get retailers => _retailers;

  /// 🔹 Fetch Distributor List (with request body)
  Future<void> fetchDistributors(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      final requestBody = DistributorUnderTsiRequestModel(id: userId).toJson();

      final response = await _dioClient.post(
        ApiEndpoints.territorydistributor,
        data: requestBody,
        options: Options(
          headers: {
            "x-access-token": token ?? "",
          },
        ),
      );

      final data = TerritoryResponse.fromJson(response.data);
      _distributors = data.data;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🔹 Fetch Retailer List (no body required)
  /// 🔹 Fetch Retailer List (with request body)
  Future<void> fetchRetailers(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      // ✅ send userId in request body
      final requestBody = RetailerUnderTSIModelRequest(id: userId).toJson();

      final response = await _dioClient.post(
        ApiEndpoints.territoryretailer,
        data: requestBody,
        options: Options(
          headers: {
            "x-access-token": token ?? "",
          },
        ),
      );

      // ✅ assign to _retailers instead of _distributors
      final data = TerritoryResponse.fromJson(response.data);
      _retailers = data.data;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  /// 🔹 Clear Data
  void clear() {
    _distributors = [];
    _retailers = [];
    _errorMessage = null;
    notifyListeners();
  }
}
