import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/recieve_return_order_model.dart';
import 'package:TrustTags_DMS/data/models/return_claim_order_post_data.dart';
import 'package:TrustTags_DMS/features/returns/distributor/return_order_bill_details.dart';
import 'package:TrustTags_DMS/features/returns/provider/approve_return_order_provider.dart';
import 'package:TrustTags_DMS/features/returns/provider/recieve_return_order_list_provider.dart';
import 'package:TrustTags_DMS/features/returns/provider/tsi_approve_return_order_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ReceiveReturnOrderScreen extends StatefulWidget {
  const ReceiveReturnOrderScreen({Key? key}) : super(key: key);

  @override
  State<ReceiveReturnOrderScreen> createState() =>
      _ReceiveReturnOrderScreenState();
}

class _ReceiveReturnOrderScreenState extends State<ReceiveReturnOrderScreen> {
  List<AcceptOrderData> filteredOrders = [];
  String _lastQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecieveReturnOrderListProvider>(context, listen: false)
          .receiveReturnClaim();
    });
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";
    try {
      final parsed = DateTime.parse(dateStr);
      return DateFormat('dd-MM-yyyy').format(parsed);
    } catch (_) {
      return dateStr.split('T').first;
    }
  }

  void _searchOrders(String query, List<AcceptOrderData> orders) {
    _lastQuery = query;
    setState(() {
      if (query.trim().isEmpty) {
        filteredOrders = List.from(orders);
      } else {
        filteredOrders = orders
            .where((o) =>
            (o.orderNo ?? '').toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _confirmStatusChange(
      BuildContext rootContext, AcceptOrderData order, String newStatus) {
    showDialog(
      context: rootContext,
      builder: (dialogContext) => AlertDialog(
        title: const AutoTranslateText("Confirm Status Change"),
        content: AutoTranslateText(
          "Are you sure you want to ${newStatus == 'accepted' ? 'Accept' : 'Reject'} this return order?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const AutoTranslateText("No"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              final provider = Provider.of<ReturnClaimOrderProvider>(
                  rootContext,
                  listen: false);
              final requestId = await SharedPrefsHelper.getUserId();

              // Create request payload
              final request = ReturnClaimOrderPostData(
                status: newStatus,
                orderId: order.id,
                requestId: requestId ?? "",
              );

              await provider.updateReturnClaimOrderStatus(request);

              if (provider.response != null &&
                  provider.response!.success == 1) {
                // Refresh the list from API
                await Provider.of<RecieveReturnOrderListProvider>(
                    rootContext,
                    listen: false)
                    .receiveReturnClaim();

                if (!mounted) return;
                setState(() {
                  filteredOrders = [];
                  _lastQuery = "";
                });

                ScaffoldMessenger.of(rootContext).showSnackBar(
                  SnackBar(
                    content: AutoTranslateText(
                        "Order ${order.orderNo ?? order.id} ${newStatus.toUpperCase()}"),
                    backgroundColor: newStatus == "accepted"
                        ? Colors.green
                        : Colors.red,
                  ),
                );
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(rootContext).showSnackBar(
                  SnackBar(
                    content:
                    AutoTranslateText(provider.error ?? "Something went wrong!"),
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

  Widget _buildOrderCard(BuildContext context, AcceptOrderData order) {
    final approveProvider = Provider.of<TsiReturnApproveOrderProvider>(context);

    final status = (order.status).toLowerCase();
    final shouldShowButtons = !(status == "accepted" || status == "rejected");

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReturnOrderDetailsScreen(
              roleId: order.roleId.toString(),
              orderId: order.id,
              requestId: order.fromLocation,
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
              // Order ID + Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: AutoTranslateText(
                      order.orderNo ?? 'N/A',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AutoTranslateText("Date : ${formatDate(order.orderDate)}"),
                ],
              ),
              const SizedBox(height: 8),

              // Value + Status
              Row(
                children: [
                  AutoTranslateText(
                    "Value : ₹${order.price}",
                    style: const TextStyle(color: Colors.purple, fontSize: 16),
                  ),
                  const Spacer(),
                  AutoTranslateText(
                    "Status: ${order.status}",
                    style: TextStyle(
                      color: order.status.toLowerCase() == "accepted"
                          ? Colors.green
                          : order.status.toLowerCase() == "rejected"
                          ? Colors.red
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Accept/Reject Buttons
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
                          side:
                          const BorderSide(color: Colors.purple),
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
                          side:
                          const BorderSide(color: Colors.purple),
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
    return Scaffold(
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
                      'Recieved Returns',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          Expanded(
            child: Consumer<RecieveReturnOrderListProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.errorMessage != null) {
                  return Center(child: AutoTranslateText(provider.errorMessage!));
                }

                final allOrders = provider.response?.data ?? [];
                final orders =
                (_lastQuery.isEmpty) ? allOrders : filteredOrders;

                if (orders.isEmpty) {
                  return const Center(child: AutoTranslateText("No return orders found"));
                }

                return Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                      child: TextField(
                        onChanged: (query) => _searchOrders(query, allOrders),
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

                    // List of Orders
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
            ),
          ),
        ],
      ),
    );
  }
}
