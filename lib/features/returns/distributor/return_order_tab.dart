import 'package:TrustTags_DMS/features/returns/distributor/distributor_received_return_order.dart';
import 'package:TrustTags_DMS/features/returns/distributor/tsi_return_order.dart';
import 'package:flutter/material.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';

class ReturnOrderTab extends StatefulWidget {
  const ReturnOrderTab({super.key});

  @override
  State<ReturnOrderTab> createState() => _ReturnOrderTabState();
}

class _ReturnOrderTabState extends State<ReturnOrderTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          const AppStatusBar(), // For status bar padding

          // App Bar
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.white,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const Center(
                  child: Text(
                    'Return Orders',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar
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

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                DistributorReceivedReturnOrder(),
                TsiReturnCreated(),// Created return orders tab
                 // Placeholder for TSI tab
              ],
            ),
          ),
        ],
      ),
    );
  }
}
