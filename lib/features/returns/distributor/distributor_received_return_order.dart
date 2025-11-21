import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/data/models/to_location_response.dart';
import 'package:TrustTags_DMS/features/authentication/provider/distributor_provider.dart';
import 'package:TrustTags_DMS/features/returns/Add_return_order.dart';
import 'package:TrustTags_DMS/features/returns/distributor/return_order_bill_details.dart';
import 'package:TrustTags_DMS/features/returns/recieve_return_claim_provider.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';

class DistributorReceivedReturnOrder extends StatefulWidget {
  const DistributorReceivedReturnOrder({super.key});

  @override
  State<DistributorReceivedReturnOrder> createState() =>
      _DistributorReceivedReturnOrderState();
}

class _DistributorReceivedReturnOrderState
    extends State<DistributorReceivedReturnOrder> {
  String searchQuery = "";
  String? roleId;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  /// 🔄 Refresh orders + distributors + roleId
  Future<void> _refreshData() async {
    final receiveProvider =
    Provider.of<ReceiveReturnClaimProvider>(context, listen: false);
    final distributorProvider =
    Provider.of<DistributorProviders>(context, listen: false);

    receiveProvider.fetchReceiveReturnClaims();
    distributorProvider.fetchDistributors();

    final fetchedRoleId = await SharedPrefsHelper.getRoleId();
    roleId = fetchedRoleId?.toString() ?? "";
    setState(() {});
  }

  /// Format date to "dd/MM/yyyy"
  String _formatDate(String dateString) {
    try {
      final parsedDate = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return dateString.split(" ").first;
    }
  }

  /// 🔹 Show distributor selection dialog
  void _showDistributorDialog(BuildContext context) {
    final distributorProvider =
    Provider.of<DistributorProviders>(context, listen: false);

    final distributors = distributorProvider.distributors;

    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: distributorProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : distributors.isEmpty
                  ? Center(
                child: AutoTranslateText(
                  (roleId == "1")
                      ? "No CFAs found"
                      : "No distributors found",
                ),
              )
                  : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownSearch<DistributorData>(
                    items: distributors,
                    itemAsString: (DistributorData d) => d.name,
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          hintText: (roleId == "1")
                              ? "Search CFA..."
                              : "Search distributor...",
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        hintText: (roleId == "1")
                            ? "Select CFA"
                            : "Select Distributor",
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),
                    onChanged: (DistributorData? distributor) {
                      if (distributor == null) return;
                      Navigator.pop(context);
                      debugPrint(
                          "✅ Selected ${roleId == "1" ? "CFA" : "Distributor"}: ${distributor.name} (ID: ${distributor.id})");

                      // 👉 Navigate to AddReturnOrderScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddReturnOrderScreen(
                            distributorName: distributor.name,
                            distributorId: distributor.id,
                          ),
                        ),
                      ).then((_) {
                        // 🔄 Refresh after coming back
                        _refreshData();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 🔍 Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by Order No or Status',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF0F0F0),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),

          // 📦 Orders list
          Expanded(
            child: Consumer<ReceiveReturnClaimProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null) {
                  return Center(
                    child: AutoTranslateText(
                      provider.errorMessage!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final filteredOrders = provider.orders.where((order) {
                  final orderNo = order.orderNo?.toLowerCase() ?? '';
                  final status = order.status.toLowerCase();
                  return orderNo.contains(searchQuery) ||
                      status.contains(searchQuery);
                }).toList();

                if (filteredOrders.isEmpty) {
                  return const Center(
                    child: AutoTranslateText(
                      'No matching orders found.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReturnOrderDetailsScreen(
                              orderId: order.id,
                              roleId: order.roleId.toString(),
                              requestId: order.fromLocation,
                            ),
                          ),
                        ).then((_) {
                          // 🔄 Refresh after coming back
                          _refreshData();
                        });
                      },
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Row 1: Order No & Date
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  AutoTranslateText(
                                    order.orderNo ?? "Order #${order.id}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  AutoTranslateText(
                                    _formatDate(order.orderDate),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Row 2: Value & Status
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  AutoTranslateText(
                                    "Value: ₹${order.price}",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.purple,
                                    ),
                                  ),
                                  AutoTranslateText(
                                    order.status,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: order.status.toLowerCase() ==
                                          "pending"
                                          ? Colors.orange
                                          : order.status.toLowerCase() ==
                                          "accepted"
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // ✅ Floating Action Button
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          backgroundColor: Colors.deepPurple,
          onPressed: () {
            _showDistributorDialog(context);
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
