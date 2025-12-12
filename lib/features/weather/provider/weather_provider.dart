import 'package:flutter/material.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/data/models/weather_model.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherModel? weather;
  bool isLoading = false;
  String? error;

  Future<void> fetchWeather(double lat, double lon) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final response = await DioClient().get(
        ApiEndpoints.getWeather,
        // <-- use queryParameters (name your DioClient expects)
        queryParameters: {
          "latitude": lat,
          "longitude": lon,
          "current":
          "temperature_2m,relative_humidity_2m,wind_speed_10m,apparent_temperature,"
              "surface_pressure,uv_index,visibility,precipitation,weather_code,"
              "cloud_cover,dew_point_2m",
          "daily":
          "temperature_2m_max,temperature_2m_min,weather_code,sunrise,sunset",
          "timezone": "auto",
        },
      );

      // response is a Dio Response; use response.data
      final data = response.data;
      if (data == null || data is! Map<String, dynamic>) {
        throw Exception("Invalid weather response");
      }

      weather = WeatherModel.fromJson(data);
      error = null;
    } catch (e) {
      debugPrint("Weather fetch error: $e");
      error = e.toString();
      weather = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
