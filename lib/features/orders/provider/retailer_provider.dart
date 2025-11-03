import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/tsi_retailer_data.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
 // ✅ Add this

class TsiRetailerProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  List<TsiRetailerData> _retailers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TsiRetailerData> get retailers => _retailers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchRetailers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      final tsmId = await SharedPrefsHelper.getUserId();

      if (token == null || tsmId == null) {
        _errorMessage = "Missing token or TSM ID";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final request = TsiRetailerRequest(tsmId: tsmId);

      final response = await _dioClient.post(
        ApiEndpoints.fetchRetailers, // ✅ Use constant
        data: request.toJson(),
        options: Options(
          headers: {
            'x-access-token': token,
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        final retailerResponse = TsiRetailerResponse.fromJson(responseData);

        if (retailerResponse.success == 1 && retailerResponse.data != null) {
          _retailers = retailerResponse.data!;
        } else {
          _errorMessage = retailerResponse.message;
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Something went wrong: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}
