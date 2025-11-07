import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/data/models/ipt_order_details_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/ipt_order_details_provider.dart';

class IPTOrderDetailsScreen extends StatefulWidget {
  final String? orderId;

  const IPTOrderDetailsScreen({super.key, this.orderId});

  @override
  State<IPTOrderDetailsScreen> createState() => _IPTOrderDetailsScreenState();
}

class _IPTOrderDetailsScreenState extends State<IPTOrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.orderId != null) {
      // Fetch order details when screen initializes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<IptOrderDetailsProvider>(context, listen: false)
            .fetchOrderDetails(widget.orderId!);
      });
    }
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3F3),
      body: Column(
        children: [
          const AppStatusBar(),
          _buildAppBar(context),
          Expanded(
            child: Consumer<IptOrderDetailsProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null) {
                  return Center(
                    child: AutoTranslateText(
                      provider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final order = provider.orderDetails?.data?.order;
                final lineItems = provider.orderDetails?.data?.lineItems ?? [];

                if (order == null) {
                  return const Center(child: AutoTranslateText("No order details found"));
                }

                double totalItemPrice = 0;
                for (var item in lineItems) {
                  totalItemPrice +=
                      (double.tryParse(item.price ?? "0") ?? 0) *
                          (int.tryParse(item.qty ?? "0") ?? 0);
                }
                final gst = 0.0; // Replace with real gst if available
                final schemePoints = 0; // Replace if available
                final estimatedTotal = totalItemPrice + gst;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _orderInfo(order, _getStatusColor),
                    const SizedBox(height: 16),
                    ...lineItems.map((e) => _itemTile(e)).toList(),
                    const SizedBox(height: 16),
                    _billSummary(
                      totalItemPrice,
                      gst,
                      schemePoints,
                      estimatedTotal,
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

  Widget _buildAppBar(BuildContext context) {
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
            child: AutoTranslateText(
              'IPT Order Details',
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

  Widget _orderInfo(Order order, Color Function(String) getStatusColor) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const AutoTranslateText("Order Details", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          AutoTranslateText("Order ID: ${order.name ?? '-'}"),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AutoTranslateText(
                  "Date: ${order.orderDate != null ? order.orderDate!.toLocal().toString().split(' ')[0] : '-'}"),
              AutoTranslateText(
                "Order ${order.status ?? '-'}",
                style: TextStyle(
                  color: _getStatusColor(order.status ?? ''),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _itemTile(IptOrderLineItem item) {
    final qty = int.tryParse(item.qty ?? "0") ?? 0;
    final price = double.tryParse(item.price ?? "0") ?? 0;
    final lineTotal = qty * price;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AutoTranslateText(item.IptProductName ?? '-', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AutoTranslateText("Qty: $qty"),
                AutoTranslateText("Price: ₹${price.toStringAsFixed(2)}"),
                AutoTranslateText(
                  "₹${lineTotal.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  Widget _billSummary(
      double subtotal, double gst, int schemePoints, double total) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const AutoTranslateText("Bill Summary", style: TextStyle(fontWeight: FontWeight.bold)),
          const Divider(),
          _billRow("Item Price:", "₹${subtotal.toStringAsFixed(2)}"),
          _billRow("GST:", "₹${gst.toStringAsFixed(2)}"),
          _billRow("Scheme Points:", "$schemePoints"),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AutoTranslateText(
                "Total:",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple),
              ),
              AutoTranslateText(
                "₹${total.toStringAsFixed(2)}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _billRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        AutoTranslateText(label),
        AutoTranslateText(value),
      ]),
    );
  }
}
