// order_details_provider.dart
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/order_details_model.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';


class OrderDetailsProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  Future<OrderDetailsResponse?> fetchOrderDetails({
    required String roleId,
    required String id,
    required String requestId,
  }) async {
    try {
      final token = await SharedPrefsHelper.getAccessToken();
      if (token == null) {
        throw Exception("Token not found in SharedPreferences");
      }

      final response = await _dioClient.post(
        ApiEndpoints.orderDetails, // make sure this points to "pwa/order-details"
        data: {
          "role_id": roleId,
          "id": id,
          "request_id": requestId,
        },
        options: Options(headers: {
          'x-access-token': token, // ✅ correct header
        }),
      );

      if (response.statusCode == 200) {
        return OrderDetailsResponse.fromJson(response.data);
      } else {
        debugPrint("Order details API error: ${response.statusCode}");
        return null;
      }
    } catch (e, stack) {
      debugPrint("Order details fetch error: $e\n$stack");
      return null;
    }
  }
}
