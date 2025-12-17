import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/data/models/merged_route_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

// 👆 adjust import path to where you placed Request/Response models

class RouteActivityProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  RouteActivityResponse? routeActivityResponse;
  bool isLoading = false;
  String? errorMessage;

  /// Fetch route activity
  Future<void> fetchRouteActivity({
    required RouteActivityRequest request,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final Response response = await _dioClient.post(
        ApiEndpoints.completeRoute,
        data: request.toJson(),
      );

      routeActivityResponse =
          RouteActivityResponse.fromJson(response.data);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Clear data if needed
  void clear() {
    routeActivityResponse = null;
    errorMessage = null;
    notifyListeners();
  }
}
