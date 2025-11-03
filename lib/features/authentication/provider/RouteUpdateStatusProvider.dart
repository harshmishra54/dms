import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/add_order_response.dart';
import 'package:TrustTags_DMS/data/models/update_route_status_request.dart';
import 'package:flutter/material.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';

import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';

class RouteUpdateStatusProvider extends ChangeNotifier {
  final DioClient dioClient;

  RouteUpdateStatusProvider({required this.dioClient});

  bool isLoading = false;
  AddOrderResponse? response;
  String? error;

  Future<void> updateRouteStatus({
    required String dailyRouteId,
    required String tsmId,
    required bool isUnfollow,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception("Access token not found");
      }

      final request = UpdateRouteStatusRequest(
        dailyRouteId: dailyRouteId,
        tsmId: tsmId,
        isUnfollow: isUnfollow,
      );

      final res = await dioClient.post(
        ApiEndpoints.updateRouteStatus,
        data: request.toJson(),
        options: Options(headers: {
          'x-access-token': token,
        }),
      );

      response = AddOrderResponse.fromJson(res.data);
    } catch (e) {
      error = e.toString();
      response = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
