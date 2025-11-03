import 'package:TrustTags_DMS/data/models/retailerapprovalbyrsm_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart'; // <-- import your model file
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
class GetRetailRsmRequest {
  final String id;

  GetRetailRsmRequest({required this.id});

  /// Convert object to JSON (for API request body)
  Map<String, dynamic> toJson() =>
      {
        "id": id,
      };
}

class RetailRsmProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  List<RetailRsm> _rsmList = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<RetailRsm> get rsmList => _rsmList;

  /// Fetch Retail RSM list
  Future<void> fetchRetailRsm(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      final requestBody = GetRetailRsmRequest(id: id).toJson();

      final response = await _dioClient.client.post(
        ApiEndpoints.retailerforrsm, // "common/get-retail-rsm"
        data: requestBody,
        options: Options(
          headers: {
            'x-access-token': token ?? '',
          },
        ),
      );

      final result = GetRetailRsmResponse.fromJson(response.data);

      if (result.success == 1) {
        _rsmList = result.data;
      } else {
        _errorMessage = "Failed to load data.";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
