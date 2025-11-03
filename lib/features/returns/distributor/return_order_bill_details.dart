import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/features/returns/provider/return_order_details_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ReturnOrderDetailsScreen extends StatefulWidget {
  final String orderId;
  final String roleId;
  final String requestId;

  const ReturnOrderDetailsScreen({
    super.key,
    required this.orderId,
    required this.roleId,
    required this.requestId,
  });

  @override
  State<ReturnOrderDetailsScreen> createState() =>
      _ReturnOrderDetailsScreenState();
}

class _ReturnOrderDetailsScreenState extends State<ReturnOrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ReturnOrderDetailsProvider>(context, listen: false)
          .fetchReturnOrderDetails(
        orderId: widget.orderId,
        roleId: widget.roleId,
        requestId: widget.requestId,
      );
    });
  }

  String _formatDate(String dateString) {
    try {
      final parsedDate = DateTime.parse(dateString);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return dateString.split(" ").first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Column(
        children: [
          const AppStatusBar(),

          // Top Bar
          Material(
            elevation: 2,
            color: Colors.white,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              width: double.infinity,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Return Order Details",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: Consumer<ReturnOrderDetailsProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.error != null) {
                  return Center(child: Text(provider.error!));
                }
                final details = provider.orderDetails;
                if (details == null || details.data == null) {
                  return const Center(child: Text("No details found"));
                }

                final orderData = details.data!;
                final items = details.detail ?? [];

                final totalAmount = items.fold<double>(
                  0.0,
                      (sum, item) =>
                  sum +
                      ((double.tryParse(item.price) ?? 0) *
                          (double.tryParse(item.qty) ?? 0)),
                );

                return ListView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10), // no top gap
                  children: [
                    // Order Header
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order No: ${orderData.orderNo}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Date: ${_formatDate(orderData.orderDate)}",
                                style: const TextStyle(fontSize: 13),
                              ),
                              Text(
                                orderData.status,
                                style: TextStyle(
                                  color: orderData.status.toLowerCase() ==
                                      "pending"
                                      ? Colors.orange
                                      : orderData.status.toLowerCase() ==
                                      "accepted"
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Items List
                    ...items.map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Qty: ${item.qty}"),
                                Text("Price: ₹${item.price}"),
                                Text(
                                  "Total: ₹${(double.tryParse(item.price) ?? 0) * (double.tryParse(item.qty) ?? 0)}",
                                  style: const TextStyle(
                                    color: Colors.purple,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Reason: ${item.reason}",
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    }),

                    // Footer Total
                    Container(
                      padding: const EdgeInsets.all(14),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          )
                        ],
                      ),
                      child: Text(
                        "Total: ₹$totalAmount",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
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
}
