import 'dart:convert';
import 'package:TrustTags_DMS/data/models/general_query_request.dart';
import 'package:TrustTags_DMS/data/models/product_recommendation_request.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class SmartProductRecommendationProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;

  // -------------------------
  // Product Recommendations
  // -------------------------
  List<Recomm> productRecommendations = [];

  // -------------------------
  // General Query
  // -------------------------
  String generalQueryAnswer = "";

  // -------------------------
  // Node server base URL
  // -------------------------
  final String baseUrl = "http://192.168.1.210:3000"; // Update if hosted elsewhere

  // -------------------------
  // Fetch Product Recommendations
  // -------------------------
  Future<void> fetchProductRecommendations(ProductRecommendationRequest request) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/recommend"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final parsed = ProductRecommendationResponse.fromJson(data);
        productRecommendations = parsed.recommendations;
      } else {
        error = "Failed to fetch product recommendations";
      }
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // -------------------------
  // Fetch General Query Answer
  // -------------------------
  Future<void> fetchGeneralQueryAnswer(GeneralQueryRequest request) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/agri_query"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final parsed = GeneralQueryResponse.fromJson(data);
        generalQueryAnswer = parsed.answer;
      } else {
        error = "Failed to fetch answer";
      }
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
