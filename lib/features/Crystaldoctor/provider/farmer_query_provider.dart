import 'package:TrustTags_DMS/data/models/farmer_query_add_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';

class FarmerQueryProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  FarmerQueryResponse? _response;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  FarmerQueryResponse? get response => _response;

  /// ✅ Add Farmer Query API
  Future<void> addFarmerQuery(FarmerQueryRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      final response = await _dioClient.post(
        ApiEndpoints.addfarmerquery,
        data: request.toJson(),
        options: Options(headers: {
          'x-access-token': token,
        }),
      );

      if (response.statusCode == 200) {
        _response = FarmerQueryResponse.fromJson(response.data);
      } else {
        _errorMessage = "Something went wrong. Please try again.";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Optional: reset state after use
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _response = null;
    notifyListeners();
  }
}
