import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/features/salesDashboard/beat_plan_tabs_screen.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/tsi_list_for_rsm_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:TrustTags_DMS/features/orders/presentation/distributors_screen.dart';
import 'package:TrustTags_DMS/features/orders/presentation/my_screen.dart';
import 'package:TrustTags_DMS/features/orders/presentation/retailers_screen.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Add_meeting.dart';
import 'package:TrustTags_DMS/features/salesDashboard/stock_summary_dist-ret_screen.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Beat_Plan.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Expense/Expense_Management.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Leave/Leave_Management.dart';

import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  bool _isExpanded = false;

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
                    // ✅ FIRST ROW (always visible)
                    _buildSchemeIcon(context, "Beat Plan", Icons.local_shipping),
                    _buildSchemeIcon(context, "Meeting", Icons.meeting_room_rounded),
                    _buildSchemeIcon(context, "Stock Summary", Icons.assignment_turned_in),
                    _buildSchemeIcon(context, "Expense", Icons.account_balance_wallet),

                    // ✅ SECOND ROW (only when expanded)
                    if (_isExpanded) ...[
                      _buildSchemeIcon(context, "Distributor", Icons.fact_check),
                      _buildSchemeIcon(context, "Retailer", Icons.storefront),
                      _buildSchemeIcon(context, "Order", Icons.phone_android),
                      _buildSchemeIcon(context, "Leave", Icons.event_available),
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
  Widget _buildSchemeIcon(BuildContext context, String label, IconData icon) {
    return GestureDetector(
      onTap: () async {
        if (label == "Beat Plan") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const BeatPlanTabsScreen()));
        }
        if (label == "Leave") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaveScreen()));
        }
        if (label == "Expense") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpensesDetailScreen()));
        }
        if (label == "Order") {
          final roleId = await SharedPrefsHelper.getRoleId();
          final userId = await SharedPrefsHelper.getUserId();

          if (roleId == 19 && userId != null) {
            final provider = Provider.of<TsiListProvider>(context, listen: false);
            await provider.fetchTsiList(userId);

            if (provider.tsiUsers.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: AutoTranslateText("No TSI found")),
              );
              return;
            }

            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) {
                return Consumer<TsiListProvider>(
                  builder: (ctx, provider, _) {
                    if (provider.isLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: provider.tsiUsers.length,
                      itemBuilder: (ctx, index) {
                        final tsi = provider.tsiUsers[index];
                        return ListTile(
                          title: AutoTranslateText(tsi.name ?? "Unknown"),
                          subtitle: AutoTranslateText(tsi.mobileNo ?? ""),
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MyScreen(tsiId: tsi.id),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MyScreen()));
          }
        }

        if (label == "Distributor") {
          final roleId = await SharedPrefsHelper.getRoleId();
          final userId = await SharedPrefsHelper.getUserId();

          if (roleId == 19 && userId != null) {
            final provider = Provider.of<TsiListProvider>(context, listen: false);
            await provider.fetchTsiList(userId);

            if (provider.tsiUsers.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: AutoTranslateText("No TSI found")),
              );
              return;
            }

            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) {
                return Consumer<TsiListProvider>(
                  builder: (ctx, provider, _) {
                    if (provider.isLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: provider.tsiUsers.length,
                      itemBuilder: (ctx, index) {
                        final tsi = provider.tsiUsers[index];
                        return ListTile(
                          title: AutoTranslateText(tsi.name ?? "Unknown"),
                          subtitle: AutoTranslateText(tsi.mobileNo ?? ""),
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DistributorsScreen(tsiId: tsi.id),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const DistributorsScreen()));
          }
        }

        if (label == "Stock Summary") {
          final roleId = await SharedPrefsHelper.getRoleId();
          final userId = await SharedPrefsHelper.getUserId();

          if (roleId == 19 && userId != null) {
            final provider = Provider.of<TsiListProvider>(context, listen: false);
            await provider.fetchTsiList(userId);

            if (provider.tsiUsers.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: AutoTranslateText("No TSI found")),
              );
              return;
            }

            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) {
                return Consumer<TsiListProvider>(
                  builder: (ctx, provider, _) {
                    if (provider.isLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: provider.tsiUsers.length,
                      itemBuilder: (ctx, index) {
                        final tsi = provider.tsiUsers[index];
                        return ListTile(
                          title: AutoTranslateText(tsi.name ?? "Unknown"),
                          subtitle: AutoTranslateText(tsi.mobileNo ?? ""),
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DistributorRetailerScreen(tsiId: tsi.id),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const DistributorRetailerScreen()));
          }
        }

        if (label == "Retailer") {
          final roleId = await SharedPrefsHelper.getRoleId();
          final userId = await SharedPrefsHelper.getUserId();

          if (roleId == 19 && userId != null) {
            final provider = Provider.of<TsiListProvider>(context, listen: false);
            await provider.fetchTsiList(userId);

            if (provider.tsiUsers.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: AutoTranslateText("No TSI found")),
              );
              return;
            }

            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) {
                return Consumer<TsiListProvider>(
                  builder: (ctx, provider, _) {
                    if (provider.isLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: provider.tsiUsers.length,
                      itemBuilder: (ctx, index) {
                        final tsi = provider.tsiUsers[index];
                        return ListTile(
                          title: AutoTranslateText(tsi.name ?? "Unknown"),
                          subtitle: AutoTranslateText(tsi.mobileNo ?? ""),
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RetailersScreen(tsiId: tsi.id),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const RetailersScreen()));
          }
        }

        if (label == "Meeting") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMeetingScreen()));
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
