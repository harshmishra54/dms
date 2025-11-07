import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/data/models/order_details_model.dart';
import 'package:TrustTags_DMS/features/dashboard/widgets/distributor_new_order_screen.dart';
import 'package:TrustTags_DMS/features/orders/provider/order_details_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/shared_prefs_helper.dart';

import 'visit_helpers.dart';

class OrderSection extends StatefulWidget {
  final String? orderId;
  final Function(String)? onOrderPlaced; // 👈 callback to notify parent

  const OrderSection({super.key, this.orderId, this.onOrderPlaced});

  @override
  State<OrderSection> createState() => _OrderSectionState();
}

class _OrderSectionState extends State<OrderSection> {
  Future<OrderDetailsResponse?>? _orderDetailsFuture;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails(widget.orderId);
  }

  Future<void> _loadOrderDetails(String? orderId) async {
    if (orderId == null) return;

    final roleId = await SharedPrefsHelper.getDailyRoleId();
    final requestId = await SharedPrefsHelper.getDailylocationId();

    setState(() {
      _orderDetailsFuture =
          Provider.of<OrderDetailsProvider>(context, listen: false)
              .fetchOrderDetails(
            roleId: roleId.toString(),
            id: orderId,
            requestId: requestId ?? "",
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Button to place a new order
        buildSectionHeader("Order", () async {
          // Navigate to PlaceNewOrderScreen
          final newOrderId = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PlaceNewOrderScreen(
                returnOrderId: true,
              ),
            ),
          );

          if (newOrderId != null && mounted) {
            // Notify parent about the new orderId
            if (widget.onOrderPlaced != null) {
              widget.onOrderPlaced!(newOrderId);
            }
            // Load details for the new order
            _loadOrderDetails(newOrderId);
          }
        }),
        const SizedBox(height: 8),
        buildTableHeader(),

        // Show order details
        FutureBuilder<OrderDetailsResponse?>(
          future: _orderDetailsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 5.0),
                child: AutoTranslateText(""), // keep blank if no order yet
              );
            } else {
              final details = snapshot.data!;
              final products = details.detail ?? [];

              return Column(
                children: products.map((product) {
                  final productName = product.product?.name ?? "-";
                  final quantityStr = product.qty ?? "-";
                  final totalAmountStr = product.price ?? "0";

                  return buildTableRow(
                    productName,
                    quantityStr,
                    totalAmountStr,
                  );
                }).toList(),
              );
            }
          },
        ),
      ],
    );
  }
}
