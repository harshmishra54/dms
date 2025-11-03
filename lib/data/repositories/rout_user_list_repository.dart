import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import '../models/rout_visit_user_list_response.dart';

class RouteUserListRepository {
  final DioClient dioClient;

  RouteUserListRepository(this.dioClient);

  Future<RoutVisitUserListResponse> getRouteVisitUserList(
      String routeId,
      String token,
      ) async {
    final response = await dioClient.get(
      ApiEndpoints.routeLocations(routeId),
      options: Options(
        headers: {
          'x-access-token': token, // same as Android
        },
      ),
    );

    // response.data is Map<String, dynamic>
    return RoutVisitUserListResponse.fromJson(response.data);
  }
}
