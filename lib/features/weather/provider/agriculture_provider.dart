import 'dart:convert';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/data/models/agriculture_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;



class AgricultureProvider extends ChangeNotifier {
  AgricultureModel? agriculture;
  bool isLoading = false;

  Future<void> fetchAgricultureData(double lat, double lon) async {
    try {
      isLoading = true;
      notifyListeners();

      final url = ApiEndpoints.agricultureData
          .replaceAll("{lat}", lat.toString())
          .replaceAll("{lon}", lon.toString());

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        agriculture = AgricultureModel.fromJson(data);
      } else {
        throw Exception("Failed to fetch agriculture data");
      }
    } catch (e) {
      debugPrint("Agriculture Data Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
