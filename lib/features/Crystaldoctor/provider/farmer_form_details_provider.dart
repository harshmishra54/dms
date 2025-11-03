import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/data/models/farmer_form_details_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

// Import necessary core utility files
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';


// Note: Replace 'your_app_name' with your actual package name

class FarmerFormDetailsProvider extends ChangeNotifier {
  // 1. Instantiate DioClient directly within the provider (SIMPLE approach)
  final DioClient _dioClient = DioClient();

  List<FarmerDetail> _farmers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<FarmerDetail> get farmers => _farmers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchFarmersByCreator() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Get Authentication Details
      final token = await SharedPrefsHelper.getAccessToken();
      final createdById = await SharedPrefsHelper.getUserId();

      if (token == null || createdById == null) {
        _errorMessage = "Authentication or User ID not found. Please log in again.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      // 2. Prepare Request Data
      final requestBody = GetDetailsByCreatorRequest(createdBy: createdById).toJson();

      final options = Options(
        headers: {
          'x-access-token': token,
        },
      );

      // 3. Make the API Call
      final Response response = await _dioClient.post(
        ApiEndpoints.getdetailsbycreator,
        data: requestBody,
        options: options,
      );

      // 4. Process the Response
      if (response.statusCode == 200 && response.data != null) {
        final apiResponse = FarmerApiResponse.fromJson(response.data);

        if (apiResponse.success == 1) {
          _farmers = apiResponse.data;
          _errorMessage = null;
        } else {
          _errorMessage = apiResponse.message.isNotEmpty
              ? apiResponse.message
              : "Failed to fetch farmers.";
          _farmers = [];
        }
      } else {
        _errorMessage = "Request failed with status: ${response.statusCode}";
        _farmers = [];
      }
    } on DioException {
      _errorMessage = "Network or Server error occurred.";
      _farmers = [];
    } catch (e) {
      _errorMessage = " ${e.toString()}";
      _farmers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}