import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/permissions/feature_access.dart';
import 'package:TrustTags_DMS/core/permissions/feature_mapper.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/rsm_approve_update_order_model.dart';
import 'package:TrustTags_DMS/features/orders/presentation/order_bill_details_screen.dart';
import 'package:TrustTags_DMS/features/permissions/permissions_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/orderupdate/edit_order_list.dart';
import 'package:TrustTags_DMS/features/orders/provider/tsi_dis_retailer_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/rsm_update_order_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as legacy;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyScreen extends StatefulWidget {
  final String? tsiId;

  const MyScreen({super.key, this.tsiId});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen>
    with SingleTickerProviderStateMixin {
  String? tsmroleId;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRoleId();

    Future.microtask(() {
      final provider =
      legacy.Provider.of<TsiDisRetailerProvider>(context, listen: false);
      provider.fetchTsiDisRetailerOrders(tsiId: widget.tsiId);
    });
  }

  Future<void> _loadRoleId() async {
    final roleId = await SharedPrefsHelper.getRoleId();
    setState(() {
      tsmroleId = roleId?.toString();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FF),
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
                  const Expanded(
                    child: AutoTranslateText(
                      'My Orders',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // ---------- Tab Bar ----------
          Material(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.deepPurple,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Colors.deepPurple,
              tabs: const [
                Tab(text: "Retailer Orders"),
                Tab(text: "Distributor Orders"),
              ],
            ),
          ),

          // ---------- Tab Views ----------
          Expanded(
            child: legacy.Consumer<TsiDisRetailerProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null) {
                  return Center(child: AutoTranslateText(provider.errorMessage!));
                }

                final data = provider.responseData;
                if (data == null) {
                  return const Center(child: AutoTranslateText("No data available"));
                }

                final distributorOrders =
                List<Map<String, dynamic>>.from(data["distributorOrders"] ?? []);
                final retailerOrders =
                List<Map<String, dynamic>>.from(data["retailerOrders"] ?? []);

                // Sort: pending first, then latest date
                int sortFn(Map<String, dynamic> a, Map<String, dynamic> b) {
                  final statusA = (a["status"] ?? "").toString().toLowerCase();
                  final statusB = (b["status"] ?? "").toString().toLowerCase();

                  if (statusA == "pending" && statusB != "pending") return -1;
                  if (statusB == "pending" && statusA != "pending") return 1;

                  final dateA = DateTime.tryParse(a["createdAt"] ?? "") ??
                      DateTime.fromMillisecondsSinceEpoch(0);
                  final dateB = DateTime.tryParse(b["createdAt"] ?? "") ??
                      DateTime.fromMillisecondsSinceEpoch(0);
                  return dateB.compareTo(dateA);
                }

                distributorOrders.sort(sortFn);
                retailerOrders.sort(sortFn);

                return TabBarView(
                  controller: _tabController,
                  children: [
                    // ---------- Retailer Orders Tab ----------
                    retailerOrders.isEmpty
                        ? const Center(child: AutoTranslateText("No Retailer Orders"))
                        : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: retailerOrders.length,
                      itemBuilder: (_, index) =>
                          _buildOrderCard(context, retailerOrders[index]),
                    ),

                    // ---------- Distributor Orders Tab ----------
                    distributorOrders.isEmpty
                        ? const Center(child: AutoTranslateText("No Distributor Orders"))
                        : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: distributorOrders.length,
                      itemBuilder: (_, index) =>
                          _buildOrderCard(context, distributorOrders[index]),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Status Badge ----------
  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case "pending":
        color = Colors.orange;
        break;
      case "rejected":
        color = Colors.red;
        break;
      case "accepted":
      case "approved":
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: AutoTranslateText(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  // ---------- Order Card with Approve/Reject/Edit Buttons ----------
  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> item) {
    final requestId = item["from_location"]?.toString() ?? "";
    final roleId = item["role_id"]?.toString() ?? "1";
    final orderId = item["id"]?.toString() ?? "";
    final int role = int.tryParse(tsmroleId ?? '') ?? 0;


    String createdDate = "";
    if (item["createdAt"] != null) {
      try {
        final dateTime = DateTime.parse(item["createdAt"]);
        createdDate =
        "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}";
      } catch (_) {
        createdDate = item["createdAt"];
      }
    }

    double price = double.tryParse(item["price"]?.toString() ?? "0") ?? 0;
    double gst = double.tryParse(item["gst"]?.toString() ?? "0") ?? 0;
    double totalValue = price + gst;

    final rsmApproval = item["rsm_approval"];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderBillDetailsScreen(
                  requestId: requestId,
                  roleId: roleId,
                  orderId: orderId,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- Header ----------
                Row(
                  children: [
                    Expanded(
                      child: AutoTranslateText(
                        item["from_location_name"] ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // ---------- Order Info ----------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AutoTranslateText(
                      "Order No: ${item["order_no"] ?? ""}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    AutoTranslateText(
                      ": $createdDate",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // ---------- Price Info ----------
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AutoTranslateText(
                        "Value: ${totalValue.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      if (tsmroleId == "18") ...[
                        const AutoTranslateText("Approval:",
                            style: TextStyle(fontWeight: FontWeight.w500)),

                        _buildStatusBadge(
                          rsmApproval == null
                              ? "Pending"
                              : (rsmApproval == true ? "Approved" : "Rejected"),
                        ),
                      ],

                      if (tsmroleId == "19") ...[
                        const AutoTranslateText("Status:",
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        _buildStatusBadge(item["status"]?.toString() ?? "Pending"),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 12),


                // ---------- Approve / Reject / Edit Buttons (only for roleId 19) ----------

                  if (rsmApproval == null && role >= 19)
                    Consumer(
                      builder: (context, ref, _) {
                        final permissionState = ref.watch(permissionsProvider);

                        final canApprove =
                            permissionState.data != null &&
                                permissionState.data!.data.any(
                                      (f) =>
                                  FeatureMapper.fromId(f.featureId) ==
                                      FeatureAccess.orderHistory &&
                                      f.permissions.approve == true,
                                );

                        // ❌ No approve permission → hide everything
                        if (!canApprove) {
                          return const SizedBox.shrink();
                        }

                        return legacy.Consumer2<RsmUpdateOrderProvider, TsiDisRetailerProvider>(
                          builder: (context, rsmProvider, tsiProvider, _) {
                            if (rsmProvider.isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              );
                            }

                            return Row(
                              children: [
                                // ✅ APPROVE
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.purple,
                                      side: const BorderSide(color: Colors.purple),
                                    ),
                                    onPressed: () async {
                                      final req = RsmApproveUpdateOrderModelRequest(
                                        status: "approved",
                                        roleId: roleId,
                                        orderId: orderId,
                                        requestId: requestId,
                                      );

                                      await rsmProvider.updateOrderByRsm(req);

                                      if (rsmProvider.response != null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: AutoTranslateText(
                                              rsmProvider.response!.message,
                                            ),
                                          ),
                                        );
                                        tsiProvider.fetchTsiDisRetailerOrders(
                                          tsiId: widget.tsiId,
                                        );
                                      } else if (rsmProvider.errorMessage != null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: AutoTranslateText(
                                              rsmProvider.errorMessage!,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: const AutoTranslateText("Approve"),
                                  ),
                                ),

                                const SizedBox(width: 4),

                                // ❌ REJECT
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.purple,
                                      side: const BorderSide(color: Colors.purple),
                                    ),
                                    onPressed: () async {
                                      final req = RsmApproveUpdateOrderModelRequest(
                                        status: "rejected",
                                        roleId: roleId,
                                        orderId: orderId,
                                        requestId: requestId,
                                      );

                                      await rsmProvider.updateOrderByRsm(req);

                                      if (rsmProvider.response != null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: AutoTranslateText(
                                              rsmProvider.response!.message,
                                            ),
                                          ),
                                        );
                                        tsiProvider.fetchTsiDisRetailerOrders(
                                          tsiId: widget.tsiId,
                                        );
                                      } else if (rsmProvider.errorMessage != null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: AutoTranslateText(
                                              rsmProvider.errorMessage!,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: const AutoTranslateText("Reject"),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // ✏️ EDIT (still only when status = pending)
                                if ((item["status"]?.toString().toLowerCase() ?? "") ==
                                    "pending")
                                  SizedBox(
                                    width: 80,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.orange,
                                        side: const BorderSide(color: Colors.orange),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => TSIUpdateOrderScreen(
                                              requestId: requestId,
                                              roleId: roleId,
                                              orderId: orderId,
                                            ),
                                          ),
                                        ).then((_) {
                                          legacy.Provider.of<TsiDisRetailerProvider>(
                                            context,
                                            listen: false,
                                          ).fetchTsiDisRetailerOrders(
                                            tsiId: widget.tsiId,
                                          );
                                        });
                                      },
                                      child: const AutoTranslateText("Edit"),
                                    ),
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
