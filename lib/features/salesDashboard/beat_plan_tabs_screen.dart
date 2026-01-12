import 'package:TrustTags_DMS/core/permissions/feature_access.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/beat_plan_doctor_screen.dart';
import 'package:TrustTags_DMS/features/permissions/permissions_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Beat_Plan.dart';
import 'package:flutter/material.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class BeatPlanTabsScreen extends ConsumerStatefulWidget {
  final String? tsiId;

  const BeatPlanTabsScreen({super.key, this.tsiId});

  @override
  ConsumerState<BeatPlanTabsScreen> createState() =>
      _BeatPlanTabsScreenState();
}


class _BeatPlanTabsScreenState
    extends ConsumerState<BeatPlanTabsScreen>
    with SingleTickerProviderStateMixin
{
  late TabController _tabController;
  bool canCreateBeatPlan() {
    return ref
        .read(permissionsProvider.notifier)
        .hasPermission(
      FeatureAccess.beatPlan,
      create: true,
    );
  }


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
              children:  [
                BeatPlanScreen(tsiId: widget.tsiId,
                  canCreate: canCreateBeatPlan(),),
                BeatPlanDoctorScreen(tsiId: widget.tsiId,
                  canCreate: canCreateBeatPlan(),),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
