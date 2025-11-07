import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/focus_product_provider.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:provider/provider.dart';
import '../../../data/models/order_product_list_data_response.dart';
import '../../../features/authentication/provider/order_product_provider.dart';
import '../../../features/dashboard/provider/scheme_products_provider.dart';
import '../../../core/utils/shared_prefs_helper.dart';

class ProductSelectorDropdown extends StatefulWidget {
  final Function(OrderProductListDataResponse?) onProductSelected;
  final String? distributorId; // ✅ pass selected distributor ID

  const ProductSelectorDropdown({
    super.key,
    required this.onProductSelected,
    this.distributorId,
  });

  @override
  State<ProductSelectorDropdown> createState() =>
      _ProductSelectorDropdownState();
}

class _ProductSelectorDropdownState extends State<ProductSelectorDropdown> {
  int selectedCategory = 0; // 0 = All, 1 = Focus, 2 = Best Seller, 3 = Scheme
  OrderProductListDataResponse? selectedProduct;

  @override
  Widget build(BuildContext context) {
    final orderProductProvider = context.watch<OrderProductProvider>();
    final focusProductProvider = context.watch<FocusProductProvider>();
    final schemeProvider = context.watch<SchemeProductsProvider>();

    final isLoading = selectedCategory == 0
        ? orderProductProvider.isLoading
        : selectedCategory == 3
        ? schemeProvider.loading
        : focusProductProvider.isLoading;

    // Prepare products list based on selected category
    List<OrderProductListDataResponse> products;
    if (selectedCategory == 0) {
      products = orderProductProvider.products;
    } else if (selectedCategory == 3) {
      final skuIds = schemeProvider.response?.skuIds ?? [];
      products = orderProductProvider.products
          .where((p) => skuIds.contains(p.id))
          .toList();
    } else {
      products = focusProductProvider.getProducts(selectedCategory);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔥 Category Tabs
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(child: _buildTab("All", 0, Colors.blue)),
              Expanded(child: _buildTab("Focus", 1, Colors.green)),
              Expanded(child: _buildTab("Seasonal", 2, Colors.orange)),
              Expanded(child: _buildTab("Scheme", 3, Colors.purple)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Product Dropdown
        Container(
          padding: const EdgeInsets.only(left: 12),
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : products.isEmpty
                    ? const Center(child: AutoTranslateText("No products available"))
                    : DropdownSearch<OrderProductListDataResponse>(
                  popupProps:
                  const PopupProps.menu(showSearchBox: true),
                  items: products,
                  itemAsString: (p) => p.productName,
                  dropdownDecoratorProps:
                  const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      hintText: "Search Product",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() => selectedProduct = val);
                    widget.onProductSelected(val);
                  },
                  selectedItem: selectedProduct,
                ),
              ),
              IconButton(
                onPressed: () {
                  if (selectedProduct != null) {
                    widget.onProductSelected(selectedProduct);
                  }
                },
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String label, int index, Color activeColor) {
    final isSelected = selectedCategory == index;
    return GestureDetector(
      onTap: () async {
        setState(() => selectedCategory = index);

        // Fetch Focus/Best/New products
        if (index > 0 && index != 3 && widget.distributorId != null) {
          final provider = context.read<FocusProductProvider>();
          provider.fetchProducts(index, locationId: widget.distributorId!);
        }

        // Fetch Scheme products
        if (index == 3 && widget.distributorId != null) {
          final schemeProvider = context.read<SchemeProductsProvider>();
          final roleId = await SharedPrefsHelper.getRoleId() ?? 1;


          await schemeProvider.fetchSchemeProducts(
          );

          setState(() {}); // rebuild to update dropdown
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: AutoTranslateText(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
