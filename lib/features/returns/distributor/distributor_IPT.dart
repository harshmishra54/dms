import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/features/returns/distributor/ipt_order_detail.dart';
import 'package:TrustTags_DMS/features/returns/distributor/ipt_scanner_screen.dart';
import 'package:TrustTags_DMS/features/returns/ipt_order_list_provider.dart';
import 'package:TrustTags_DMS/features/returns/ipt_distributor_provider.dart'; // <-- Import your provider
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../../common/widgets/app_status_bar.dart';

class DistributorIpt extends StatefulWidget {
  const DistributorIpt({super.key});

  @override
  State<DistributorIpt> createState() => _DistributorIptState();
}

class _DistributorIptState extends State<DistributorIpt> {
  String? selectedDistributor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final requestId = await SharedPrefsHelper.getUserId() ?? '';

      if (requestId.isEmpty) {
        debugPrint('Request ID not found in SharedPreferences');
      } else {
        // Fetch IPT Orders
        Provider.of<IptOrderListProvider>(context, listen: false)
            .fetchIptOrderList(
          isReceived: false,
          requestId: requestId,
        );

        // Fetch Distributors from API
        Provider.of<IptDistributorProvider>(context, listen: false)
            .fetchDistributors(requestId);
      }
    });
  }

  void _showDistributorDialog(BuildContext context) {
    final distributorProvider =
    Provider.of<IptDistributorProvider>(context, listen: false);

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
                  : distributorProvider.errorMessage != null
                  ? Center(
                child: AutoTranslateText(distributorProvider.errorMessage ?? ''),
              )
                  : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownSearch<String>(
                    items: distributors
                        .map((d) => d.name ?? '-')
                        .toList(),
                    popupProps: const PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          hintText: "Search distributor...",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    dropdownDecoratorProps:
                    const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        hintText: "Select Distributor",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),
                    onChanged: (value) {
                      Navigator.pop(context);

                      // ✅ Find full distributor object
                      final selected = distributors.firstWhere(
                            (d) => d.name == value,
                        orElse: () => distributors.first,
                      );

                      setState(() {
                        selectedDistributor = selected.name;
                      });

                      // ✅ Pass distributor.id to scanner screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => IptScannerScreen(
                            toLocationId: selected.id ?? "",
                          ),
                        ),
                      );
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



  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7FF),
      body: Column(
        children: [
          const AppStatusBar(),
          Container(
            color: Colors.white,
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const Center(
                  child: AutoTranslateText(
                    'IPT List',
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
            child: Consumer<IptOrderListProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (provider.errorMessage != null) {
                  return Center(child: AutoTranslateText(provider.errorMessage!));
                } else if (provider.iptOrders.isEmpty) {
                  return const Center(child: AutoTranslateText('No IPT orders found.'));
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: provider.iptOrders.length,
                    itemBuilder: (context, index) {
                      final order = provider.iptOrders[index];

                      return GestureDetector(
                        onTap: () {
                          // Navigate to IPT Order Details screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => IPTOrderDetailsScreen(
                                orderId: order.id ?? "", // Pass orderId
                              ),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    AutoTranslateText(
                                      order.name ?? '-',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    AutoTranslateText(
                                      'Date : ${_formatDate(order.orderDate)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    AutoTranslateText(
                                      'Value : ₹${order.price ?? '0.0'}',
                                      style: const TextStyle(
                                        color: Color(0xFFA259FF),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const AutoTranslateText(
                                          'Status: ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black, // always black
                                          ),
                                        ),
                                        AutoTranslateText(
                                          order.status ?? '-',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: order.status?.toLowerCase() == 'pending'
                                                ? Colors.amber[800]
                                                : order.status?.toLowerCase() == 'rejected'
                                                ? Colors.red
                                                : Colors.green,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );

                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDistributorDialog(context);
        },
        backgroundColor: const Color(0xFFA259FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }
}
