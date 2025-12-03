import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/data/models/cancel_order_%20model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/data/models/order_details_model.dart';
import 'package:TrustTags_DMS/features/orders/provider/order_details_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/cancel_order_provider.dart';

class CancelUpdateOrderScreen extends StatefulWidget {
  final String orderId;
  final String roleId;
  final String requestId;

  const CancelUpdateOrderScreen({
    super.key,
    required this.orderId,
    required this.roleId,
    required this.requestId,
  });

  @override
  State<CancelUpdateOrderScreen> createState() =>
      _CancelUpdateOrderScreenState();
}

class _CancelUpdateOrderScreenState extends State<CancelUpdateOrderScreen> {
  OrderDetailsResponse? orderDetails;
  bool isLoading = true;
  bool _submitting = false;

  final Map<String, TextEditingController> _qtyCtrls = {};

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
          _qtyCtrls[d.product.id] =
              TextEditingController(text: d.qty.toString());
        }
      }
    });
  }

  /// ---- UPDATE ORDER ----
  Future<void> _handleUpdateOrder() async {
    if (orderDetails == null) return;

    final products = orderDetails!.detail.map((d) {
      final qty = int.tryParse(_qtyCtrls[d.product.id]!.text) ?? 0;
      return CancelProduct(productId: d.product.id, quantity: qty);
    }).toList();

    setState(() => _submitting = true);
    try {
      await context.read<CancelUpdateOrderProvider>().cancelOrUpdateOrder(
        orderId: widget.orderId,
        roleId: widget.roleId,
        requestId: widget.requestId,
        products: products,
        cancel: null,
      );

      final p = context.read<CancelUpdateOrderProvider>();
      if (!mounted) return;
      if (p.error != null) {
        _showSnack("Error: ${p.error}");
      } else {
        _showSnack(p.response?.message ?? "Order updated successfully");
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /// ---- CANCEL ORDER ----
  Future<void> _handleCancelOrder() async {
    if (orderDetails == null) return;

    /// Pass all product IDs with qty = 0
    final products = orderDetails!.detail.map((d) {
      return CancelProduct(productId: d.product.id, quantity: 0);
    }).toList();

    setState(() => _submitting = true);
    try {
      await context.read<CancelUpdateOrderProvider>().cancelOrUpdateOrder(
        orderId: widget.orderId,
        roleId: widget.roleId,
        requestId: widget.requestId,
        products: products,
        cancel: true,
      );

      final p = context.read<CancelUpdateOrderProvider>();
      if (!mounted) return;
      if (p.error != null) {
        _showSnack("Error: ${p.error}");
      } else {
        _showSnack(p.response?.message ?? "Order cancelled successfully");
        Navigator.pop(context, true);
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
      body: Column(
        children: [
          /// ---- Custom Header ----
          const AppStatusBar(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, color: Colors.black),
                ),
                const SizedBox(width: 12),
                const AutoTranslateText(
                  "Order Update",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          /// ---- Main Content ----
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : orderDetails == null
                ? const Center(child: AutoTranslateText("Failed to load order details"))
                : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orderDetails!.detail.length,
                    itemBuilder: (context, index) {
                      final item = orderDetails!.detail[index];
                      final controller =
                      _qtyCtrls[item.product.id]!;

                      return Card(
                        color: Colors.white,
                        margin:
                        const EdgeInsets.symmetric(vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              /// Left side: Product name & price
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    AutoTranslateText(
                                      item.product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    AutoTranslateText(
                                      "Price: ₹${item.price}",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              /// Right side: Qty + Delete
                              Row(
                                children: [
                                  SizedBox(
                                    width: 70,
                                    child: TextField(
                                      controller: controller,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly, // ⛔ blocks all non-digits
                                      ],
                                      decoration: const InputDecoration(
                                        hintText: "Qty",
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),

                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        controller.text = "0";
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                /// ---- ACTION BUTTONS ----
                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submitting
                              ? null
                              : _handleCancelOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            minimumSize:
                            const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),
                          ),
                          child: _submitting
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                            CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white),
                          )
                              : const AutoTranslateText("Cancel Order",style: TextStyle(color: Colors.white),),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submitting
                              ? null
                              : _handleUpdateOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize:
                            const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),
                          ),
                          child: _submitting
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                            CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white),
                          )
                              : const AutoTranslateText("Update Order",style: TextStyle(color: Colors.white),),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
