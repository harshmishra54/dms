import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/add_order_request.dart';
import 'package:TrustTags_DMS/data/models/line_item.dart';
import 'package:TrustTags_DMS/data/models/order_product_list_data_response.dart';
import 'package:TrustTags_DMS/features/authentication/provider/add_order_provider.dart';
import 'package:TrustTags_DMS/features/authentication/provider/distributor_provider.dart';
import 'package:TrustTags_DMS/features/authentication/provider/order_product_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/credit_limit_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/focus_product_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/widgets/product_selector_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../../common/widgets/app_status_bar.dart';
import '../../../common/app_colors.dart';
import 'package:TrustTags_DMS/data/models/to_location_response.dart';

class PlaceNewOrderScreen extends StatefulWidget {
  final bool returnOrderId;
  const PlaceNewOrderScreen({super.key, this.returnOrderId = false});

  @override
  State<PlaceNewOrderScreen> createState() => _PlaceNewOrderScreenState();
}

class _PlaceNewOrderScreenState extends State<PlaceNewOrderScreen> {
  DistributorData? selectedDistributor;
  OrderProductListDataResponse? selectedProduct;
  List<LineItem> cartItems = [];
  DateTime? selectedDate;

  bool _isSubmitting = false; // ✅ prevent multiple taps

  int? loggedInRoleId;
  int? dailyRoleId;
  String distributorHint = "Please Select Distributor";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // fetch distributor list
      context.read<DistributorProviders>().fetchDistributors();

      // load roles
      loggedInRoleId = await SharedPrefsHelper.getRoleId() ?? 0;
      dailyRoleId = int.tryParse(await SharedPrefsHelper.getDailyRoleId() ?? "0") ?? 0;

      // determine hint text based on role logic
      if (loggedInRoleId == 1 || dailyRoleId == 1) {
        distributorHint = "Please Select CFA";
      } else {
        distributorHint = "Please Select Distributor";
      }

      // 🔹 Always fetch credit limit when entering page
      await _fetchCreditLimit();

      setState(() {}); // trigger rebuild
    });
  }

  void addProduct(OrderProductListDataResponse product) {
    setState(() {
      final index = cartItems.indexWhere((item) => item.itemCode == product.itemCode);
      if (index >= 0) {
        cartItems[index].qty += 1;
      } else {
        cartItems.add(LineItem(
          itemCode: product.itemCode,
          productName: product.productName,
          qty: 1,
          schemePoints: "0",
          batchId: "0",
          schemePrice: product.schemePrice.toStringAsFixed(2),
          purchasePrice: product.purchasePrice.toStringAsFixed(2),
          price: (product.schemePrice != null && product.schemePrice > 0)
              ? product.schemePrice.toStringAsFixed(2)
              : product.price.toStringAsFixed(2),
        ));
      }
    });
  }

  void updateQuantity(LineItem item, int change) {
    setState(() {
      final index = cartItems.indexOf(item);
      if (index >= 0) {
        cartItems[index].qty += change;
        if (cartItems[index].qty <= 0) {
          cartItems.removeAt(index);
        }
      }
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
  Future<void> _fetchCreditLimit() async {
    final creditProvider = context.read<CreditLimitProvider>();

    final loggedRole = await SharedPrefsHelper.getRoleId() ?? 0;
    final dailyRole = int.tryParse(await SharedPrefsHelper.getDailyRoleId() ?? "0") ?? 0;
    final userId = await SharedPrefsHelper.getUserId() ?? "";
    final dailyLocationId = await SharedPrefsHelper.getDailylocationId() ?? "";

    if (loggedRole == 1) {
      // Distributor login → fetch his credit
      await creditProvider.fetchDistributorCreditLimit(
        roleId: "1",
        distributorId: userId,
      );
    } else if (loggedRole == 18 && dailyRole == 1) {
      // Salesperson acting as Distributor
      await creditProvider.fetchDistributorCreditLimit(
        roleId: "1",
        distributorId: dailyLocationId,
      );
    }
  }
  bool _isFirstTime = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstTime) {
      _isFirstTime = false;
      _fetchCreditLimit();
    }
  }



  @override
  Widget build(BuildContext context) {
    final distributorProvider = context.watch<DistributorProviders>();
    final focusProductProvider = context.watch<FocusProductProvider>();
    final orderProductProvider = context.watch<OrderProductProvider>();

    double totalPrice = 0;

    for (var item in cartItems) {
      double itemPrice = 0;

      // If CFA/Distributor
      if (loggedInRoleId == 1 || dailyRoleId == 1) {
        // Prefer purchasePrice if valid, else fallback to price
        if (item.purchasePrice != null && double.tryParse(item.purchasePrice) != null && double.parse(item.purchasePrice) > 0) {
          itemPrice = double.parse(item.purchasePrice);
        } else {
          itemPrice = double.parse(item.price);
        }
      }

      // If Retailer or other role (3)
      else if (loggedInRoleId == 3 || dailyRoleId == 3) {
        // Prefer schemePrice if valid, else fallback to price
        if (item.schemePrice != null && double.tryParse(item.schemePrice) != null && double.parse(item.schemePrice) > 0) {
          itemPrice = double.parse(item.schemePrice);
        } else {
          itemPrice = double.parse(item.price);
        }
      }

      // Add total for this item
      totalPrice += itemPrice * item.qty;
    }


    const double gstPercent = 0.18;
    double gst = totalPrice * gstPercent;
    double discount = 0;
    double finalTotal = totalPrice + gst - discount;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7FF),
      body: Column(
        children: [
          const AppStatusBar(),
          Container(
            height: 56,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Center(
                  child: AutoTranslateText(
                    'Place New Order',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Distributor Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    alignment: Alignment.center,
                    child: distributorProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownSearch<DistributorData>(
                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            hintText: "Search Distributor",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                      ),
                      items: distributorProvider.distributors,
                      itemAsString: (DistributorData d) => d.name ?? "Unnamed Distributor",
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          hintText: distributorHint,
                          border: InputBorder.none,
                        ),
                      ),
                      onChanged: (val) async {
                        setState(() {
                          selectedDistributor = val;
                          cartItems.clear();
                        });

                        if (val != null) {
                          final orderProductProvider = context.read<OrderProductProvider>();
                          orderProductProvider.fetchOrderProductList(distributorId: val.id);

                          final focusProvider = context.read<FocusProductProvider>();
                          focusProvider.fetchProducts(1, locationId: val.id);
                          focusProvider.fetchProducts(2, locationId: val.id);
                          focusProvider.fetchProducts(3, locationId: val.id);

                          // 🔹 ADD CREDIT LIMIT FETCH HERE
                          final creditProvider = context.read<CreditLimitProvider>();

                          final loggedRole = await SharedPrefsHelper.getRoleId() ?? 0;
                          final dailyRole = int.tryParse(await SharedPrefsHelper.getDailyRoleId() ?? "0") ?? 0;
                          final userId = await SharedPrefsHelper.getUserId() ?? "";
                          final dailyLocationId = await SharedPrefsHelper.getDailylocationId() ?? "";

                          if (loggedRole == 1) {
                            // Distributor logged in → fetch his credit
                            creditProvider.fetchDistributorCreditLimit(
                              roleId: "1",
                              distributorId: userId,
                            );
                          } else if (loggedRole == 18 && dailyRole == 1) {
                            // Salesperson logged in, but acting as Distributor
                            creditProvider.fetchDistributorCreditLimit(
                              roleId: "1",
                              distributorId: dailyLocationId,
                            );
                          }
                        }
                      },

                      selectedItem: selectedDistributor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  ProductSelectorDropdown(
                    distributorId: selectedDistributor?.id,
                    onProductSelected: (product) {
                      if (product != null) {
                        addProduct(product);
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Date Picker Field
                  GestureDetector(
                    onTap: () => _pickDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDate == null
                                ? "Select Expected Date"
                                : "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Icon(Icons.calendar_today, color: Colors.deepPurple),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Cart List
                  Column(
                    children: cartItems.map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),

                                  // Always show base price
                                  Text("Base Price: ₹${item.price}"),

                                  // Show scheme or purchase price depending on role
                                  if (loggedInRoleId == 1 || dailyRoleId == 1)
                                    Text(
                                      "Purchase Price: ₹${item.purchasePrice}",
                                      style: const TextStyle(color: Colors.black),
                                    )
                                  else if (loggedInRoleId == 3 || dailyRoleId == 3)
                                    Text(
                                      "Scheme Price: ₹${item.schemePrice}",
                                      style: const TextStyle(color: Colors.black),
                                    ),
                                ],
                              ),
                            ),

                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => updateQuantity(item, -1),
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                                Text(item.qty.toString()),
                                IconButton(
                                  onPressed: () => updateQuantity(item, 1),
                                  icon: const Icon(Icons.add_circle_outline),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Bill Summary
                  if (cartItems.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AutoTranslateText('Bill Summary',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Divider(thickness: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const AutoTranslateText('Item Price :'),
                              Text("₹${totalPrice.toStringAsFixed(2)}"),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const AutoTranslateText('GST (18%) :'),
                              Text("₹${gst.toStringAsFixed(2)}"),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const AutoTranslateText('Discount :'),
                              Text("₹${discount.toStringAsFixed(2)}"),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const AutoTranslateText('Total :',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16)),
                              Text("₹${finalTotal.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.deepPurple)),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Submit Button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 40, left: 16, right: 16),
            height: 52,
            child: ElevatedButton(
              onPressed: () async {
                if (_isSubmitting) return; // Prevent double-tap
                setState(() => _isSubmitting = true);

                if (selectedDistributor == null || cartItems.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: AutoTranslateText("Please select distributor and add at least one product")),
                  );
                  setState(() => _isSubmitting = false);
                  return;
                }

                if (selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: AutoTranslateText("Please select an expected date")),
                  );
                  setState(() => _isSubmitting = false);
                  return;
                }

                try {
                  final addOrderProvider = context.read<AddOrderProvider>();
                  final creditProvider = context.read<CreditLimitProvider>();

                  final String userId = await SharedPrefsHelper.getUserId() ?? "";
                  final int loggedInRoleId = await SharedPrefsHelper.getRoleId() ?? 0;
                  final String dailyLocationId = await SharedPrefsHelper.getDailylocationId() ?? "";
                  final int dailyRoleId = int.tryParse(await SharedPrefsHelper.getDailyRoleId() ?? "0") ?? 0;

                  // 🔹 Fetch latest credit limit
                  if (loggedInRoleId == 1) {
                    await creditProvider.fetchDistributorCreditLimit(
                      roleId: "1",
                      distributorId: userId,
                      forceRefresh: true,
                    );
                  } else if (loggedInRoleId == 18 && dailyRoleId == 1) {
                    await creditProvider.fetchDistributorCreditLimit(
                      roleId: "1",
                      distributorId: dailyLocationId,
                      forceRefresh: true,
                    );
                  }

                  // 🔹 Credit limit validation
                  double currentLimit = 0;
                  bool shouldCheckCredit = false;

                  if (loggedInRoleId == 1) {
                    final creditData = creditProvider.creditMap[userId];
                    if (creditData != null) {
                      currentLimit = double.tryParse(creditData.currentLimit ?? "0") ?? 0;
                      shouldCheckCredit = true;
                    }
                  } else if (loggedInRoleId == 18 && dailyRoleId == 1) {
                    final creditData = creditProvider.creditMap[dailyLocationId];
                    if (creditData != null) {
                      currentLimit = double.tryParse(creditData.currentLimit ?? "0") ?? 0;
                      shouldCheckCredit = true;
                    }
                  }

                  bool proceedWithOrder = true;

                  if (shouldCheckCredit && currentLimit > 0 && finalTotal > currentLimit) {
                    final diff = finalTotal - currentLimit;

                    // 🔹 Show dialog for credit exceed
                    proceedWithOrder = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const AutoTranslateText("Credit Limit Exceeded"),
                        content: AutoTranslateText(
                          "Your credit limit is ₹${currentLimit.toStringAsFixed(2)}.\n\n"
                              "Order total ₹${finalTotal.toStringAsFixed(2)} exceeds it by ₹${diff.toStringAsFixed(2)}.\n\n"
                              "Do you want to proceed with the order anyway?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false), // Cancel
                            child: const AutoTranslateText("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true), // Proceed
                            child: const AutoTranslateText("Proceed"),
                          ),
                        ],
                      ),
                    ) ??
                        false; // default false if dismissed
                  }

                  if (!proceedWithOrder) {
                    setState(() => _isSubmitting = false);
                    return;
                  }

                  // ✅ Proceed with order submission
                  final int requestedRoleId = loggedInRoleId;
                  int roleId;
                  String fromLocation;

                  if (loggedInRoleId == 1 || loggedInRoleId == 3) {
                    roleId = loggedInRoleId;
                    fromLocation = userId;
                  } else {
                    roleId = dailyRoleId;
                    fromLocation = dailyLocationId;
                  }

                  final request = AddOrderRequest(
                    price: totalPrice.toStringAsFixed(2),
                    schemePrice: "0",
                    gst: gst.toStringAsFixed(2),
                    roleId: roleId,
                    requestedRoleId: requestedRoleId,
                    qty: cartItems.fold(0, (sum, item) => sum + item.qty),
                    createdBy: userId,
                    fromLocation: fromLocation,
                    toLocation: selectedDistributor?.id ?? "",
                    expectedDate:
                    "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}",
                    lineItems: cartItems,
                  );

                  await addOrderProvider.submitOrder(request);

                  if (addOrderProvider.response != null &&
                      addOrderProvider.response!.success == 1) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: AutoTranslateText("Order placed successfully.")),
                      );
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (context.mounted) {
                          final orderId = addOrderProvider.response?.orderId;
                          if (widget.returnOrderId && orderId != null) {
                            Navigator.pop(context, orderId);
                          } else {
                            Navigator.pop(context);
                          }
                        }
                      });
                    }
                  } else {
                    if (mounted) setState(() => _isSubmitting = false);
                  }
                } catch (e) {
                  debugPrint("Error placing order: $e");
                  if (mounted) setState(() => _isSubmitting = false);
                }
              },


              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA259FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const AutoTranslateText(
                'Submit Order',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
