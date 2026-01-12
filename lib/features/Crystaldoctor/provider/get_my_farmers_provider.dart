import 'package:TrustTags_DMS/data/models/get_my_farmer_list_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';

class GetMyFarmersProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  List<Farmer> _farmers = [];

  // ✅ LOCKED USER CONTEXT
  String? _activeUserId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Farmer> get farmers => _farmers;

  /// 🔥 Fetch My Farmers API
  Future<void> fetchMyFarmers({String? userId}) async {
    _isLoading = true;
    _errorMessage = null;

    // 🔒 Lock userId if provided
    if (userId != null && userId.isNotEmpty) {
      _activeUserId = userId;
    }

    notifyListeners();

    try {
      // ✅ Always use locked userId first
      final finalUserId =
          _activeUserId ?? await SharedPrefsHelper.getUserId();

      final token = await SharedPrefsHelper.getAccessToken();

      if (finalUserId == null || finalUserId.isEmpty) {
        throw Exception("User ID not available");
      }

      if (token == null || token.isEmpty) {
        throw Exception("Auth token not available");
      }

      final requestBody =
      GetMyFarmersRequest(createdBy: finalUserId);

      final response = await _dioClient.post(
        ApiEndpoints.getmyfarmerlist,
        data: requestBody.toJson(),
        options: Options(headers: {
          'x-access-token': token,
          'Content-Type': 'application/json',
        }),
      );

      if (response.data['offline'] == true) {
        _errorMessage = "Saved offline. Will sync when online.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final result = GetMyFarmersResponse.fromJson(response.data);

      if (result.success && result.data != null) {
        _farmers = result.data!.farmers;
      } else {
        _errorMessage = result.message;
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print("❌ GetMyFarmersProvider error: $e");
        print(stack);
      }
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 🔄 Refresh (same user, no switching)
  Future<void> refreshMyFarmers() async {
    _farmers.clear();
    await fetchMyFarmers();
  }

  /// 🧹 Clear when role/screen changes
  void clear() {
    _activeUserId = null;
    _farmers.clear();
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}

