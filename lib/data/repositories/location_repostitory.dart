import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
class LocationRepository {
  final DioClient dioClient;
  LocationRepository({required this.dioClient});

  Future<Map<String, dynamic>> getCityStateByPincode(String token, String pincode) async {
    final response = await dioClient.get(
      ApiEndpoints.getCityStateByPincode,
      queryParameters: {"pincode": pincode},
      options: Options(headers: {"x-access-token": token}),
    );

    if (response.data["success"].toString() == "1") {
      return response.data["data"];
    } else {
      throw Exception(response.data["message"]);
    }
  }

  Future<List<Map<String, dynamic>>> fetchStates(String token) async {
    final response = await dioClient.get(
      "/common/v2/state/101",
      options: Options(headers: {"x-access-token": token}),
    );
    if (response.data["success"].toString() == "1") {
      return List<Map<String, dynamic>>.from(response.data["data"]);
    } else {
      throw Exception(response.data["message"]);
    }
  }

  Future<List<Map<String, dynamic>>> fetchDistricts(String token, int stateId) async {
    final response = await dioClient.get(
      "/common/v2/district/$stateId",
      options: Options(headers: {"x-access-token": token}),
    );
    if (response.data["success"].toString() == "1") {
      return List<Map<String, dynamic>>.from(response.data["data"]);
    } else {
      throw Exception(response.data["message"]);
    }
  }
}
