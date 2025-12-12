class WeatherModel {
  // Current weather
  final double temperature;
  final double windSpeed;
  final double humidity;
  final double uvIndex;
  final double feelsLike;
  final double pressure;
  final double visibility;
  final double precipitation;
  final String conditionCode;
  final double cloudCover;
  final double dewPoint;

  // Daily forecast
  final List<double> dailyMaxTemp;
  final List<double> dailyMinTemp;
  final List<String> dailyWeatherCode;
  final List<String> sunrise;
  final List<String> sunset;

  // Optional: future fields
  final String? airQuality; // e.g., "Good", "Moderate", etc.
  final String? weatherDescription; // e.g., "Sunny", "Cloudy"

  WeatherModel({
    required this.temperature,
    required this.windSpeed,
    required this.humidity,
    required this.uvIndex,
    required this.feelsLike,
    required this.pressure,
    required this.visibility,
    required this.precipitation,
    required this.conditionCode,
    required this.cloudCover,
    required this.dewPoint,
    required this.dailyMaxTemp,
    required this.dailyMinTemp,
    required this.dailyWeatherCode,
    required this.sunrise,
    required this.sunset,
    this.airQuality,
    this.weatherDescription,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: (json["current"]["temperature_2m"] ?? 0).toDouble(),
      windSpeed: (json["current"]["wind_speed_10m"] ?? 0).toDouble(),
      humidity: (json["current"]["relative_humidity_2m"] ?? 0).toDouble(),
      uvIndex: (json["current"]["uv_index"] ?? 0).toDouble(),
      feelsLike: (json["current"]["apparent_temperature"] ?? 0).toDouble(),
      pressure: (json["current"]["surface_pressure"] ?? 0).toDouble(),
      visibility: (json["current"]["visibility"] ?? 0).toDouble(),
      precipitation: (json["current"]["precipitation"] ?? 0).toDouble(),
      conditionCode: json["current"]["weather_code"]?.toString() ?? "Unknown",
      cloudCover: (json["current"]["cloud_cover"] ?? 0).toDouble(),
      dewPoint: (json["current"]["dew_point_2m"] ?? 0).toDouble(),

      dailyMaxTemp: ((json["daily"]["temperature_2m_max"] ?? []) as List)
          .map((e) => (e ?? 0).toDouble())
          .toList()
          .cast<double>(),

      dailyMinTemp: ((json["daily"]["temperature_2m_min"] ?? []) as List)
          .map((e) => (e ?? 0).toDouble())
          .toList()
          .cast<double>(),

      dailyWeatherCode: (json["daily"]["weather_code"] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      sunrise: (json["daily"]["sunrise"] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      sunset: (json["daily"]["sunset"] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],

      // Optional future fields (default null)
      airQuality: json["air_quality"]?.toString(),
      weatherDescription: json["weather_description"]?.toString(),
    );
  }
}
