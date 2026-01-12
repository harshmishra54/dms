import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/permissions/feature_access.dart';
import 'package:TrustTags_DMS/features/permissions/permissions_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/beat_plan_tabs_screen.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/get_childs_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:TrustTags_DMS/features/orders/presentation/distributors_screen.dart';
import 'package:TrustTags_DMS/features/orders/presentation/my_screen.dart';
import 'package:TrustTags_DMS/features/orders/presentation/retailers_screen.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Add_meeting.dart';
import 'package:TrustTags_DMS/features/salesDashboard/stock_summary_dist-ret_screen.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Expense/Expense_Management.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Leave/Leave_Management.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';

class BottomBar extends ConsumerStatefulWidget {
  const BottomBar({super.key});

  @override
  ConsumerState<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends ConsumerState<BottomBar> {

  bool _isExpanded = false;



  FeatureAccess? featureFromLabel(String label) {
    switch (label) {
      case "Beat Plan":
        return FeatureAccess.beatPlan;
      case "Meeting":
        return FeatureAccess.meeting;
      case "Stock Summary":
        return FeatureAccess.viewStockOfDistributer;
      case "Expense":
        return FeatureAccess.expense;
      case "Distributor":
        return FeatureAccess.DistributerOrder;
      case "Retailer":
        return FeatureAccess.RetailerOrder;
      case "Order":
        return FeatureAccess.placeOrderOnBehalfOfDistributer;
      case "Leave":
        return FeatureAccess.leaveManagement;
      default:
        return null;
    }
  }





  @override
  void initState() {
    super.initState();

  }
  bool canView(FeatureAccess feature) {
    return ref
        .read(permissionsProvider.notifier)
        .hasPermission(feature, view: true);
  }

  bool canCreate(FeatureAccess feature) {
    return ref
        .read(permissionsProvider.notifier)
        .hasPermission(feature, create: true);
  }
  Future<void> _handleSelfOrChildNavigation({
    required BuildContext context,
    required FeatureAccess selfFeature,
    required FeatureAccess childFeature,
    required Widget Function({String? childId}) onNavigate,
  }) async {
    final userId = await SharedPrefsHelper.getUserId();
    if (userId == null) return;

    // 🔥 Fetch childs
    await ref.read(getChildsProvider.notifier).fetchChilds(id: userId);

    final state = ref.read(getChildsProvider);

    state.when(
      loading: () {},
      error: (e, _) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      },
      data: (childs) {
        // =====================
        // 🔹 NO CHILDS → SELF
        // =====================
        if (childs.isEmpty) {
          if (!canView(selfFeature)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: AutoTranslateText(
                  "You don't have permission to access this",
                ),
              ),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => onNavigate(),
            ),
          );
          return;
        }

        // =====================
        // 🔹 CHILDS EXIST
        // =====================
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) {
            return SafeArea(
              child: ListView(
                shrinkWrap: true,
                children: [
                  /// 🔹 SELF
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const AutoTranslateText("Self"),
                    onTap: () {
                      Navigator.pop(context);

                      if (!canView(selfFeature)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: AutoTranslateText(
                              "You don't have permission to access this",
                            ),
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => onNavigate(),
                        ),
                      );
                    },
                  ),

                  const Divider(),

                  /// 🔹 CHILDS
                  ...childs.map(
                        (child) => ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: AutoTranslateText(child.name),
                      onTap: () {
                        Navigator.pop(context);

                        if (!canView(childFeature)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: AutoTranslateText(
                                "You don't have permission to access this",
                              ),
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                onNavigate(childId: child.id),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    const int crossAxisCount = 4;
    const double itemHeight = 96;

    const double arrowHeight = 48;
    const double collapsedHeight = arrowHeight + itemHeight;
    const double expandedHeight = arrowHeight + (itemHeight * 2); // 2 rows

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        height: _isExpanded ? expandedHeight : collapsedHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 8),
          ],
        ),
        child: Column(
          children: [
            /// 🔼 Animated Arrow (compact)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: SizedBox(
                height: arrowHeight,
                child: Center(
                  child: AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 280),
                    child: const Icon(
                      Icons.keyboard_arrow_up,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),

            /// 📦 Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: crossAxisCount,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 0.85,
                  children: [
                    buildFeatureIcon(context, "Beat Plan", Icons.local_shipping),
                    buildFeatureIcon(context, "Meeting", Icons.meeting_room_rounded),
                    buildFeatureIcon(context, "Stock Summary", Icons.assignment_turned_in),
                    buildFeatureIcon(context, "Expense", Icons.account_balance_wallet),

                    if (_isExpanded) ...[
                      buildFeatureIcon(context, "Distributor", Icons.fact_check),
                      buildFeatureIcon(context, "Retailer", Icons.storefront),
                      buildFeatureIcon(context, "Order", Icons.phone_android),
                      buildFeatureIcon(context, "Leave", Icons.event_available),
                    ],
                  ],

                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================
  // EVERYTHING BELOW IS UNCHANGED
  // ===========================
  Widget buildFeatureIcon(
      BuildContext context,
      String label,
      IconData icon,
      ) {
    // ✅ Always show icon
    return _buildSchemeIcon(context, label, icon);
  }


  Widget _buildSchemeIcon(BuildContext context, String label, IconData icon) {
    return GestureDetector(
      onTap: () async {
        if (label == "Beat Plan") {
          await _handleSelfOrChildNavigation(
            context: context,
            selfFeature: FeatureAccess.beatPlanSelf, // 501
            childFeature: FeatureAccess.beatPlan,    // 406
            onNavigate: ({String? childId}) {
              return BeatPlanTabsScreen(tsiId: childId);
            },
          );
        }
        if (label == "Leave") {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const LeaveScreen()));
        }
        if (label == "Expense") {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ExpensesDetailScreen()));
        }
        if (label == "Order") {
          // 🔐 ORDER HISTORY VIEW permission (UNCHANGED)
          if (!canView(FeatureAccess.orderHistory)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: AutoTranslateText(
                  "You don't have permission to view orders",
                ),
              ),
            );
            return;
          }

          // ✅ NEW FLOW: Parent–Child (NO roleId, NO TSI)
          await _handleSelfOrChildNavigation(
            context: context,
            selfFeature: FeatureAccess.orderHistory,  // SAME permission
            childFeature: FeatureAccess.orderHistory, // SAME permission
            onNavigate: ({String? childId}) {
              return MyScreen(tsiId: childId);
            },
          );
        }
        if (label == "Distributor") {
          // 🔐 PERMISSION (UNCHANGED)
          if (!canView(FeatureAccess.approveDistributer)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: AutoTranslateText(
                  "You don't have permission to view Distributor orders",
                ),
              ),
            );
            return;
          }

          // ✅ NEW FLOW: Parent–Child (NO roleId, NO TSI)
          await _handleSelfOrChildNavigation(
            context: context,
            selfFeature: FeatureAccess.approveDistributer,
            childFeature: FeatureAccess.approveDistributer,
            onNavigate: ({String? childId}) {
              return DistributorsScreen(tsiId: childId);
            },
          );
        }
        if (label == "Stock Summary") {
          // 🔐 PERMISSION (UNCHANGED)
          if (!canView(FeatureAccess.viewStockOfCfa)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: AutoTranslateText(
                  "You don't have permission to view Stocks",
                ),
              ),
            );
            return;
          }

          // ✅ NEW FLOW: Parent–Child (NO roleId, NO TSI)
          await _handleSelfOrChildNavigation(
            context: context,
            selfFeature: FeatureAccess.viewStockOfCfa,
            childFeature: FeatureAccess.viewStockOfCfa,
            onNavigate: ({String? childId}) {
              return DistributorRetailerScreen(tsiId: childId);
            },
          );
        }



        if (label == "Retailer") {
          // 🔐 PERMISSION (UNCHANGED)
          if (!canView(FeatureAccess.RetailerOrder)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: AutoTranslateText(
                  "You don't have permission to view Retailer orders",
                ),
              ),
            );
            return;
          }

          // ✅ NEW FLOW: Parent–Child (NO roleId, NO TSI)
          await _handleSelfOrChildNavigation(
            context: context,
            selfFeature: FeatureAccess.RetailerOrder,
            childFeature: FeatureAccess.RetailerOrder,
            onNavigate: ({String? childId}) {
              return RetailersScreen(tsiId: childId);
            },
          );
        }


        if (label == "Meeting") {
          final feature = FeatureAccess.meeting;

          if (!canView(feature)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: AutoTranslateText(
                  "You don't have permission to view this",
                ),
              ),
            );
            return;
          }

          if (!canCreate(feature)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: AutoTranslateText(
                  "You don't have permission to create meeting",
                ),
              ),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMeetingScreen()),
          );
        }

      },
        child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFF9F2FC),
            child: Icon(icon, color: Colors.black87, size: 22),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 32,
            child: Center(
              child: AutoTranslateText(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
