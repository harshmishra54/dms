import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/features/authentication/provider/rout_user_list_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Visit_Details_page.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/complete_all_route_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../common/app_colors.dart';
import '../../../common/widgets/app_status_bar.dart';

class RouteDetailsScreen extends StatefulWidget {
  final String tsiRouteVisitId; // route_id to complete
  final String routeName;
  final String? status;

  const RouteDetailsScreen({
    super.key,
    required this.tsiRouteVisitId,
    required this.routeName,
    this.status,

  });

  @override
  State<RouteDetailsScreen> createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends State<RouteDetailsScreen> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch route visit user list when the screen loads
    Future.microtask(() {
      context.read<RouteDetailsProvider>().fetchRouteVisitUserList(
        widget.tsiRouteVisitId,
      );
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _onCompletePressed() async {
    final providerResponse = context.read<RouteDetailsProvider>().data;
    final status = providerResponse?.data?.status?.toLowerCase() ?? '';

    String? reason;
    if (status == "pending") {
      reason = await showDialog<String>(
        context: context,
        builder: (context) {
          bool isLoading = false; // track loading state
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Enter reason for pending'),
                content: TextField(
                  controller: _reasonController,
                  decoration: const InputDecoration(hintText: 'Reason...'),
                ),
                actions: [
                  TextButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null // disable button during API call
                        : () async {
                      if (_reasonController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a reason')),
                        );
                        return;
                      }

                      setState(() {
                        isLoading = true; // start loader
                      });

                      // Call completeRoute API
                      final routeProvider = context.read<RouteProvider>();
                      await routeProvider.completeRoute(widget.tsiRouteVisitId);

                      setState(() {
                        isLoading = false; // stop loader
                      });

                      if (routeProvider.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(routeProvider.errorMessage!)),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Route completed successfully')),
                        );
                        Navigator.pop(context, _reasonController.text.trim()); // close dialog
                        Navigator.pop(context, true); // go back
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(80, 40),
                    ),
                    child: isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text('Submit'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (reason == null || reason.isEmpty) return; // User cancelled
    } else {
      // Non-pending route completion
      final routeProvider = context.read<RouteProvider>();
      await routeProvider.completeRoute(widget.tsiRouteVisitId);

      if (routeProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(routeProvider.errorMessage!)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Route completed successfully')),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RouteDetailsProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Column(
        children: [
          const AppStatusBar(),
          Material(
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.1),
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.routeName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // Main content
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.data == null
                ? const Center(child: Text('No data available'))
                : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Visit Retailers",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...(provider.data!.data?.retailers ?? []).map(
                        (retailer) => _buildCard(
                      icon: Icons.storefront,
                      name: retailer.name,
                      firm: retailer.firmName,
                      contact: retailer.mobileNo,
                      status: retailer.status ?? '',
                          onTap: () async {
                            await SharedPrefsHelper.saveDailyLocationId(retailer.locationId);
                            await SharedPrefsHelper.saveDailyRoleId(retailer.roleId.toString());

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VisitDetailsScreen(
                                  routeStatus: widget.status ?? 'Pending',
                                ),
                              ),
                            ).then((_) {
                              // Re-fetch API on return
                              context.read<RouteDetailsProvider>().fetchRouteVisitUserList(
                                widget.tsiRouteVisitId,
                              );
                            });
                          },

                        ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Visit Distributors",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...(provider.data!.data?.distributors ?? []).map(
                        (dist) => _buildCard(
                      icon: Icons.local_shipping,
                      name: dist.name,
                      firm: dist.firmName,
                      contact: dist.mobileNo,
                      status: dist.status ?? '',
                          onTap: () async {
                            await SharedPrefsHelper.saveDailyLocationId(dist.locationId);
                            await SharedPrefsHelper.saveDailyRoleId(dist.roleId.toString());

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VisitDetailsScreen(
                                  routeStatus: widget.status ?? 'Pending',
                                ),
                              ),
                            ).then((_) {
                              // Re-fetch API on return
                              context.read<RouteDetailsProvider>().fetchRouteVisitUserList(
                                widget.tsiRouteVisitId,
                              );
                            });
                          },

                        ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // Complete button at bottom
          // Complete button at bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: widget.status?.toLowerCase() == 'completed'
                    ? null // disables the button
                    : _onCompletePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.status?.toLowerCase() == 'completed'
                      ? Colors.grey // optional: show disabled color
                      : AppColors.topBarColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.status?.toLowerCase() == 'completed'
                      ? 'Completed'
                      : 'Complete',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String name,
    required String firm,
    required String contact,
    required String status,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFF2E9FA),
          child: Row(
            //0xFFF2E9FA,0xFFFFF3F3
            children: [
              Container(
                width: 72,
                height: 110,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF3F3),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Icon(icon, color: Color(0xFF9C27B0), size: 36),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        firm,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            contact,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black54),
                          ),
                          Text(
                            status,
                            style: TextStyle(
                              color: status == 'Completed'
                                  ? Colors.black
                                  : Colors.amber[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
