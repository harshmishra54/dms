// farmer_consideration_provider.dart
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/data/models/farmer_consideration_model.dart';
import 'package:flutter/material.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:dio/dio.dart';


class FarmerConsiderationProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  List<Farmer> _farmers = [];
  List<Farmer> get farmers => _farmers;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  /// Fetch Consideration Farmers
  Future<void> fetchConsideration({required String createdBy}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      final request = FarmerConsiderationRequest(createdBy: createdBy);

      final Response response = await _dioClient.post(
        ApiEndpoints.consideration,
        data: request.toJson(),
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "x-access-token": token ?? "",
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = FarmerConsiderationResponse.fromJson(response.data);
        if (data.success == 1) {
          _farmers = data.farmers;
        } else {
          _error = data.message;
        }
      } else {
        _error = "Error: ${response.statusCode}";
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Clear Farmers List
  void clear() {
    _farmers = [];
    _error = null;
    notifyListeners();
  }
}
