import 'package:TrustTags_DMS/common/widgets/custom_bottom_nav_bar.dart';
import 'package:TrustTags_DMS/features/dashboard/distributor_history_screen.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/channel_performance_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/dashboard_provider.dart';
import 'package:TrustTags_DMS/features/home/presentation/retailer_scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dashboard_screen.dart';

import 'schemes_screen.dart';
import 'profile_screen.dart';


class HomeNavigation extends StatefulWidget {
  final int initialIndex;

  const HomeNavigation({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  late int _selectedIndex;

  final List<Widget> _screens = const [
    DashboardScreen(selectedRoleId: 1, selectedRole: 'user'),
    DistributorHistoryScreen(),
    RetailerScanQRScreen(),
    SchemesScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 0) {
      // ✅ Dashboard tab selected → refresh API
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
      // If not on Dashboard, go to Dashboard instead of exiting
      setState(() {
        _selectedIndex = 0;
      });
      return false;
    }
    return true; // Exit when already on Dashboard
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
        ),
      ),
    );
  }
}
