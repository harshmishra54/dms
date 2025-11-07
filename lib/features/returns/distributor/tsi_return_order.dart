import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/data/models/tsi_return_order_models.dart';
import 'package:TrustTags_DMS/data/models/tsi_approve_return_models.dart';
import 'package:TrustTags_DMS/features/returns/distributor/return_order_bill_details.dart';
import 'package:TrustTags_DMS/features/returns/provider/tsi_approve_return_order_provider.dart';
import 'package:TrustTags_DMS/features/returns/provider/tsi_return_order_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TsiReturnCreated extends StatefulWidget {
  const TsiReturnCreated({Key? key}) : super(key: key);

  @override
  State<TsiReturnCreated> createState() => _TsiReturnCreatedState();
}

class _TsiReturnCreatedState extends State<TsiReturnCreated> {
  List<TsiReturnOrderItem> filteredOrders = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TsiReturnOrderProvider>(context, listen: false)
          .fetchTsiReturnOrders();
    });
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";
    try {
      DateTime parsedDate = DateTime.parse(dateStr);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return dateStr.split('T').first;
    }
  }

  void _searchOrders(String query, List<TsiReturnOrderItem> orders) {
    setState(() {
      if (query.isEmpty) {
        filteredOrders = List.from(orders);
      } else {
        filteredOrders = orders
            .where((order) =>
            order.orderNo.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _confirmStatusChange(
      BuildContext context,
      TsiReturnOrderItem order,
      String newStatus,
      ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const AutoTranslateText("Confirm Status Change"),
        content: AutoTranslateText(
          "Are you sure you want to ${newStatus.toLowerCase() == 'accepted' ? 'Accept' : 'Reject'} this return order?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const AutoTranslateText("No"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              final approveProvider =
              Provider.of<TsiReturnApproveOrderProvider>(context,
                  listen: false);
              final ordersProvider =
              Provider.of<TsiReturnOrderProvider>(context, listen: false);

              final decision = newStatus.toLowerCase() == "accepted" ? 1 : 0;

              final request = TsiApproveReturnClaimRequest(
                id: order.id ?? "",
                requestId: order.fromLocation ?? "",
                roleId: order.roleId?.toString() ?? "",
                decision: decision,
              );

              await approveProvider.approveReturnOrder(request);

              if (!mounted) return;

              if (approveProvider.response != null &&
                  approveProvider.response!.success == 1) {
                // ✅ Instead of mutating model, re-fetch orders
                await ordersProvider.fetchTsiReturnOrders();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: AutoTranslateText(
                        "Order ${order.orderNo} ${newStatus.toUpperCase()}"),
                    backgroundColor: newStatus.toLowerCase() == "accepted"
                        ? Colors.green
                        : Colors.red,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: AutoTranslateText(approveProvider.errorMessage ??
                        "Something went wrong!"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const AutoTranslateText("Yes"),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
      BuildContext context,
      TsiReturnOrderItem order,
      ) {
    bool shouldShowButtons = order.isApprove?.toLowerCase() == "pending";

    final approveProvider = Provider.of<TsiReturnApproveOrderProvider>(context);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReturnOrderDetailsScreen(
              roleId: order.roleId?.toString() ?? "",
              orderId: order.id ?? "",
              requestId: order.fromLocation ?? "",
            ),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order ID + Date Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: AutoTranslateText(
                      order.orderNo,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AutoTranslateText(
                    "Date : ${formatDate(order.orderDate)}",
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Value + Status
              Row(
                children: [
                  AutoTranslateText(
                    "Value : ₹${order.price}",
                    style:
                    const TextStyle(color: Colors.purple, fontSize: 16),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const AutoTranslateText(
                        "Status: ",
                        style: TextStyle(
                          color: Colors.black, // always black for label
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AutoTranslateText(
                        order.status ?? "Pending",
                        style: TextStyle(
                          color: (order.status?.toLowerCase() == "accepted")
                              ? Colors.green
                              : (order.status?.toLowerCase() == "rejected")
                              ? Colors.red
                              : Colors.orange, // Pending → Orange
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )

                ],
              ),
              const SizedBox(height: 12),

              // Accept/Reject Buttons (only if Pending)
              if (shouldShowButtons)
                approveProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.purple,
                          side: const BorderSide(color: Colors.purple),
                        ),
                        onPressed: () => _confirmStatusChange(
                            context, order, "Accepted"),
                        child: const AutoTranslateText("ACCEPT"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.purple,
                          side: const BorderSide(color: Colors.purple),
                        ),
                        onPressed: () => _confirmStatusChange(
                            context, order, "Rejected"),
                        child: const AutoTranslateText("REJECT"),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TsiReturnOrderProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.errorMessage != null) {
          return Center(child: AutoTranslateText(provider.errorMessage!));
        }
        final orders =
        filteredOrders.isEmpty ? provider.orders : filteredOrders;

        if (orders.isEmpty) {
          return const Center(child: AutoTranslateText("No return orders found"));
        }

        return Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: TextField(
                onChanged: (query) => _searchOrders(query, provider.orders),
                decoration: InputDecoration(
                  hintText: "Search by Return Order ID",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),

            // Order List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return _buildOrderCard(context, orders[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
