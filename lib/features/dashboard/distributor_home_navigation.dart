import 'package:TrustTags_DMS/features/dashboard/distributor_history_screen.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/channel_performance_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/dashboard_provider.dart';
import 'package:TrustTags_DMS/features/home/presentation/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/custom_bottom_nav_bar.dart';
import 'distributor_dashboard.dart';
import 'distributor_scan_screen.dart';
import 'distributor_schemes_screen.dart';


class DistributorHomeNavigation extends StatefulWidget {
  final int initialIndex;
  final String? dashboardHighlight; // ✅ NEW → can tell dashboard which action to highlight

  const DistributorHomeNavigation({
    Key? key,
    this.initialIndex = 0,
    this.dashboardHighlight,
  }) : super(key: key);

  @override
  State<DistributorHomeNavigation> createState() =>
      _DistributorHomeNavigationState();
}

class _DistributorHomeNavigationState
    extends State<DistributorHomeNavigation> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 0) {
      // ✅ Dashboard tab selected → refresh APIs
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
      return false; // Stay in app, just switch to dashboard
    }
    return true; // Allow exit when already on dashboard
  }

  List<Widget> get _screens => [
    DistributorDashboard(highlightAction: widget.dashboardHighlight), // ✅ pass down
    const DistributorHistoryScreen(),
    // const DistributorScanScreen(),
    DistributorDashboard(highlightAction: 'scan'),
    const DistributorSchemesScreen(),
    const ProfileScreen(),
  ];

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
