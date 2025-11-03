import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/credit_limit_response.dart';

class CreditLimitProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  /// old usage (still works)
  List<CreditListDataResponse> creditList = [];
  bool isLoading = false;

  /// new usage: distributorId -> credit data
  final Map<String, CreditListDataResponse?> creditMap = {};
  final Map<String, bool> loadingMap = {};
  final Set<String> _fetchedIds = {}; // ✅ track attempted distributor fetches

  /// 🔹 Existing function (do not break old places)
  Future<void> fetchCreditLimitList({required String roleId}) async {
    isLoading = true;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      final requestId = await SharedPrefsHelper.getUserId(); // Using userId as requestId

      if (token == null || requestId == null) {
        debugPrint('Token or RequestId missing in SharedPreferences');
        creditList = [];
        isLoading = false;
        notifyListeners();
        return;
      }

      final request = CreditListRequest(roleId: roleId, requestId: requestId);

      final response = await _dioClient.post(
        ApiEndpoints.creditLimitList,
        data: request.toJson(),
        options: Options(headers: {
          'x-access-token': token,
        }),
      );

      final parsed = CreditLimitResponse.fromJson(response.data);

      if (parsed.success == 1) {
        creditList = parsed.data;
      } else {
        creditList = [];
      }
    } catch (e) {
      debugPrint('Error fetching credit limit list: $e');
      creditList = [];
    }

    isLoading = false;
    notifyListeners();
  }

  /// 🔹 New function for distributor-specific credit limit
  Future<void> fetchDistributorCreditLimit({
    required String roleId,
    required String distributorId,
    bool forceRefresh = false, // ✅ add forceRefresh
  }) async {
    // ✅ Prevent duplicate fetch if already loading
    if (loadingMap[distributorId] == true) return;

    // ✅ Skip if already fetched, unless forceRefresh is true
    if (!forceRefresh && creditMap.containsKey(distributorId)) return;

    final token = await SharedPrefsHelper.getAccessToken();
    if (token == null) {
      debugPrint('Missing token while fetching distributor credit limit');
      return;
    }

    loadingMap[distributorId] = true;
    notifyListeners();

    try {
      final request = CreditListRequest(roleId: roleId, requestId: distributorId);

      final response = await _dioClient.post(
        ApiEndpoints.creditLimitList,
        data: request.toJson(),
        options: Options(headers: {
          'x-access-token': token,
        }),
      );

      final parsed = CreditLimitResponse.fromJson(response.data);

      if (parsed.success == 1 && parsed.data.isNotEmpty) {
        creditMap[distributorId] = parsed.data.first;
      } else {
        creditMap[distributorId] = null;
      }
    } catch (e) {
      debugPrint('Error fetching credit limit for distributor $distributorId: $e');
      creditMap[distributorId] = null;
    }

    loadingMap[distributorId] = false;
    notifyListeners();
  }

}
