import 'package:TrustTags_DMS/common/app_colors.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/data/models/order_product_list_data_response.dart';
import 'package:TrustTags_DMS/data/models/tsi_update_model.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/tsi_update_order_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/data/models/order_details_model.dart';
import 'package:TrustTags_DMS/features/orders/provider/order_details_provider.dart';
import 'package:TrustTags_DMS/features/authentication/provider/order_product_provider.dart';
import 'package:TrustTags_DMS/data/models/line_item.dart';
import 'package:dropdown_search/dropdown_search.dart';

class TSIUpdateOrderScreen extends StatefulWidget {
  final String orderId;
  final String roleId;
  final String requestId;

  const TSIUpdateOrderScreen({
    super.key,
    required this.orderId,
    required this.roleId,
    required this.requestId,
  });

  @override
  State<TSIUpdateOrderScreen> createState() => _TSIUpdateOrderScreenState();
}

class _TSIUpdateOrderScreenState extends State<TSIUpdateOrderScreen> {
  OrderDetailsResponse? orderDetails;
  bool isLoading = true;
  bool _submitting = false;
  final Map<String, TextEditingController> _qtyCtrls = {};
  OrderProductListDataResponse? _selectedProduct;

  /// Product UUID → Product mapping
  Map<String, OrderProductListDataResponse> _productMap = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrderDetails();
      _fetchProductList();
    });
  }

  Future<void> _loadOrderDetails() async {
    final provider = context.read<OrderDetailsProvider>();
    final result = await provider.fetchOrderDetails(
      roleId: widget.roleId,
      id: widget.orderId,
      requestId: widget.requestId,
    );

    if (!mounted) return;

    setState(() {
      orderDetails = result;
      isLoading = false;
      if (result != null) {
        for (final d in result.detail) {
          _qtyCtrls[d.product.id] = TextEditingController(text: d.qty);
        }
      }
    });
  }

  Future<void> _fetchProductList() async {
    final provider = context.read<OrderProductProvider>();
    await provider.fetchOrderProductList(
      requestIdOverride: widget.requestId,
      roleIdOverride: widget.roleId,
    );

    // Build UUID → Product map
    _productMap = {for (var p in provider.products) p.id: p};
  }

  Future<void> _handleUpdateOrder() async {
    if (orderDetails == null) return;

    final lineItems = orderDetails!.detail.map((d) {
      final qty = int.tryParse(_qtyCtrls[d.product.id]?.text ?? "0") ?? 0;
      final matchedProduct = _productMap[d.product.id];

      return LineItem(
        itemCode: matchedProduct?.itemCode ?? "",
        productName: matchedProduct?.productName ?? d.product.name,
        qty: qty,
        schemePoints: d.schemePrice ?? "0",
        purchasePrice: d.purchasePrice ?? "0",
        batchId: d.batchId ?? "",
        schemePrice: d.schemePrice ?? "0",
        price: d.price ?? "0",
      );
    }).where((item) => item.qty > 0).toList();

    if (lineItems.isEmpty) {
      _showSnack("Please add at least one product with quantity.");
      return;
    }

    setState(() => _submitting = true);

    try {
      final request = UpdateOrderRequest(
        orderId: widget.orderId,
        fromLocation: widget.requestId,
        lineItems: lineItems,
      );

      final success =
      await context.read<UpdateOrderProvider>().updateOrder(request);

      if (!mounted) return;
      final provider = context.read<UpdateOrderProvider>();

      if (success) {
        _showSnack(provider.updateOrderResponse?.message ??
            "Order updated successfully");
        Navigator.pop(context, true);
      } else {
        _showSnack(provider.errorMessage ?? "Failed to update order");
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
                      'Order Update',
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
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : orderDetails == null
                ? const Center(child: AutoTranslateText("Failed to load order details"))
                : Column(
              children: [
                // Dropdown to add products
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Consumer<OrderProductProvider>(
                    builder: (context, productProvider, _) {
                      if (productProvider.isLoading) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: DropdownSearch<
                                OrderProductListDataResponse>(
                              items: productProvider.products,
                              selectedItem: _selectedProduct,
                              itemAsString: (p) => p?.productName ?? "",
                              onChanged: (value) {
                                setState(() {
                                  _selectedProduct = value;
                                });
                              },
                              popupProps: PopupProps.menu(
                                showSearchBox: true,
                                fit: FlexFit.loose,
                                menuProps: MenuProps(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              dropdownBuilder: (context, selectedItem) {
                                return Container(
                                  height: 50,
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    selectedItem?.productName ??
                                        "Select Product",
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Add button
                          SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _selectedProduct == null
                                  ? null
                                  : () {
                                if (_selectedProduct != null) {
                                  bool exists = orderDetails!.detail
                                      .any((e) =>
                                  e.product.id ==
                                      _selectedProduct!.id);
                                  if (!exists) {
                                    setState(() {
                                      orderDetails!.detail.add(
                                        OrderDetail(
                                          id: DateTime.now()
                                              .millisecondsSinceEpoch
                                              .toString(),
                                          orderId: widget.orderId,
                                          productId:
                                          _selectedProduct!.id,
                                          qty: "1",
                                          price: _selectedProduct!.price
                                              .toString(),
                                          product: ProductData(
                                            id: _selectedProduct!.id,
                                            name: _selectedProduct!
                                                .productName,
                                          ),
                                          level: null,
                                          batchId: null,
                                          schemePrice: null,
                                          createdAt: DateTime.now()
                                              .toIso8601String(),
                                          updatedAt: DateTime.now()
                                              .toIso8601String(),
                                        ),
                                      );
                                      _qtyCtrls[_selectedProduct!.id] =
                                          TextEditingController(text: "1");
                                      _selectedProduct = null;
                                    });
                                  } else {
                                    _showSnack("Product already added");
                                  }
                                }
                              },
                              icon: const Icon(Icons.add, size: 20,color: Colors.white,),
                              label: const AutoTranslateText("Add",style: TextStyle(color: Colors.white),),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:AppColors.topBarColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                // Product list with qty
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orderDetails!.detail.length,
                    itemBuilder: (context, index) {
                      final item = orderDetails!.detail[index];
                      final controller = _qtyCtrls[item.product.id]!;

                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                              Row(
                                children: [
                                  SizedBox(
                                    width: 70,
                                    child: TextField(
                                      controller: controller,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      decoration: const InputDecoration(
                                        hintText: "Qty",
                                        isDense: true,
                                        contentPadding:
                                        EdgeInsets.symmetric(vertical: 8),
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon:
                                    const Icon(Icons.delete, color: Colors.red),
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
                // Update button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                          _submitting ? null : _handleUpdateOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.topBarColor,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _submitting
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const AutoTranslateText(
                            "Update Order",
                            style: TextStyle(color: Colors.white),
                          ),
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
