import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/features/authentication/provider/rout_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Route_user_listing.dart';
import 'package:TrustTags_DMS/features/salesDashboard/tsi_rout_selection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../common/widgets/app_status_bar.dart';

class BeatPlanScreen extends StatefulWidget {
  final String? tsiId;
  final bool canCreate;
  const BeatPlanScreen({super.key,this.tsiId,required this.canCreate});

  @override
  State<BeatPlanScreen> createState() => _BeatPlanScreenState();
}

class _BeatPlanScreenState extends State<BeatPlanScreen> {
  @override
  void initState() {
    super.initState();
    _reloadData();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<RoutProvider>(context, listen: false);
      final token = await SharedPrefsHelper.getAccessToken();
      final userId = await _getEffectiveUserId(); // ✅ FIX

      if (token != null && userId != null) {
        provider.loadRoutes(token, userId);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: AutoTranslateText(
                "Session expired. Please login again.",
              ),
            ),
          );
          Navigator.pop(context);
        }
      }
    });




  }
  Future<String?> _getEffectiveUserId() async {
    final roleId = await SharedPrefsHelper.getRoleId();

    // ✅ RSM → use selected TSI
    if (roleId == 19 && widget.tsiId != null) {
      return widget.tsiId;
    }

    // ✅ Normal flow
    return await SharedPrefsHelper.getUserId();
  }


  Future<void> _reloadData() async {
    final provider = Provider.of<RoutProvider>(context, listen: false);
    final token = await SharedPrefsHelper.getAccessToken();
    final userId = await _getEffectiveUserId(); // ✅ FIX

    if (token != null && userId != null) {
      provider.loadRoutes(token, userId);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: AutoTranslateText(
              "Session expired. Please login again.",
            ),
          ),
        );
        Navigator.pop(context);
      }
    }
  }


  String formatDate(String rawDate) {
    try {
      final dt = DateTime.parse(rawDate);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (e) {
      return rawDate; // fallback if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: widget.canCreate
          ? SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 25.0),
          child: FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>  RouteSelectionScreen(
                    tsiId: widget.tsiId,
                  ),
                ),
              );

              if (result == true) {
                _reloadData();
              }
            },
            backgroundColor: Colors.purple,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      )
          : null,

      body: Column(
        children: [
          Expanded(
            child: Consumer<RoutProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) return const Center(child: CircularProgressIndicator());
                if (provider.error.isNotEmpty) return Center(child: AutoTranslateText('Error: ${provider.error}'));
                if (provider.routes.isEmpty) return const Center(child: AutoTranslateText('No routes found'));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.routes.length,
                  itemBuilder: (context, index) {
                    final beat = provider.routes[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          // Save route info
                          await SharedPrefsHelper.saveSelectedRoute(beat.routeId, beat.routeName);
                          await SharedPrefsHelper.saveDailyRouteId(beat.id);

                          // Navigate to RouteDetailsScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RouteDetailsScreen(
                                tsiRouteVisitId: beat.id,
                                routeName: beat.routeName,
                                status: beat.status,
                              ),
                            ),
                          ).then((value) {
                            // refresh when coming back
                            _reloadData();
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F2FC),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top: Route Name & Status
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: AutoTranslateText(
                                        beat.routeName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                    AutoTranslateText(
                                      beat.status ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: (beat.status?.toLowerCase() == 'pending') ? Colors.amber : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Retailer & Distributor visits
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Retailer visit: ${beat.totalRetailers}"),
                                    Text("Distributor visit: ${beat.totalDistributors}"),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Bottom row: Date
                                if (beat.date != null)
                                  AutoTranslateText(
                                    formatDate(beat.date!),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
