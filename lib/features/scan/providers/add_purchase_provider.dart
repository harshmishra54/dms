import 'package:TrustTags_DMS/data/models/add_purchase_prod_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';


class AddPurchaseProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AddPurchaseProdResponse? _responseModel;
  AddPurchaseProdResponse? get responseModel => _responseModel;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// ------------------------------
  /// 🔥 CALL API — Add Purchase Product
  /// ------------------------------
  Future<bool> addPurchaseProduct({
    required String userId,
    required String cropName,
    required int roleId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      final response = await DioClient().post(
        ApiEndpoints.addpurchaseprod,
        data: {
          "user_id": userId,
          "crop_name": cropName,
          "role_id": roleId,
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "x-access-token": token ?? "",
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        _responseModel = AddPurchaseProdResponse.fromJson(response.data);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Something went wrong!";
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
