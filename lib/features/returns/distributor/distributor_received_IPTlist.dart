import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/features/returns/distributor/ipt_order_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/app_status_bar.dart';
import '../../../core/utils/shared_prefs_helper.dart';
import '../../returns/ipt_order_list_provider.dart';
import '../provider/ipt_order_update_provider.dart';


class DistributorReceivedIptlist extends StatefulWidget {
  const DistributorReceivedIptlist({super.key});

  @override
  State<DistributorReceivedIptlist> createState() =>
      _DistributorReceivedIptlistState();
}

class _DistributorReceivedIptlistState
    extends State<DistributorReceivedIptlist> {
  final Set<String> _loadingOrders = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final requestId = await SharedPrefsHelper.getUserId() ?? '';

      if (requestId.isNotEmpty) {
        Provider.of<IptOrderListProvider>(context, listen: false)
            .fetchIptOrderList(
          isReceived: true,
          requestId: requestId,
        );
      } else {
        debugPrint('Request ID not found in SharedPreferences');
      }
    });
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

  void _handleAcceptReject(String orderId, String action) async {
    setState(() => _loadingOrders.add(orderId));

    final updateProvider =
    Provider.of<IptOrderUpdateProvider>(context, listen: false);
    final listProvider =
    Provider.of<IptOrderListProvider>(context, listen: false);

    final status = action == 'accept' ? 'Accepted' : 'Rejected';

    try {
      await updateProvider.updateOrderStatus(orderId: orderId, status: status);

      if (updateProvider.successMessage != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: AutoTranslateText(updateProvider.successMessage!)));

        // Update local UI
        final index =
        listProvider.iptOrders.indexWhere((element) => element.id == orderId);
        if (index != -1) {
          setState(() {
            listProvider.iptOrders[index].status = status;
          });
        }
      } else if (updateProvider.errorMessage != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: AutoTranslateText(updateProvider.errorMessage!)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: AutoTranslateText('Something went wrong!')));
    } finally {
      setState(() => _loadingOrders.remove(orderId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7FF),
      body: Column(
        children: [
          const AppStatusBar(),

          // Custom AppBar
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
                    'Received IPT List',
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

          // IPT Orders List
          Expanded(
            child: Consumer<IptOrderListProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (provider.errorMessage != null) {
                  return Center(child: AutoTranslateText(provider.errorMessage!));
                } else if (provider.iptOrders.isEmpty) {
                  return const Center(
                      child: AutoTranslateText('No Received IPT orders found.'));
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: provider.iptOrders.length,
                    itemBuilder: (context, index) {
                      final order = provider.iptOrders[index];
                      final isLoading = _loadingOrders.contains(order.id);

                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => IPTOrderDetailsScreen(
                                orderId: order.id ?? "",
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name + Date
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
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

                                // Value + Status
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
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
                                            color: Colors.black,
                                          ),
                                        ),
                                        AutoTranslateText(
                                          order.status ?? '-',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color:
                                            order.status?.toLowerCase() ==
                                                'pending'
                                                ? Colors.amber[800]
                                                : order.status
                                                ?.toLowerCase() ==
                                                'rejected'
                                                ? Colors.red
                                                : Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                // Accept / Reject Buttons or Loader
                                if (order.status?.toLowerCase() == 'pending') ...[
                                  const SizedBox(height: 10),
                                  isLoading
                                      ? const Center(
                                    child: SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                      : Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    children: [
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                              color: Colors.purple,
                                              width: 1),
                                          backgroundColor: Colors.white,
                                        ),
                                        onPressed: () =>
                                            _handleAcceptReject(
                                                order.id!, 'accept'),
                                        child: const AutoTranslateText(
                                          'Accept',
                                          style: TextStyle(
                                              color: Colors.purple),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                              color: Colors.purple,
                                              width: 1),
                                          backgroundColor: Colors.white,
                                        ),
                                        onPressed: () =>
                                            _handleAcceptReject(
                                                order.id!, 'reject'),
                                        child: const AutoTranslateText(
                                          'Reject',
                                          style: TextStyle(
                                              color: Colors.purple),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
    );
  }
}
