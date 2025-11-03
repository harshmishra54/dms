import 'package:TrustTags_DMS/common/app_colors.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/farmer_query_add_model.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/farmer_query_provider.dart';
import 'package:TrustTags_DMS/features/authentication/provider/order_product_provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class RecordFarmerQueryScreen extends StatefulWidget {
  const RecordFarmerQueryScreen({super.key});

  @override
  State<RecordFarmerQueryScreen> createState() =>
      _RecordFarmerQueryScreenState();
}

class _RecordFarmerQueryScreenState extends State<RecordFarmerQueryScreen> {
  final TextEditingController _queryController = TextEditingController();
  final List<Map<String, String>> selectedProducts = []; // [{id, name}]
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider =
      Provider.of<OrderProductProvider>(context, listen: false);
      provider.fetchOrderProductList();
    });
  }

  /// ✅ Get current location
  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location services are disabled.")),
      );
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permissions are denied.")),
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Location permissions are permanently denied. Please enable them in settings.",
          ),
        ),
      );
      return null;
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  /// ✅ Submit query to backend
  Future<void> _submitQuery() async {
    if (selectedProducts.isEmpty || _queryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Please select at least one product and enter a query.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final farmerQueryProvider =
    Provider.of<FarmerQueryProvider>(context, listen: false);
    final userId = await SharedPrefsHelper.getUserId();

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User ID not found. Please login again.")),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    final position = await _getCurrentLocation();
    if (position == null) {
      setState(() => _isSubmitting = false);
      return;
    }

    final request = FarmerQueryRequest(
      queries: _queryController.text.trim(),
      suggestedProducts:
      selectedProducts.map((e) => e["id"] ?? "").toList(), // only ids
      createdBy: userId,
      latitude: position.latitude,
      longitude: position.longitude,
      flag: true,
    );

    await farmerQueryProvider.addFarmerQuery(request);
    setState(() => _isSubmitting = false);

    if (farmerQueryProvider.response != null &&
        farmerQueryProvider.response!.success == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(farmerQueryProvider.response!.message)),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            farmerQueryProvider.errorMessage ??
                "Failed to submit query. Please try again.",
          ),
        ),
      );
    }
  }

  /// ✅ Add selected product from dropdown
  void _addProduct(String id, String name) {
    final alreadyExists = selectedProducts.any((p) => p["id"] == id);
    if (!alreadyExists) {
      setState(() {
        selectedProducts.add({"id": id, "name": name});
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product already added.")),
      );
    }
  }

  /// ✅ Remove product card
  void _removeProduct(String id) {
    setState(() {
      selectedProducts.removeWhere((p) => p["id"] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProductProvider = Provider.of<OrderProductProvider>(context);
    final isLoading = orderProductProvider.isLoading;
    final products = orderProductProvider.products;

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
                    child: Text(
                      'Farmers Queries',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 18),
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
                : products.isEmpty
                ? const Center(
              child: Text(
                "No products found",
                style: TextStyle(fontSize: 16),
              ),
            )
                : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Suggested Product",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),

                  /// ✅ Dropdown for selecting products
                  DropdownSearch<String>(
                    items: products
                        .map((e) => e.productName ?? "")
                        .toList(),
                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          hintText: "Search product...",
                        ),
                      ),
                    ),
                    dropdownDecoratorProps:
                    const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        hintText: "Select a product",
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        final selected = products.firstWhere(
                                (p) => p.productName == value);
                        _addProduct(selected.id ?? "", value);
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  /// ✅ Selected Product Cards
                  if (selectedProducts.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Selected Products",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        ...selectedProducts.map(
                              (p) => Card(
                                color: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              title: Text(p["name"] ?? ''),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () =>
                                    _removeProduct(p["id"]!),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                  const Text(
                    "Record Query / Demand",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _queryController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText:
                      "Enter farmer's query or demand here",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                      _isSubmitting ? null : _submitQuery,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14),
                        backgroundColor: AppColors.topBarColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        "Add Demand",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
