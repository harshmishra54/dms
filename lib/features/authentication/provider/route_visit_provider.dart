import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/Tsi_visited_request.dart';
import 'package:TrustTags_DMS/data/models/add_order_response.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';


class RouteVisitProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AddOrderResponse? _response;
  AddOrderResponse? get response => _response;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> addRouteVisit(TsiVisitedRequest requestData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      final response = await _dioClient.post(
        '/pwa/tsi-visited',
        data: requestData.toJson(),
        options: Options(
          headers: {
            'x-access-token': token,
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _response = AddOrderResponse.fromJson(response.data);
        _errorMessage = null;
      } else {
        _errorMessage = "Something went wrong: ${response.statusMessage}";
        _response = null;
      }
    } catch (e) {
      _errorMessage = "Failed to submit data: $e";
      _response = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
