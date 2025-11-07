import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/crystal_doctor_dashboard.dart';
import 'package:TrustTags_DMS/features/dashboard/distributor_home_navigation.dart';
import 'package:TrustTags_DMS/features/farmer/dashboard/farmer_dashboard_homenavigation.dart';
import 'package:TrustTags_DMS/features/home/presentation/home_navigation.dart';
import 'package:TrustTags_DMS/features/salesDashboard/sales_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../common/widgets/app_status_bar.dart';
import '../../landing/presentation/landing_screen.dart';


class SplashScreenn extends StatefulWidget {
  const SplashScreenn({super.key});

  @override
  State<SplashScreenn> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreenn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    // Navigate after 3 seconds
    Future.delayed(const Duration(seconds: 3), () async {
      await _navigateNext();
    });
  }

  Future<void> _navigateNext() async {
    final token = await SharedPrefsHelper.getAccessToken();

    if (token != null && token.isNotEmpty) {
      final roleId = await SharedPrefsHelper.getRoleId();
      final roleName = await SharedPrefsHelper.getUserName(); // or use another field for role name

      if (!mounted) return;

      switch (roleId) {
        case 1:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DistributorHomeNavigation()),
          );
          break;

        case 18:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => SalesDashboardScreen()),
          );
          break;
        case 19:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => SalesDashboardScreen()),
          );
          break;
        case 23:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => CrystalDoctorDashboard()),
          );
          break;


        case 3:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeNavigation(
              ),
            ),
          );
          break;

        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const FarmerDashboardHomenavigation()),
          );
          break;

        default:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LandingScreen()),
          );
      }
    } else {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LandingScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            const AppStatusBar(),
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
                    color: Colors.purple,
                  ),
                ),
              ),
            ),
            Center(
              child: ScaleTransition(
                scale: _animation,
                child: Image.asset(
                  'assets/images/trust_tags.png',
                  width: 120,
                  height: 120,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
