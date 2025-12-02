import 'package:TrustTags_DMS/data/models/get_my_category_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';


class MyCategoryProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool isLoading = false;
  String? errorMessage;

  CategoryData? categoryData;

  // -------------------------------------------------------------
  // 🔥 Get My Category (POST API)
  // -------------------------------------------------------------
  Future<void> getMyCategory(int points) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      final requestBody = {
        "points": points,
      };

      final response = await _dioClient.post(
        ApiEndpoints.getmycategoryDIS,
        data: requestBody,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "x-access-token": token ?? "",
          },
        ),
      );

      final res = GetMyCategoryResponse.fromJson(response.data);

      if (res.success == 1) {
        categoryData = res.data;
      } else {
        errorMessage = res.message;
      }
    } catch (e) {
      errorMessage = "Something went wrong: $e";
    }

    isLoading = false;
    notifyListeners();
  }
}
