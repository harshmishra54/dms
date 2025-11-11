import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/reject_tsi_order_provider.dart';
import 'package:TrustTags_DMS/features/orders/presentation/order_bill_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/tsi_order_provider.dart';
import 'package:TrustTags_DMS/data/models/tsi_order_models.dart';
import 'package:TrustTags_DMS/common/app_colors.dart';
// <-- add this

class OrdersScreen extends StatefulWidget {

  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<OrderTsi> filteredOrders = [];
  Set<String> _loadingOrders = {}; // track orders being processed

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  Future<void> _loadOrders() async {
    final provider = Provider.of<TsiOrderProvider>(context, listen: false);
    await provider.fetchOrders();

    if (!mounted) return;
    setState(() {
      filteredOrders = List.from(provider.orders);

      // sort by date (latest first)
      filteredOrders.sort((a, b) {
        final dateA = DateTime.tryParse(a.orderDate ?? '') ?? DateTime(1900);
        final dateB = DateTime.tryParse(b.orderDate ?? '') ?? DateTime(1900);
        return dateB.compareTo(dateA);
      });
    });
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";
    try {
      DateTime parsedDate = DateTime.parse(dateStr);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return dateStr.split('T').first; // fallback
    }
  }

  void _searchOrders(String query) {
    final provider = Provider.of<TsiOrderProvider>(context, listen: false);
    setState(() {
      if (query.isEmpty) {
        filteredOrders = List.from(provider.orders);
      } else {
        filteredOrders = provider.orders
            .where((order) =>
            order.orderNo.toLowerCase().contains(query.toLowerCase().trim()))
            .toList();
      }

      // sort search results by date
      filteredOrders.sort((a, b) {
        final dateA = DateTime.tryParse(a.orderDate ?? '') ?? DateTime(1900);
        final dateB = DateTime.tryParse(b.orderDate ?? '') ?? DateTime(1900);
        return dateB.compareTo(dateA);
      });
    });
  }

  void _showCancelDialog(OrderTsi order) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const AutoTranslateText("Raise Dispute"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AutoTranslateText("Please enter a reason for cancelling this order:"),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Enter reason",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const AutoTranslateText("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: AutoTranslateText("Reason cannot be empty")),
                );
                return;
              }

              Navigator.pop(dialogContext);

              setState(() {
                _loadingOrders.add(order.id ?? "");
              });

              // 🔥 Call Reject API
              final provider = Provider.of<RejectTsiOrderProvider>(context, listen: false);

              final requestId = await SharedPrefsHelper.getUserId(); // request_id
              final roleId = await SharedPrefsHelper.getRoleId(); // role_id

              final success = await provider.rejectOrder({
                "id": order.id ?? "",
                "role_id": roleId ?? "",
                "request_id": requestId ?? "",
                "rejection_reason": reason,
              });

              if (!mounted) return;

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: AutoTranslateText("Order cancelled successfully")),
                );
                await _loadOrders();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: AutoTranslateText(provider.errorMessage ?? "Failed to cancel order")),
                );
              }

              setState(() {
                _loadingOrders.remove(order.id ?? "");
              });
            },
            child: const AutoTranslateText("Submit"),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderTsi order) {
    bool shouldShowCancelButton = (order.status?.toLowerCase() ?? '') == 'pending';
    bool isLoading = _loadingOrders.contains(order.id);

    double price = double.tryParse(order.price ?? "0") ?? 0;
    double gst = double.tryParse(order.gst ?? "0") ?? 0;
    double total = price + gst;

    return InkWell(
      onTap: isLoading
          ? null
          : () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderBillDetailsScreen(
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
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        elevation: 3,
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
                    child: Text(
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

              // Value + Delivery Row
              Row(
                children: [
                  AutoTranslateText(
                    "Value : ₹${total.toStringAsFixed(2)}",
                    style: const TextStyle(
                        color: AppColors.topBarColor,
                        fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  AutoTranslateText(
                    "Delivery : ${formatDate(order.deliveryDate)}",
                    style: TextStyle(
                      color: (order.deliveryDate != null &&
                          order.deliveryDate!.isNotEmpty)
                          ? Colors.orange
                          : Colors.green,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Cancel Button OR Loader
              // Cancel Button OR Loader
              if (shouldShowCancelButton)
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.1),
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      onPressed: () => _showCancelDialog(order),
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const AutoTranslateText(
                        "Dispute",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
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
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TsiOrderProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          return Center(child: AutoTranslateText(provider.errorMessage!));
        }

        return Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                onChanged: _searchOrders,
                decoration: InputDecoration(
                  hintText: "Search by Order ID",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),

            // Order List
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: ListView.builder(
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    return _buildOrderCard(filteredOrders[index]);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
