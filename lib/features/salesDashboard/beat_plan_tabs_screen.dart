import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/beat_plan_doctor_screen.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Beat_Plan.dart';
import 'package:flutter/material.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';


class BeatPlanTabsScreen extends StatefulWidget {
  const BeatPlanTabsScreen({super.key});

  @override
  State<BeatPlanTabsScreen> createState() => _BeatPlanTabsScreenState();
}

class _BeatPlanTabsScreenState extends State<BeatPlanTabsScreen>
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
          const AppStatusBar(),

          /// ✅ Common AppBar
          Material(
            elevation: 3,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: AutoTranslateText(
                      'Beat Plan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          /// ✅ Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.purple,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.purple,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Dis-Ret Route'),
                Tab(text: 'Farmers Route'),
              ],
            ),
          ),

          /// ✅ Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                BeatPlanScreen(),
                BeatPlanDoctorScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
