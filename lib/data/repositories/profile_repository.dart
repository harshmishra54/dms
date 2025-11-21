import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import '../models/profile_request.dart';
import '../models/profile_response.dart';
import '../models/customer_details_response.dart';

class ProfileRepository {
  final DioClient dioClient;

  ProfileRepository({required this.dioClient});

  // Update Profile API
  Future<ProfileUpdateResponse> updateProfile(
      String token, ProfileRequest request) async {
    try {
      FormData formData = FormData.fromMap({
        ...request.toJson(),
        if (request.profileImageFile != null)
          "profileImage": await MultipartFile.fromFile(
            request.profileImageFile!.path,
            filename: request.profileImageFile!.path.split("/").last,
          ),
      });

      final response = await dioClient.put(
        ApiEndpoints.updateProfile,
        data: formData,
        options: Options(
          headers: {
            'x-access-token': token,
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return ProfileUpdateResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }


  // ✅ New: Fetch customer details API
  Future<CustomerDetailsResponse> getCustomerDetails(String token) async {
    try {
      final response = await dioClient.get(
        ApiEndpoints.getCustomerDetail,
        options: Options(
          headers: {
            'x-access-token': token,
          },
        ),
      );

      return CustomerDetailsResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
