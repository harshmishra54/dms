class AgricultureModel {
  final String soilType;
  final double soilMoisture;
  final double soilPh;
  final Map<String, double> nutrients; // NPK or micronutrients
  final String recommendedCrop;
  final double rainProbability;
  final double temperature;
  final double humidity;

  AgricultureModel({
    required this.soilType,
    required this.soilMoisture,
    required this.soilPh,
    required this.nutrients,
    required this.recommendedCrop,
    required this.rainProbability,
    required this.temperature,
    required this.humidity,
  });

  factory AgricultureModel.fromJson(Map<String, dynamic> json) {
    return AgricultureModel(
      soilType: json["soil_type"] ?? "",
      soilMoisture: (json["soil_moisture"] ?? 0).toDouble(),
      soilPh: (json["soil_ph"] ?? 0).toDouble(),
      nutrients: Map<String, double>.from(
        (json["nutrients"] ?? {}).map(
              (key, value) => MapEntry(key, value.toDouble()),
        ),
      ),
      recommendedCrop: json["recommended_crop"] ?? "",
      rainProbability: (json["rain_probability"] ?? 0).toDouble(),
      temperature: (json["temperature"] ?? 0).toDouble(),
      humidity: (json["humidity"] ?? 0).toDouble(),
    );
  }
}
