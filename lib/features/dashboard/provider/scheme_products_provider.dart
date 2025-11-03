import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/schemeProduct_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class SchemeProductsProvider extends ChangeNotifier {
  final DioClient _dioClient;

  SchemeProductsProvider({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  bool _loading = false;
  bool get loading => _loading;

  SchemeProductsResponse? _response;
  SchemeProductsResponse? get response => _response;

  String? _error;
  String? get error => _error;

  // ✅ Fetch scheme products using dynamic roleId/userId logic
  Future<void> fetchSchemeProducts() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // Get token from SharedPreferences
      final token = await SharedPrefsHelper.getAccessToken();

      // Get main roleId and userId
      int mainRoleId = await SharedPrefsHelper.getRoleId() ?? 1;
      String mainUserId = await SharedPrefsHelper.getUserId() ?? '';

      int roleId;
      String userId;

      if (mainRoleId == 18) {
        // Special case for daily role
        roleId = int.tryParse(await SharedPrefsHelper.getDailyRoleId() ?? '18') ?? 18;
        userId = await SharedPrefsHelper.getDailylocationIdKey() ?? '';
      } else {
        // Regular role
        roleId = mainRoleId;
        userId = mainUserId;
      }

      final headers = {
        'x-access-token': token ?? '',
      };

      // Prepare request body
      final requestBody = SchemeProductsRequest(roleId: roleId, userId: userId);

      // Make API call
      final Response res = await _dioClient.post(
        ApiEndpoints.schemeProducts,
        data: requestBody.toJson(),
        options: Options(headers: headers),
      );

      _response = SchemeProductsResponse.fromJson(res.data);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
