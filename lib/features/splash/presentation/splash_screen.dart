import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/crystal_doctor_dashboard.dart';
import 'package:TrustTags_DMS/features/dashboard/distributor_home_navigation.dart';
import 'package:TrustTags_DMS/features/farmer/dashboard/farmer_dashboard_homenavigation.dart';
import 'package:TrustTags_DMS/features/home/presentation/home_navigation.dart';
import 'package:TrustTags_DMS/features/salesDashboard/sales_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../landing/presentation/landing_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () async {
      await _navigateNext();
    });
  }

  Future<void> _navigateNext() async {
    final token = await SharedPrefsHelper.getAccessToken();

    if (token != null && token.isNotEmpty) {
      final roleId = await SharedPrefsHelper.getRoleId();

      if (!mounted) return;

      Widget nextScreen;

      switch (roleId) {
        case 1:
          nextScreen = const DistributorHomeNavigation();
          break;
        case 18:
        case 19:
          nextScreen = SalesDashboardScreen();
          break;
        case 23:
          nextScreen = CrystalDoctorDashboard();
          break;
        case 3:
          nextScreen = HomeNavigation();
          break;
        case 0:
          nextScreen = const FarmerDashboardHomenavigation();
          break;
        default:
          nextScreen = const LandingScreen();
      }

      if (!mounted) return;
      _navigateWithFade(nextScreen);
    } else {
      if (!mounted) return;
      _navigateWithFade(const LandingScreen());
    }
  }

  void _navigateWithFade(Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Custom status bar color for splash screen
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Make it transparent to show gradient
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA), Color(0xFFF3E5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Removed AppStatusBar, using custom status bar above
            Positioned(
              top: screenHeight * 0.12,
              left: 0,
              right: 0,
              child: const Center(
                child: AutoTranslateText(
                  'TrustTags-DMS',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Image.asset(
                    'assets/images/trust_tags.png',
                    width: 130,
                    height: 130,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: screenHeight * 0.25,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: const Center(
                  child: AutoTranslateText(
                    "Empowering Growth",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: screenHeight * 0.15,
              left: 0,
              right: 0,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
