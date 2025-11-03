import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/route_meeting_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class MeetingProvider extends ChangeNotifier {
  final DioClient _dioClient;

  MeetingProvider({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Submit Meeting API
  Future<RouteMeetingResponse> submitMeeting(RouteMeetingRequest request) async {
    try {
      _isLoading = true;
      notifyListeners();

      // 1. Get access token
      final token = await SharedPrefsHelper.getAccessToken();

      // 2. Perform POST request
      final response = await _dioClient.post(
        ApiEndpoints.routeMeeting, // ✅ no hardcoding
        data: request.toJson(),
        options: Options(
          headers: {
            "x-access-token": token ?? "",
          },
        ),
      );

      if (kDebugMode) {
        debugPrint("➡️ Meeting API Response: ${response.data}");
      }

      // 3. Parse response
      return RouteMeetingResponse.fromJson(response.data);
    } catch (e) {
      debugPrint("❌ Error in submitMeeting: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
