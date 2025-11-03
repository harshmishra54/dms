import 'dart:convert';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/data/models/smart_recommendation_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class RecommendationProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  RecommendationResponse? _recommendationResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RecommendationResponse? get recommendationResponse => _recommendationResponse;

  /// Fetch recommendations directly from external AI bot server
  Future<void> fetchRecommendations({
    required RecommendationRequest requestBody,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _recommendationResponse = null;
    notifyListeners();

    const String botServerUrl =
        'https://ai-recommendation-intelligence-system.onrender.com/recommend';

    try {
      final Response response = await _dioClient.client.post(
        botServerUrl, // ✅ Directly using full URL
        data: jsonEncode(requestBody.toJson()),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        _recommendationResponse =
            RecommendationResponse.fromJson(response.data);
      } else {
        _errorMessage = "Unexpected response format or empty data.";
      }
    } catch (error) {
      _errorMessage = error.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Optional: Reset provider state
  void clear() {
    _isLoading = false;
    _errorMessage = null;
    _recommendationResponse = null;
    notifyListeners();
  }
}
