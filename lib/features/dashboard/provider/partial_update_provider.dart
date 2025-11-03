import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart'; // ✅ use new unified model
import 'package:TrustTags_DMS/data/models/partial_update_model.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';

/// ----------------------
/// Provider for Partial Order Update
/// ----------------------
class PartiallyOrderUpdateProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  PartialOrderUpdateModel? _orderResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PartialOrderUpdateModel? get orderResponse => _orderResponse;

  /// ✅ Partial Order Update API call
  Future<void> updatePartialOrder(PartialOrderUpdateModel request) async {
    _isLoading = true;
    _errorMessage = null;
    _orderResponse = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      final response = await _dioClient.post(
        ApiEndpoints.updatePartialOrder, // ✅ endpoint
        data: request.toJson(), // ✅ send request JSON
        options: Options(
          headers: {
            "x-access-token": token ?? "",
          },
        ),
      );

      if (response.statusCode == 200) {
        _orderResponse = PartialOrderUpdateModel.fromJson(response.data); // ✅ parse response
      } else {
        _errorMessage = "Failed with status code: ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
