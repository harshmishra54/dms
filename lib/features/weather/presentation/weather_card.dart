import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../provider/weather_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;

class WeatherDashboardScreen extends StatefulWidget {
  const WeatherDashboardScreen({super.key});

  @override
  State<WeatherDashboardScreen> createState() => _WeatherDashboardScreenState();
}

class _WeatherDashboardScreenState extends State<WeatherDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _shimmerController;

  // Advanced Weather Intelligence System
  Map<String, dynamic> analyzeWeatherConditions(dynamic w) {
    return {
      'comfort': _calculateComfortIndex(w),
      'airQuality': _estimateAirQuality(w),
      'activities': _suggestActivities(w),
      'healthAlerts': _generateHealthAlerts(w),
      'outfit': _suggestOutfit(w),
      'energyTip': _getEnergyTip(w),
    };
  }

  String _calculateComfortIndex(dynamic w) {
    double temp = w.temperature.toDouble();
    double humidity = w.humidity.toDouble();
    double windSpeed = w.windSpeed.toDouble();

    // Heat Index calculation
    double heatIndex = temp;
    if (temp >= 27 && humidity >= 40) {
      heatIndex = -8.78469475556 +
          1.61139411 * temp +
          2.33854883889 * humidity +
          -0.14611605 * temp * humidity +
          -0.012308094 * temp * temp +
          -0.0164248277778 * humidity * humidity +
          0.002211732 * temp * temp * humidity +
          0.00072546 * temp * humidity * humidity +
          -0.000003582 * temp * temp * humidity * humidity;
    }

    // Wind chill for cold weather
    if (temp <= 10 && windSpeed > 4.8) {
      heatIndex = 13.12 + 0.6215 * temp - 11.37 * math.pow(windSpeed, 0.16) +
          0.3965 * temp * math.pow(windSpeed, 0.16);
    }

    if (heatIndex >= 80) return "⚠️ Dangerous";
    if (heatIndex >= 60) return "😰 Uncomfortable";
    if (heatIndex >= 40) return "🌡️ Warm";
    if (heatIndex >= 20) return "😊 Comfortable";
    if (heatIndex >= 10) return "🧥 Cool";
    return "🥶 Very Cold";
  }

  String _estimateAirQuality(dynamic w) {
    int score = 100;

    // Factors affecting air quality
    if (w.humidity > 85) score -= 15;
    if (w.humidity < 30) score -= 10;
    if (w.windSpeed < 5) score -= 20;
    if (w.pressure < 1000) score -= 10;
    if (w.cloudCover > 90) score -= 5;

    if (w.conditionCode.toLowerCase().contains("rain")) score += 15;
    if (w.windSpeed > 15) score += 10;

    score = score.clamp(0, 100);

    if (score >= 90) return "🌿 Excellent (${score}/100)";
    if (score >= 70) return "✅ Good (${score}/100)";
    if (score >= 50) return "⚠️ Moderate (${score}/100)";
    if (score >= 30) return "😷 Poor (${score}/100)";
    return "🚫 Very Poor (${score}/100)";
  }

  List<String> _suggestActivities(dynamic w) {
    List<String> activities = [];
    double temp = w.temperature.toDouble();
    String condition = w.conditionCode.toLowerCase();
    double uvIndex = (w.uvIndex ?? 0).toDouble();

    if (condition.contains("sunny") && temp >= 20 && temp <= 30 && uvIndex < 7) {
      activities.add("🏃 Perfect for outdoor running");
      activities.add("🚴 Great cycling weather");
      activities.add("🏖️ Beach day recommended");
    } else if (condition.contains("rain")) {
      activities.add("📚 Indoor reading time");
      activities.add("🎬 Movie marathon weather");
      activities.add("☕ Cozy café visit");
    } else if (temp < 15 && !condition.contains("rain")) {
      activities.add("⛸️ Ice skating conditions");
      activities.add("🥾 Brisk hiking weather");
      activities.add("☕ Hot beverage perfect");
    } else if (condition.contains("cloudy") && temp >= 18 && temp <= 28) {
      activities.add("📸 Photography lighting ideal");
      activities.add("🚶 Pleasant walking weather");
      activities.add("🧘 Outdoor yoga suitable");
    }

    if (w.windSpeed > 20) {
      activities.add("🪁 Kite flying conditions");
    }

    if (activities.isEmpty) {
      activities.add("🏠 Indoor activities recommended");
    }

    return activities;
  }

  List<String> _generateHealthAlerts(dynamic w) {
    List<String> alerts = [];

    if (w.uvIndex >= 8) {
      alerts.add("☀️ EXTREME UV: Sunscreen SPF 50+ required");
    } else if (w.uvIndex >= 6) {
      alerts.add("🕶️ HIGH UV: Wear sunglasses & hat");
    }

    if (w.temperature > 35) {
      alerts.add("🚨 Heat Warning: Drink 3-4L water today");
    } else if (w.temperature < 0) {
      alerts.add("❄️ Frostbite Risk: Cover exposed skin");
    }

    if (w.humidity > 85) {
      alerts.add("💧 High Humidity: Asthma caution");
    } else if (w.humidity < 30) {
      alerts.add("🏜️ Low Humidity: Use moisturizer");
    }

    double feelsLikeDiff = (w.feelsLike - w.temperature).abs();
    if (feelsLikeDiff > 8) {
      alerts.add("🌡️ Large temp variance: Layer clothing");
    }

    if (w.windSpeed > 30) {
      alerts.add("💨 Strong winds: Secure loose objects");
    }

    if (alerts.isEmpty) {
      alerts.add("✅ No health alerts today");
    }

    return alerts;
  }

  String _suggestOutfit(dynamic w) {
    double temp = w.temperature.toDouble();
    String condition = w.conditionCode.toLowerCase();
    double windSpeed = w.windSpeed.toDouble();

    if (temp >= 30) {
      return "👕 Light clothes: T-shirt, shorts, sunhat";
    } else if (temp >= 25) {
      return "👔 Summer wear: Light shirt, comfortable pants";
    } else if (temp >= 20) {
      return "👗 Spring outfit: Long sleeves, light jacket";
    } else if (temp >= 15) {
      return "🧥 Layered look: Sweater with jacket";
    } else if (temp >= 10) {
      return "🧥 Warm layers: Coat, scarf recommended";
    } else if (temp >= 0) {
      return "🧣 Winter gear: Heavy coat, gloves, hat";
    } else {
      return "❄️ Extreme cold: Insulated layers, face cover";
    }
  }

  String _getEnergyTip(dynamic w) {
    if (w.temperature < 10) {
      return "💡 High heating costs expected - seal windows";
    } else if (w.temperature > 28) {
      return "🌡️ AC usage high - use fans for efficiency";
    } else if (w.cloudCover < 30) {
      return "☀️ Solar energy optimal - charge devices";
    } else if (w.windSpeed > 20) {
      return "💨 Wind energy abundant today";
    }
    return "🔋 Moderate energy conditions";
  }

  String generateWeatherAdvice(dynamic w) {
    List<String> advice = [];

    if (w.temperature > 35) {
      advice.add("🔥 Extreme heat! Stay indoors 11AM-4PM");
    } else if (w.temperature < 10) {
      advice.add("🥶 Bundle up! Layers are essential");
    }

    if ((w.feelsLike - w.temperature).abs() > 5) {
      advice.add("🌡️ Feels like ${w.feelsLike}°C - dress accordingly");
    }

    if (w.humidity > 80) {
      advice.add("💧 High humidity - expect sticky conditions");
    }

    double uvIndex = (w.uvIndex ?? 0).toDouble();
    if (uvIndex >= 7) {
      advice.add("☀️ Dangerous UV levels - sunscreen mandatory");
    }

    if (w.conditionCode.toLowerCase().contains("rain") || (w.precipitation ?? 0) > 50) {
      advice.add("☔ Rain expected - carry umbrella");
    }

    if (w.windSpeed > 20) {
      advice.add("💨 Windy conditions - secure loose items");
    }

    if (advice.isEmpty) advice.add("✨ Perfect weather - enjoy your day!");

    return advice.join("\n");
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) return;

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final provider = context.read<WeatherProvider>();
      await provider.fetchWeather(pos.latitude, pos.longitude);

      _controller.forward();
      _slideController.forward();
    } catch (e) {}
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  IconData weatherIcon(String code) {
    switch (code) {
      case "Cloudy":
        return Icons.cloud;
      case "Rain":
        return Icons.water_drop;
      case "Sunny":
        return Icons.wb_sunny;
      case "Fog":
        return Icons.cloud_queue;
      case "Snow":
        return Icons.ac_unit;
      default:
        return Icons.wb_cloudy;
    }
  }

  LinearGradient _getWeatherGradient(String? code) {
    switch (code) {
      case "Sunny":
        return LinearGradient(
          colors: [Color(0xFFF57C00), Color(0xFFFF6F00), Color(0xFFE65100)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case "Rain":
        return LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case "Cloudy":
        return LinearGradient(
          colors: [Color(0xFF455A64), Color(0xFF546E7A), Color(0xFF607D8B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: provider.weather != null
                    ? _getWeatherGradient(provider.weather!.conditionCode).colors
                    : [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          ...List.generate(30, (i) => _FloatingParticle(index: i)),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: provider.isLoading
                      ? _buildLoader()
                      : provider.error != null
                      ? _error(provider.error!)
                      : provider.weather == null
                      ? _noData()
                      : FadeTransition(
                    opacity: _controller,
                    child: _weatherUI(provider.weather!),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Weather",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                "AI-Powered Insights",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.8),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _loadWeather,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(Icons.refresh_rounded, color: Colors.white, size: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
              ),
              child: const Icon(Icons.cloud, color: Colors.white, size: 48),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Analyzing weather patterns...",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _error(String msg) => Center(
    child: Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    ),
  );

  Widget _noData() => Center(
    child: ElevatedButton(
      onPressed: _loadWeather,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF764BA2),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: const Text("Load Weather", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    ),
  );

  Widget _weatherUI(w) {
    final intelligence = analyzeWeatherConditions(w);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: const SizedBox(height: 20)),
        SliverToBoxAdapter(
          child: SlideTransition(
            position: Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
              CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
            ),
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: _header(w)),
          ),
        ),
        SliverToBoxAdapter(child: const SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _aiInsightsCard(intelligence),
          ),
        ),
        SliverToBoxAdapter(child: const SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _todayHighlights(w),
          ),
        ),
        SliverToBoxAdapter(child: const SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _intelligenceCards(intelligence),
          ),
        ),
        SliverToBoxAdapter(child: const SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _infoGrid(w),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _header(w) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            blurRadius: 40,
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 20),
          ),
        ],
      ),
      padding: const EdgeInsets.all(36),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(weatherIcon(w.conditionCode), size: 80, color: Colors.white),
          ),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [Colors.white, Colors.white.withOpacity(0.9)],
            ).createShader(bounds),
            child: Text(
              "${w.temperature}°",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 96,
                fontWeight: FontWeight.w900,
                letterSpacing: -4,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            w.conditionCode,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Feels like ${w.feelsLike}°C",
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiInsightsCard(Map<String, dynamic> intelligence) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.psychology, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                "AI Weather Analysis",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _insightRow("Comfort Level", intelligence['comfort']),
          _insightRow("Air Quality", intelligence['airQuality']),
          _insightRow("Outfit", intelligence['outfit']),
          _insightRow("Energy Tip", intelligence['energyTip']),
        ],
      ),
    );
  }

  Widget _insightRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _intelligenceCards(Map<String, dynamic> intelligence) {
    return Column(
      children: [
        _expandableCard(
          "🎯 Recommended Activities",
          (intelligence['activities'] as List<String>).join("\n"),
          FontAwesomeIcons.running,
        ),
        const SizedBox(height: 16),
        _expandableCard(
          "⚕️ Health Alerts",
          (intelligence['healthAlerts'] as List<String>).join("\n"),
          FontAwesomeIcons.heartPulse,
        ),
      ],
    );
  }

  Widget _expandableCard(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FaIcon(icon, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _todayHighlights(w) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Highlights",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                blurRadius: 30,
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _highlightItem("Max", "${w.dailyMaxTemp[0]}°", FontAwesomeIcons.temperatureHigh),
              _divider(),
              _highlightItem("Min", "${w.dailyMinTemp[0]}°", FontAwesomeIcons.temperatureLow),
              _divider(),
              _highlightItem("Clouds", "${w.cloudCover}%", FontAwesomeIcons.cloud),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _sunriseSunset(w),
      ],
    );
  }

  Widget _divider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _highlightItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: FaIcon(icon, size: 20, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(title, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _sunriseSunset(w) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.withOpacity(0.3), Colors.deepOrange.withOpacity(0.3)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _sunTile("Sunrise", w.sunrise[0], Icons.wb_sunny_outlined),
          _sunTile("Sunset", w.sunset[0], Icons.nightlight_round),
        ],
      ),
    );
  }

  Widget _sunTile(String title, String time, IconData icon) {
    String timeOnly = time;

    if (time.contains('T')) {
      timeOnly = time.split('T').last.substring(0, 5);
    } else if (time.contains(' ')) {
      final parts = time.split(' ');
      if (parts.length > 1) {
        timeOnly = parts[1].substring(0, 5);
      }
    } else if (time.contains(':')) {
      timeOnly = time.substring(0, 5);
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(timeOnly, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _infoGrid(w) {
    final metrics = [
      _Metric("Humidity", "${w.humidity}%", FontAwesomeIcons.droplet),
      _Metric("Wind", "${w.windSpeed} km/h", FontAwesomeIcons.wind),
      _Metric("UV Index", "${w.uvIndex}", FontAwesomeIcons.sun),
      _Metric("Visibility", "${w.visibility} m", FontAwesomeIcons.eye),
      _Metric("Pressure", "${w.pressure} hPa", FontAwesomeIcons.gaugeHigh),
      _Metric("Dew Point", "${w.dewPoint}°C", FontAwesomeIcons.temperatureHalf),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, i) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 400 + (i * 100)),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(opacity: value, child: _metricTile(metrics[i])),
          );
        },
      ),
    );
  }

  Widget _metricTile(_Metric m) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 8),
          )
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: FaIcon(m.icon, color: Colors.white, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                m.title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                m.value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric {
  final String title;
  final String value;
  final IconData icon;

  _Metric(this.title, this.value, this.icon);
}

class _FloatingParticle extends StatefulWidget {
  final int index;

  const _FloatingParticle({required this.index});

  @override
  State<_FloatingParticle> createState() => _FloatingParticleState();
}

class _FloatingParticleState extends State<_FloatingParticle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  final random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3 + random.nextInt(4)),
    )..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: Offset(random.nextDouble() * 2 - 1, random.nextDouble() * 2 - 1),
      end: Offset(random.nextDouble() * 2 - 1, random.nextDouble() * 2 - 1),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned(
      left: random.nextDouble() * size.width,
      top: random.nextDouble() * size.height,
      child: SlideTransition(
        position: _animation,
        child: Container(
          width: 3 + random.nextDouble() * 8,
          height: 3 + random.nextDouble() * 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2 + random.nextDouble() * 0.3),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}