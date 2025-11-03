import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/route_asm_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class RouteAsmProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  RouteAsmResponse? _response;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RouteAsmResponse? get response => _response;

  /// Submit ASM Route request
  Future<RouteAsmResponse> submitRouteAsm(RouteAsmRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      final res = await _dioClient.post(
        ApiEndpoints.routselection,
        data: request.toJson(),
        options: Options(
          headers: {
            'x-access-token': token ?? '',
          },
        ),
      );

      _response = RouteAsmResponse.fromJson(res.data);
      return _response!;
    } catch (e) {
      _errorMessage = e.toString();
      return RouteAsmResponse(success: 0, message: _errorMessage ?? "Unknown error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
