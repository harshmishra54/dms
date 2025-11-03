import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import '../models/rout_list_response.dart';

class RoutRepository {
  final DioClient dioClient;
  RoutRepository(this.dioClient);

  Future<RoutListResponse> fetchRoutes({
    required String token,
    required String tsmId,
  }) async {
    final response = await dioClient.get(
      ApiEndpoints.getRoutList(tsmId),

      options: Options(
        headers: {
          'x-access-token': token,
        },
      ),
    );

    return RoutListResponse.fromJson(response.data);
  }
}
