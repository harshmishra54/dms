import 'package:TrustTags_DMS/data/models/recommendation_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class SmartRecommendationProvider extends ChangeNotifier {
  final Dio _dio = Dio();
  // Use your backend URL directly
  final String baseUrl = 'http://192.168.1.192:5000'; // <-- your Flask server

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Recommendation> _recommendations = [];
  List<Recommendation> get recommendations => _recommendations;

  String? _error;
  String? get error => _error;

  // Fetch recommendations from backend
  Future<void> fetchRecommendations({
    required String query,
    double area = 1,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.post(
        '$baseUrl/recommend',
        data: {
          "query": query,
          "area": area,
        },
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> recs = data['recommendations'] ?? [];

        _recommendations = recs
            .map((json) => Recommendation.fromJson(json))
            .toList();
      } else {
        _error = "Server returned status code ${response.statusCode}";
      }
    } catch (e) {
      _error = "Failed to fetch recommendations: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  // Clear recommendations
  void clear() {
    _recommendations = [];
    _error = null;
    notifyListeners();
  }
}
