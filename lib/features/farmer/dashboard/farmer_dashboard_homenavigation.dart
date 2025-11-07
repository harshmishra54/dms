import 'package:TrustTags_DMS/features/farmer/dashboard/farmer_dashboard.dart';
import 'package:TrustTags_DMS/features/home/presentation/history_screen.dart';
import 'package:TrustTags_DMS/features/home/presentation/profile_screen.dart';
import 'package:TrustTags_DMS/features/home/presentation/scan_screen.dart';
import 'package:TrustTags_DMS/features/home/presentation/schemes_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/widgets/custom_bottom_nav_bar.dart';
import '../../dashboard/provider/channel_performance_provider.dart';
import '../../dashboard/provider/dashboard_provider.dart';

class FarmerDashboardHomenavigation extends StatefulWidget {
  final int initialIndex;

  const FarmerDashboardHomenavigation({Key? key, this.initialIndex = 0})
      : super(key: key);

  @override
  State<FarmerDashboardHomenavigation> createState() =>
      _FarmerDashboardHomenavigationState();
}

class _FarmerDashboardHomenavigationState
    extends State<FarmerDashboardHomenavigation> {
  late int _selectedIndex;
  int? roleId;


  Future<void> _loadRoleId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // ❌ Wrong
      // roleId = prefs.getInt('roleId');

      // ✅ Correct (use the same key name you used in SharedPrefsHelper)
      roleId = prefs.getInt('role_id');
    });
  }

  final List<Widget> _screens = const [
    FarmerDashboard(),
    HistoryScreen(),
    ScanQRScreen(),
    SchemesScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _loadRoleId();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 0) {
      // ✅ Refresh Farmer Dashboard data when tab 0 is selected
      final channelProvider =
      Provider.of<ChannelPerformanceProvider>(context, listen: false);
      final dashboardProvider =
      Provider.of<DashboardProvider>(context, listen: false);

      channelProvider.fetchChannelPerformance();
      dashboardProvider.fetchDashboardData();
    }
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      return false; // Stay in app, just go to Dashboard
    }
    return true; // Allow back (exit) if already on Dashboard
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          roleId: roleId,
        ),
      ),
    );
  }
}
