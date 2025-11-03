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

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Farmer> get farmers => _farmers;

  /// 🔥 Fetch My Farmers API
  Future<void> fetchMyFarmers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 🔹 Get user ID and token from SharedPrefs
      final userId = await SharedPrefsHelper.getUserId();
      final token = await SharedPrefsHelper.getAccessToken();

      if (userId == null || userId.isEmpty) {
        throw Exception("User ID not found in SharedPreferences");
      }

      if (token == null || token.isEmpty) {
        throw Exception("Auth token not found in SharedPreferences");
      }

      final requestBody = GetMyFarmersRequest(createdBy: userId);

      final response = await _dioClient.post(
        ApiEndpoints.getmyfarmerlist,
        data: requestBody.toJson(),
        options: Options(headers: {
          'x-access-token': token, // ✅ Add token here
          'Content-Type': 'application/json',
        }),
      );

      // Handle offline saved request
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
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🧹 Clear farmers (optional utility)
  void clearFarmers() {
    _farmers.clear();
    notifyListeners();
  }
}
