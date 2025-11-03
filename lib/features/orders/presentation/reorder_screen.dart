import 'package:TrustTags_DMS/common/app_colors.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/complete_return_model.dart';
import 'package:TrustTags_DMS/data/models/order_details_model.dart';
import 'package:TrustTags_DMS/data/models/reorder_model.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/reorder_provider.dart';
import 'package:TrustTags_DMS/features/orders/provider/order_details_provider.dart';
import 'package:TrustTags_DMS/features/returns/provider/complete_return_order_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';

class ReorderScreen extends StatefulWidget {
  final String orderId;
  final String roleId;
  final String requestId;

  const ReorderScreen({
    super.key,
    required this.orderId,
    required this.roleId,
    required this.requestId,
  });

  @override
  State<ReorderScreen> createState() => _ReorderScreenState();
}

class _ReorderScreenState extends State<ReorderScreen> {
  OrderDetailsResponse? orderDetails;
  bool isLoading = true;
  bool _reordering = false;
  bool _returning = false;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case "pending":
        return Colors.orange;
      case "rejected":
      case "auto rejected":
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    final provider = context.read<OrderDetailsProvider>();
    final result = await provider.fetchOrderDetails(
      roleId: widget.roleId,
      id: widget.orderId,
      requestId: widget.requestId,
    );

    setState(() {
      orderDetails = result;
      isLoading = false;
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _handleCompleteReturn() async {
    if (orderDetails == null) return;

    setState(() => _returning = true);

    final userId = await SharedPrefsHelper.getUserId() ?? '';
    final roleId = int.tryParse(widget.roleId) ?? 0;

    final request = CompleteReturnOrderRequest(
      orderId: orderDetails!.data.id,
      roleId: roleId,
      fromLocation: userId,
      createdBy: userId,
      requestedRoleId: roleId,
      reason: "Order Return", // optional: could be user input
    );

    final provider =
    Provider.of<CompleteReturnOrderProvider>(context, listen: false);
    await provider.createCompleteReturnOrder(request);

    if (!mounted) return;

    if (provider.errorMessage != null) {
      _showSnack("Error: ${provider.errorMessage}");
    } else {
      _showSnack(provider.response?.message ?? "Return created successfully");
      Navigator.pop(context, true);
    }

    setState(() => _returning = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FF),
      body: Column(
        children: [
          const AppStatusBar(),
          _buildAppBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : orderDetails == null
                ? const Center(child: Text("Failed to load order details"))
                : _buildOrderContent(orderDetails!),
          ),
        ],
      ),
      bottomNavigationBar: (orderDetails != null &&
          orderDetails!.data.status.toLowerCase() == "accepted")
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _returning ? null : _handleCompleteReturn,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: AppColors.topBarColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _returning
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : const Text(
            "Complete Return",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      )
          : null,
    );
  }

  Widget _buildAppBar() {
    return Container(
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
              'Order Details',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 18, color: Colors.black),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildOrderContent(OrderDetailsResponse data) {
    final discountPrice = double.tryParse(data.data.discountPrice) ?? 0;
    final gst = double.tryParse(data.data.gst) ?? 0;
    final total = discountPrice + gst;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Order Details",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Order ID : ${data.data.orderNo ?? ""}"),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Date : ${data.data.orderDate.split('T')[0]}"),
                    Row(
                      children: [
                        Text(
                          "Order ${data.data.status}",
                          style: TextStyle(
                            color: _getStatusColor(data.data.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        FutureBuilder<int?>(
                          future: SharedPrefsHelper.getRoleId(),
                          builder: (context, snapshot) {
                            final roleId = snapshot.data ?? 0;
                            if ((roleId == 1 || roleId == 3) &&
                                (data.data.status.toLowerCase() == 'accepted' ||
                                    data.data.status.toLowerCase() ==
                                        'partially accepted')) {
                              return _reordering
                                  ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                                  : IconButton(
                                icon: const Icon(Icons.replay,
                                    color: AppColors.topBarColor),
                                tooltip: "Reorder",
                                onPressed: () async {
                                  setState(() => _reordering = true);

                                  final userId =
                                      await SharedPrefsHelper.getUserId() ?? '';
                                  final reorderRequest = ReorderRequest(
                                    orderId: data.data.id,
                                    roleId: roleId,
                                    fromLocation: userId,
                                    createdBy: userId,
                                    requestedRoleId: roleId,
                                  );

                                  final provider =
                                  Provider.of<ReorderProvider>(context, listen: false);
                                  await provider.createReorder(reorderRequest);

                                  if (!mounted) return;

                                  if (provider.status == ReorderStatus.success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Reorder created: ${provider.reorderResponse?.newOrderNo ?? ''}",
                                        ),
                                      ),
                                    );
                                    Navigator.pop(context, true);
                                  } else if (provider.status ==
                                      ReorderStatus.error) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Failed to reorder: ${provider.errorMessage}"),
                                      ),
                                    );
                                    setState(() => _reordering = false);
                                  }
                                },
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Items (read-only)
        ...data.detail.map((item) {
          final price = double.tryParse(item.price) ?? 0;
          final qty = int.tryParse(item.qty) ?? 0;
          final lineTotal = price * qty;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.product.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Qty : $qty"),
                        Text("Price : ₹${price.toStringAsFixed(2)}"),
                        Text(
                          "₹${lineTotal.toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.deepPurple),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 12),

        // Bill Summary
        Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Bill Summary",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Divider(),
                _billRow("Discounted Price :", "₹${discountPrice.toStringAsFixed(2)}"),
                _billRow("GST :", "₹${gst.toStringAsFixed(2)}"),
                _billRow("Scheme Points :", data.data.schemePoints?.toString() ?? ""),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total :",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.deepPurple),
                    ),
                    Text(
                      "₹${total.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.deepPurple),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _billRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label),
        Text(value),
      ]),
    );
  }
}
