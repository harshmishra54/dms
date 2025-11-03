import 'package:TrustTags_DMS/common/app_colors.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/order_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/tsi_approve_order_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/orderupdate/edit_order_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'order_bill_details_screen.dart';

class ReceivedOrderListScreen extends StatefulWidget {
  final String distributorId;
  final int roleId;

  const ReceivedOrderListScreen({
    super.key,
    required this.distributorId,
    required this.roleId,
  });

  @override
  State<ReceivedOrderListScreen> createState() =>
      _ReceivedOrderListScreenState();
}

class _ReceivedOrderListScreenState extends State<ReceivedOrderListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _refreshOrders());
  }

  String formatDate(String isoDateString) {
    try {
      final dateTime = DateTime.parse(isoDateString);
      return DateFormat('dd-MM-yyyy').format(dateTime);
    } catch (e) {
      return isoDateString;
    }
  }

  Future<void> _approveOrder(BuildContext context, String orderId, String requestId) async {
    final tsiProvider = context.read<TsiApproveOrderProvider>();

    showDialog(
      context: context,
      builder: (ctx) {
        final scaffoldMessenger = ScaffoldMessenger.of(ctx);
        return AlertDialog(
          title: const Text("Confirm Approval"),
          content: const Text("Are you sure you want to approve this order?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await tsiProvider.tsiApprovePlaceOrderList(
                  requestId: requestId,
                  orderId: orderId,
                  decision: 1,
                );

                if (!mounted) return;

                if (tsiProvider.errorMessage != null) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text(tsiProvider.errorMessage!)),
                  );
                } else {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text("Order approved successfully")),
                  );
                  await _refreshOrders();
                }
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _rejectOrder(BuildContext context, String orderId, String requestId) async {
    final tsiProvider = context.read<TsiApproveOrderProvider>();
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final scaffoldMessenger = ScaffoldMessenger.of(ctx);
        return AlertDialog(
          title: const Text("Reject Order"),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              labelText: "Reason (optional)",
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await tsiProvider.tsiApprovePlaceOrderList(
                  requestId: requestId,
                  orderId: orderId,
                  decision: 0,
                  reason: reasonController.text.trim().isNotEmpty
                      ? reasonController.text.trim()
                      : null,
                );

                if (!mounted) return;

                if (tsiProvider.errorMessage != null) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text(tsiProvider.errorMessage!)),
                  );
                } else {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text("Order rejected successfully")),
                  );
                  await _refreshOrders();
                }
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _refreshOrders() async {
    final provider = Provider.of<OrderProvider>(context, listen: false);

    await provider.fetchOrdersForDistributor(widget.distributorId, widget.roleId);

    // Sort by latest date first
    provider.orders.sort((a, b) {
      final dateA = DateTime.tryParse(a.orderDate) ?? DateTime(1900);
      final dateB = DateTime.tryParse(b.orderDate) ?? DateTime(1900);
      return dateB.compareTo(dateA);
    });

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final tsiProvider = Provider.of<TsiApproveOrderProvider>(context);

    // Filter out rejected orders
    final visibleOrders = orderProvider.orders
        .where((order) => order.isApprove?.toLowerCase() != "rejected")
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3F3),
      body: Column(
        children: [
          const AppStatusBar(),

          // AppBar
          Container(
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
                  child: Text(
                    'Received Order List',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search Order by OrderId',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // Order List
          Expanded(
            child: orderProvider.isLoading || tsiProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : orderProvider.error != null
                ? Center(child: Text(orderProvider.error!))
                : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: visibleOrders.length,
              itemBuilder: (context, index) {
                final order = visibleOrders[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderBillDetailsScreen(
                          orderId: order.id,
                          roleId: order.roleId.toString(),
                          requestId: order.fromLocation,
                        ),
                      ),
                    );
                  },
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Order Info
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  order.orderNo,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Text(
                                "Date : ${formatDate(order.orderDate)}",
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Value : ₹${(order.price + order.gst).toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                "Delivery : ${formatDate(order.deliveryDate)}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),


                          // Action buttons
                          Row(
                            children: [
                              // APPROVE button
                              if (order.roleId == 1 && order.isApprove?.toLowerCase() == "pending")
                                SizedBox(
                                  width: 90, // fixed width to prevent wrapping
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.purple,
                                      side: const BorderSide(color: Colors.purple),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                    onPressed: () =>
                                        _approveOrder(context, order.id, order.fromLocation),
                                    child: const Text(
                                      "Approve",
                                      textAlign: TextAlign.center, // ensures text is centered
                                    ),
                                  ),
                                ),
                              if (order.roleId == 1 && order.isApprove?.toLowerCase() == "pending")
                                const SizedBox(width: 8),

                              // REJECT button
                              if (order.roleId == 1 && order.isApprove?.toLowerCase() == "pending")
                                SizedBox(
                                  width: 90, // same width for consistency
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.purple,
                                      side: const BorderSide(color: Colors.purple),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                    onPressed: () =>
                                        _rejectOrder(context, order.id, order.fromLocation),
                                    child: const Text(
                                      "Reject",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              if (order.roleId == 1 && order.isApprove?.toLowerCase() == "pending")
                                const SizedBox(width: 8),

                              // EDIT button
                              if (order.status?.toLowerCase() == "pending")
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
                                            orderId: order.id,
                                            roleId: order.roleId.toString(),
                                            requestId: order.fromLocation,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Edit",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),


                        ],
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
            ),
          ),
        ],
      ),
    );
  }
}
