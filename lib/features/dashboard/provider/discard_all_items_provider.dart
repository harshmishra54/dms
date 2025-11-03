import 'package:TrustTags_DMS/data/models/discard_all_items_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';


class DiscardAllItemsProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  DiscardAllItemsResponse? _response;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DiscardAllItemsResponse? get response => _response;

  /// Call API to discard all items
  Future<void> discardAllItems(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    _response = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      if (token == null) throw Exception("Missing authentication token");

      final response = await _dioClient.post(
        ApiEndpoints.discardallitems,
        data: {"orderId": orderId},
        options: Options(
          headers: {"x-access-token": token},
        ),
      );

      _response = DiscardAllItemsResponse.fromJson(response.data);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
