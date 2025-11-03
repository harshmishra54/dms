import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/features/dashboard/widgets/order_created.dart';
import 'package:TrustTags_DMS/features/dashboard/widgets/tsi_order_created.dart';
import 'package:flutter/material.dart';
class DistributorHistoryScreen extends StatefulWidget {
  final int? initialTabIndex; // Add this

  const DistributorHistoryScreen({super.key, this.initialTabIndex = 0}); // Default to 0

  @override
  State<DistributorHistoryScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<DistributorHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex ?? 0, // use 0 as default
    );

  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const AppStatusBar(),
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Spacer(),
                Text(
                  'Order Details',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
          Container(
            color: const Color(0xFFE0E0E0),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.deepPurple,
              labelColor: Colors.black,
              indicatorWeight: 2,
              tabs: const [
                Tab(text: 'Created'),
                Tab(text: 'TSI'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                DistributorOrderCreated(),
                OrdersScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
