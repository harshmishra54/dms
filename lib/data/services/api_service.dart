import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/dashboard_response.dart';
import 'package:dio/dio.dart';
import '../models/verify_otp_request.dart';
import '../models/verify_otp_response.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/dio_client.dart';

class ApiService {
  final DioClient _dioClient = DioClient(); // Use your singleton/custom DioClient

  Future<VerifyOtpResponse?> verifyOtp(VerifyOtpRequest request) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.verifyOtp,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return VerifyOtpResponse.fromJson(response.data);
      } else {
        print('❌ Server error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Dio exception: $e');
      return null;
    }
  }
  Future<DashboardResponse?> fetchDashboardData() async {
    final token = await SharedPrefsHelper.getAccessToken();
    final response = await _dioClient.get(
      ApiEndpoints.channelDashboard,
      options: Options(headers: {'x-access-token': token}),
    );
    return DashboardResponse.fromJson(response.data);
  }


}
