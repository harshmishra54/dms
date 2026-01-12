import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/crystal_doctor_dashboard.dart';
import 'package:TrustTags_DMS/features/dashboard/distributor_home_navigation.dart';
import 'package:TrustTags_DMS/features/farmer/dashboard/farmer_dashboard_homenavigation.dart';
import 'package:TrustTags_DMS/features/home/presentation/home_navigation.dart';
import 'package:TrustTags_DMS/features/salesDashboard/sales_dashboard_screen.dart';
import 'package:TrustTags_DMS/features/landing/presentation/landing_screen.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';

import 'package:TrustTags_DMS/features/permissions/permissions_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
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

    _initFlow();
  }

  Future<void> _initFlow() async {
    await _requestPermissions();

    final token = await SharedPrefsHelper.getAccessToken();
    if (token != null && token.isNotEmpty) {
      final roleId = await SharedPrefsHelper.getRoleId();

      // ❌ Skip permissions API for these roles
      if (roleId != 0 && roleId != 1 && roleId != 3) {
        final notifier = ref.read(permissionsProvider.notifier);

        // ✅ Step 1: load cached permissions immediately
        await notifier.hydrateFromCache();

        // ✅ Step 2: refresh from API (overwrites cache)
        await notifier.loadPermissions();
      }

    }

    await _navigateNext();
  }


  /// 📱 Runtime permissions
  Future<void> _requestPermissions() async {
    if (const bool.fromEnvironment('FLUTTER_TEST')) return;
    await [
      Permission.camera,
      Permission.notification,
      Permission.location,
      Permission.storage,
      Permission.photos,
      Permission.mediaLibrary,
      Permission.contacts,
    ].request();
  }

  /// 🔐 Load permissions via Riverpod (API + save handled inside provider)
  Future<void> _loadPermissions() async {
    final notifier = ref.read(permissionsProvider.notifier);
    await notifier.loadPermissions();
  }

  /// 🚦 Decide next screen
  Future<void> _navigateNext() async {
    final token = await SharedPrefsHelper.getAccessToken();

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      _navigateWithFade(const LandingScreen());
      return;
    }

    final roleId = await SharedPrefsHelper.getRoleId();

    Widget nextScreen;

    if (roleId != null && roleId >= 18) {
      nextScreen = SalesDashboardScreen();
    }else {
      switch (roleId) {
        case 1:
          nextScreen = const DistributorHomeNavigation();
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
    }

    _navigateWithFade(nextScreen);
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

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6A1B9A),
              Color(0xFF8E24AA),
              Color(0xFFF3E5F5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: screenHeight * 0.12,
              left: 0,
              right: 0,
              child: const Center(
                child: AutoTranslateText(
                  'Crystal-DMS',
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
                    'assets/images/crystal_logo.jpeg',
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
