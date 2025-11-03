
import 'package:TrustTags_DMS/data/models/order_update_model.dart';
import 'package:TrustTags_DMS/features/orders/presentation/order_bill_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/order_list_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/order_update_provider.dart';
import 'package:TrustTags_DMS/common/app_colors.dart';

class RecievedOrderList extends StatefulWidget {
  const RecievedOrderList({super.key});

  @override
  State<RecievedOrderList> createState() => _RecievedOrderListState();
}

class _RecievedOrderListState extends State<RecievedOrderList> {
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<OrderListProvider>().fetchOrderList();
    });
  }

  String formatDate(String rawDate) {
    try {
      final parsedDate = DateTime.parse(rawDate);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return rawDate;
    }
  }

  Future<bool> _showConfirmDialog(String status) async {
    // map status to display text
    final displayText = status == "Accepted"
        ? "Accept"
        : status == "Rejected"
        ? "Reject"
        : status;

    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Confirm Order"),
        content: Text("Are you sure you want to $displayText this order?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    ) ?? false;
  }


  Future<String?> _pickDeliveryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    return date != null ? DateFormat('yyyy-MM-dd').format(date) : null;
  }

  Future<void> _handleUpdateStatus({
    required String status,
    required dynamic order,
  }) async {
    final confirmed = await _showConfirmDialog(status);
    if (!confirmed) return;

    String deliveryDate = "";
    if (status == "Accepted") {
      final selected = await _pickDeliveryDate();
      if (selected == null) return;
      deliveryDate = selected;
    }

    // old flow for normal status update
    final req = OrderUpdateRequest(
      status: status,
      roleId: '1',
      orderId: order.id.toString(),
      requestId: order.toLocation.toString(),
      deliveryDate: deliveryDate,
    );

    await context.read<OrderUpdateProvider>().updateOrderStatus(req);


    final updateProvider = context.read<OrderUpdateProvider>();
    if (updateProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${updateProvider.errorMessage}")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(updateProvider.orderResponse?.message ?? "Success")),
      );
      context.read<OrderListProvider>().fetchOrderList();
    }
  }

  /// ✅ Handle Partial Update
  /// ✅ Handle Partial Update
  Future<void> _handlePartialUpdate(dynamic order) async {
    final confirmed = await _showConfirmDialog("Partial Accept");
    if (!confirmed) return;

    String? deliveryDate = await _pickDeliveryDate();
    if (deliveryDate == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderBillDetailsScreen(
          orderId: order.id.toString(),
          roleId: order.roleId.toString(),
          requestId: order.fromLocation.toString(),
          isPartialFlow: true,             // 👈 flag ON
          deliveryDate: deliveryDate,      // 👈 pass picked date
        ),
      ),
    ).then((result) {
      if (result == true) {
        // refresh list if partial was confirmed
        context.read<OrderListProvider>().fetchOrderList();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const AppStatusBar(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Received Order List",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                ),
              ],
            ),
          ),

          /// ✅ Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search Order by OrderId",
                hintStyle: const TextStyle(color: Colors.black54),
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),

          Expanded(
            child: Consumer<OrderListProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.errorMessage != null) {
                  return Center(
                      child: Text(provider.errorMessage!,
                          style: const TextStyle(color: Colors.red)));
                }

                final response = provider.orderListResponse;
                if (response == null || response.data.isEmpty) {
                  return const Center(
                      child: Text("No orders found",
                          style: TextStyle(color: Colors.grey)));
                }

                final filteredOrders = response.data.where((order) {
                  return order.orderNo
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()) ||
                      order.orderDate
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()) ||
                      order.status
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase());
                }).toList();
                filteredOrders.sort((a, b) {
                  final dateA = DateTime.tryParse(a.orderDate) ?? DateTime(2000);
                  final dateB = DateTime.tryParse(b.orderDate) ?? DateTime(2000);
                  return dateB.compareTo(dateA); // descending
                });

                if (filteredOrders.isEmpty) {
                  return const Center(
                      child: Text("No matching orders",
                          style: TextStyle(color: Colors.grey)));
                }

                return MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderBillDetailsScreen(
                                roleId: order.roleId.toString(),
                                orderId: order.id,
                                requestId: order.fromLocation,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(order.orderNo,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    Text(
                                      "Date : ${formatDate(order.orderDate)}",
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        "Value : ₹${((double.tryParse(order.discountPrice.toString()) ?? 0) + (double.tryParse(order.gst.toString()) ?? 0)).toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          color: Colors.purple,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),


                                    Flexible(
                                      child: Text(
                                        order.status == "Pending"
                                            ? "Delivery : ${formatDate(order.deliveryDate)}"
                                            : (order.status == "Rejected"
                                            ? "Order Rejected"
                                            : "Order Approved"),
                                        style: TextStyle(
                                          color: order.status == "Pending"
                                              ? Colors.orange
                                              : order.status == "Rejected"
                                              ? Colors.red
                                              : Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.right,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Expected Delivery:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      formatDate(order.expectedDate??""),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:Colors.purple,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                if (order.status == "Pending")
                                  Row(
                                    children: [
                                      Flexible(
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              _handleUpdateStatus(
                                                  status: "Accepted",
                                                  order: order),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor:
                                            Colors.purple,
                                            side: const BorderSide(
                                                color: Colors.purple),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 6),
                                            textStyle: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          child: const FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text("ACCEPT"),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              _handleUpdateStatus(
                                                  status: "Rejected",
                                                  order: order),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor:
                                            Colors.purple,
                                            side: const BorderSide(
                                                color: Colors.purple),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 6),
                                            textStyle: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          child: const FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text("REJECT"),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              _handlePartialUpdate(order),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: Colors.orange,
                                            side: const BorderSide(
                                                color: Colors.orange),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 6),
                                            textStyle: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          child: const FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text("PARTIAL"),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
