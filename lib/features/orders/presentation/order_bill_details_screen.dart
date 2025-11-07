import 'package:TrustTags_DMS/common/app_colors.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/order_details_model.dart';
import 'package:TrustTags_DMS/data/models/partial_update_model.dart';
import 'package:TrustTags_DMS/data/models/reorder_model.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/reorder_provider.dart';
import 'package:TrustTags_DMS/features/orders/provider/order_details_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/partial_update_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';

class OrderBillDetailsScreen extends StatefulWidget {
  final String orderId;
  final String roleId;
  final String requestId;

  /// 👇 pass true when user tapped "PARTIAL" in the list screen
  final bool isPartialFlow;

  /// 👇 pass the date you already picked on the list screen (yyyy-MM-dd)
  final String? deliveryDate;

  const OrderBillDetailsScreen({
    super.key,
    required this.orderId,
    required this.roleId,
    required this.requestId,
    this.isPartialFlow = false,
    this.deliveryDate,
  });

  @override
  State<OrderBillDetailsScreen> createState() => _OrderBillDetailsScreenState();
}

class _OrderBillDetailsScreenState extends State<OrderBillDetailsScreen> {
  OrderDetailsResponse? orderDetails;
  bool isLoading = true;
  bool _submitting = false;
  bool _reordering = false;

  /// qty controllers keyed by productId
  final Map<String, TextEditingController> _qtyCtrls = {};
  /// original ordered qty to validate against
  final Map<String, int> _originalQty = {};
  Color _getStatusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case "pending":
        return Colors.orange;
      case "rejected":
      case "auto rejected":
        return Colors.red;
      default:
        return Colors.green; // approved / completed etc.
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

      if (result != null) {
        for (final d in result.detail) {
          final productId = d.product.id; // assuming String
          final ordered = int.tryParse(d.qty) ?? 0;
          _originalQty[productId] = ordered;

          final c = TextEditingController(text: d.qty);
          if (widget.isPartialFlow) {
            c.addListener(() => setState(() {})); // live total refresh
          }
          _qtyCtrls[productId] = c;
        }
      }
    });
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

  Future<void> _handleConfirmPartialAccept() async {
    final requestId =await SharedPrefsHelper.getUserId();
    if (orderDetails == null) return;

    // ensure deliveryDate
    String? deliveryDate = widget.deliveryDate;
    if (deliveryDate == null || deliveryDate.isEmpty) {
      deliveryDate = await _pickDeliveryDate();
      if (deliveryDate == null) return;
    }

    // validate qtys
    for (final d in orderDetails!.detail) {
      final productId = d.product.id;
      final text = _qtyCtrls[productId]!.text.trim();
      final val = int.tryParse(text);

      if (val == null) {
        _showSnack("Please enter valid quantities.");
        return;
      }
      final max = _originalQty[productId] ?? 0;
      if (val < 0 || val > max) {
        _showSnack("Qty for ${d.product.name} must be between 0 and $max.");
        return;
      }
    }

    // build request
    final req = PartialOrderUpdateModel(
      id: orderDetails!.data.id,                 // order id
      roleId: 1,
      requestId: requestId,
      deliveryDate: deliveryDate,
      products: orderDetails!.detail.map<ProductUpdate>((d) {
        final productId = d.product.id;
        final qty = int.tryParse(_qtyCtrls[productId]!.text) ?? 0;
        return ProductUpdate(productId: productId, approvedQty: qty);
      }).toList(),
    );

    setState(() => _submitting = true);
    try {
      await context.read<PartiallyOrderUpdateProvider>().updatePartialOrder(req);

      final p = context.read<PartiallyOrderUpdateProvider>();
      if (!mounted) return;

      if (p.errorMessage != null) {
        _showSnack("Error: ${p.errorMessage}");
      } else {
        _showSnack(p.orderResponse?.message ?? "Partial update successful");
        Navigator.pop(context, true); // go back and let caller refresh
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: AutoTranslateText(msg)));
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
                ? const Center(child: AutoTranslateText("Failed to load order details"))
                : _buildOrderContent(orderDetails!),
          ),
          if (!isLoading && orderDetails != null && widget.isPartialFlow)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ElevatedButton(
                onPressed: _submitting ? null : _handleConfirmPartialAccept,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: AppColors.topBarColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                    width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                    : const AutoTranslateText("Confirm Partial Accept",style: TextStyle(color: Colors.white,fontSize: 15),),
              ),
            ),
        ],
      ),
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
            child: AutoTranslateText(
              'Order Details',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18, color: Colors.black),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildOrderContent(OrderDetailsResponse data) {
    // estimate total using edited qtys (only for display; server will compute final)
    double estimateSubtotal = 0;

    final items = data.detail.map((item) {
      final price = double.tryParse(item.price) ?? 0;
      final productId = item.product.id;
      final qtyText = _qtyCtrls[productId]!.text;
      final qty = int.tryParse(qtyText.isEmpty ? "0" : qtyText) ?? 0;

      estimateSubtotal += price * qty;

      return Padding(
        padding: const EdgeInsets.only(bottom:8.0),
        child: _itemTile(
          name: item.product.name,
          productId: productId,
          orderedQty: int.tryParse(item.qty) ?? 0,
          unitPrice: price,
        ),
      );
    }).toList();

    final gst = double.tryParse(data.data.gst) ?? 0;
    final discountPrice = double.tryParse(data.data.discountPrice) ?? 0;

// 👇 For partial flow, use estimateSubtotal instead of original price
    final estimatedTotal = (widget.isPartialFlow ? estimateSubtotal : discountPrice) + gst;


    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Order Info
        Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AutoTranslateText("Order Details", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                AutoTranslateText("Order ID : ${data.data.orderNo ?? ""}"),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Date : ${data.data.orderDate.split('T')[0]}"),
                    Row(
                      children: [
                        // Order status
                        Text(
                          "Order ${data.data.status}",
                          style: TextStyle(
                            color: _getStatusColor(data.data.status),
                            fontWeight: FontWeight.w600,
                          ),
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

        // Items (editable in partial flow)
        ...items,
        const SizedBox(height: 12),

        // Bill Summary (shows estimated when in partial flow)
        Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AutoTranslateText("Bill Summary", style: TextStyle(fontWeight: FontWeight.bold)),
                const Divider(),
                _billRow(
                  widget.isPartialFlow ? "Estimated Item Price :" : "Discounted Price :",
                  "₹${(widget.isPartialFlow ? estimateSubtotal : discountPrice).toStringAsFixed(2)}",
                ),
                _billRow("GST :", "₹${gst.toStringAsFixed(2)}"),

                _billRow("Scheme Points :", data.data.schemePoints?.toString() ?? ""),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AutoTranslateText(
                      "Total :",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple),
                    ),
                    AutoTranslateText(
                      "₹${estimatedTotal.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple),
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

  Widget _itemTile({
    required String name,
    required String productId,
    required int orderedQty,
    required double unitPrice,
  }) {
    final controller = _qtyCtrls[productId]!;

    final qty = int.tryParse(controller.text.isEmpty ? "0" : controller.text) ?? 0;
    final lineTotal = unitPrice * qty;

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AutoTranslateText(name, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.isPartialFlow)
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Qty (max $orderedQty)",
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                )
              else
                AutoTranslateText("Qty : $orderedQty"),
              AutoTranslateText("Price : ₹${unitPrice.toStringAsFixed(2)}"),
              AutoTranslateText(
                "₹${lineTotal.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
            ],
          )
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
