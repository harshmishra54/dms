import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/features/orders/presentation/cancel_update_order_screen.dart';
import 'package:TrustTags_DMS/features/orders/presentation/order_bill_details_screen.dart';
import 'package:TrustTags_DMS/features/orders/presentation/reorder_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/common/app_colors.dart';
import 'package:TrustTags_DMS/features/dashboard/widgets/distributor_new_order_screen.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/order_provider.dart';

class DistributorOrderCreated extends StatefulWidget {
  const DistributorOrderCreated({super.key});

  @override
  State<DistributorOrderCreated> createState() => _DistributorOrderCreatedState();
}

class _DistributorOrderCreatedState extends State<DistributorOrderCreated> with RouteAware {
  String searchQuery = "";
  bool _isFirstLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      _refreshOrders();
      _isFirstLoad = false;
    }
  }

  void _refreshOrders() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });
  }

  String formatDate(String rawDate) {
    try {
      final parsed = DateTime.parse(rawDate);
      return "${parsed.day}-${parsed.month.toString().padLeft(2, '0')}-${parsed.year.toString().padLeft(2, '0')}";
    } catch (e) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: AutoTranslateText(provider.error!));
          }

          if (provider.orders.isEmpty) {
            return const Center(child: AutoTranslateText("No orders found."));
          }

          final filteredOrders = provider.orders.where((order) {
            return order.orderNo.toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();

          // Sort by orderDate (latest first)
          filteredOrders.sort((a, b) {
            final dateA = DateTime.tryParse(a.orderDate) ?? DateTime(1900);
            final dateB = DateTime.tryParse(b.orderDate) ?? DateTime(1900);
            return dateB.compareTo(dateA);
          });

          return Column(
            children: [
              // 🔎 Search bar
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  onChanged: (value) => setState(() => searchQuery = value),
                  decoration: InputDecoration(
                    hintText: "Search by Order ID",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),

              // 📦 Orders list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _refreshOrders();
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: filteredOrders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      double totalAmount = (order.price ?? 0) + (order.gst ?? 0);

                      return Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () async {
                            final requestId = await SharedPrefsHelper.getUserId() ?? '';
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderBillDetailsScreen(
                                  orderId: order.id,
                                  roleId: order.roleId.toString(),
                                  requestId: requestId,
                                ),
                              ),
                            ).then((_) => _refreshOrders());
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 🆔 Order ID + Date
                                Row(
                                  children: [
                                    Expanded(
                                      child: AutoTranslateText(
                                        order.orderNo,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600, fontSize: 15),
                                      ),
                                    ),
                                    AutoTranslateText("Date: ${formatDate(order.orderDate)}",
                                        style: const TextStyle(fontSize: 13)),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // 💰 Total + Delivery
                                Row(
                                  children: [
                                    AutoTranslateText(
                                      "Value: ₹${totalAmount.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.topBarColor,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const Spacer(),
                                    AutoTranslateText(
                                      "Delivery: ${order.deliveryDate.isNotEmpty ? formatDate(order.deliveryDate) : 'Pending'}",
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // 📅 Actions: Edit / Status / Reorder / Return
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Edit button for pending orders
                                    if (order.status.toLowerCase().trim() == "pending")
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                        ),
                                        onPressed: () async {
                                          final requestId = await SharedPrefsHelper.getUserId() ?? '';
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CancelUpdateOrderScreen(
                                                orderId: order.id,
                                                roleId: order.roleId.toString(),
                                                requestId: requestId,
                                              ),
                                            ),
                                          ).then((_) => _refreshOrders());
                                        },
                                        icon: const Icon(Icons.edit, size: 14),
                                        label: const AutoTranslateText("Edit", style: TextStyle(fontSize: 12)),
                                      )
                                    else
                                      Row(
                                        children: [
                                          // Status label
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: order.status.toLowerCase() == "accepted" ||
                                                  order.status.toLowerCase() == "partially accepted"
                                                  ? Colors.green[100]
                                                  : Colors.red[100],
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: AutoTranslateText(
                                              order.status,
                                              style: TextStyle(
                                                color: order.status.toLowerCase() == "accepted" ||
                                                    order.status.toLowerCase() == "partially accepted"
                                                    ? Colors.green[800]
                                                    : Colors.red[800],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),

                                          // Reorder button
                                          if (order.status.toLowerCase() == "accepted" ||
                                              order.status.toLowerCase() == "partially accepted")
                                            IconButton(
                                              icon: const Icon(Icons.replay, color: AppColors.topBarColor),
                                              tooltip: "Reorder",
                                              onPressed: () async {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ReorderScreen(
                                                      orderId: order.id,
                                                      roleId: order.roleId.toString(),
                                                      requestId: order.fromLocation ?? '',
                                                    ),
                                                  ),
                                                ).then((_) => _refreshOrders());
                                              },
                                            ),

                                          // Return button (new)
                                          if (order.status.toLowerCase() == "accepted" ||
                                              order.status.toLowerCase() == "partially accepted")
                                            TextButton.icon(
                                              label: const AutoTranslateText("Return", style: TextStyle(color: Colors.red)),
                                              onPressed: () async {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ReorderScreen(
                                                      orderId: order.id,
                                                      roleId: order.roleId.toString(),
                                                      requestId: order.fromLocation ?? '',
                                                    ),
                                                  ),
                                                ).then((_) => _refreshOrders());
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
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.topBarColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PlaceNewOrderScreen()),
          ).then((_) => _refreshOrders());
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
