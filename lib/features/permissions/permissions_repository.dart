import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/data/models/permissions_model.dart';
import 'package:flutter/cupertino.dart';

class PermissionsRepository {
  final DioClient _dioClient;

  PermissionsRepository(this._dioClient);

  Future<PermissionsResponseModel> fetchPermissions(
      PermissionsRequestModel request,
      ) async {
    final response = await _dioClient.post(
      ApiEndpoints.permissionaccess,
      data: request.toJson(),
    );

    // 🔥 FULL RESPONSE LOG (IMPORTANT)
    debugPrint(
      response.data.toString(),
      wrapWidth: 2048,
    );

    return PermissionsResponseModel.fromJson(response.data);
  }

}
