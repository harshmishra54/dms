import 'package:TrustTags_DMS/common/app_colors.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/data/models/inward_preview_model.dart';
import 'package:TrustTags_DMS/features/dashboard/distributor_home_navigation.dart';
import 'package:TrustTags_DMS/features/dashboard/helper/child_scan_screen.dart';
import 'package:TrustTags_DMS/features/dashboard/helper/greentap_screen.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/accept_all_items_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/discard_all_items_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/inward_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/partial_accept_all_items_provider.dart';
import 'package:TrustTags_DMS/features/scan/providers/inward_complete_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScanDetailsScreen extends StatefulWidget {
  final OrderDetails orderDetails;

  const ScanDetailsScreen({super.key, required this.orderDetails});

  @override
  State<ScanDetailsScreen> createState() => _ScanDetailsScreenState();
}

class _ScanDetailsScreenState extends State<ScanDetailsScreen> {
  late OrderDetails _orderDetails;
  Set<String> _selectedBatches = {};
  Set<String> _selectedOrderDetails = {};
  Set<String> _partiallyAcceptedIds = {};



  @override
  void initState() {
    super.initState();
    _orderDetails = widget.orderDetails;

    // Run after build is done
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }


  Future<void> _refreshData() async {
    final inwardProvider = context.read<InwardProvider>();

    try {
      // Optional: show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // Call provider API with orderId
      await inwardProvider.fetchInwardDetails(_orderDetails.orderId);

      Navigator.pop(context); // close loading dialog

      if (!mounted) return;

      if (inwardProvider.inwardPreview != null &&
          inwardProvider.inwardPreview!.success == 1 &&
          inwardProvider.inwardPreview!.data != null) {
        setState(() {
          _orderDetails = inwardProvider.inwardPreview!.data!;
          _selectedBatches.clear(); // clear checkbox selections on refresh
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(inwardProvider.error ?? "Failed to refresh order details"),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // close loading
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            "Choose Action",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogOption("Accept All", Icons.check_circle, Colors.green, () async {
                Navigator.pop(dialogContext);

                final acceptProvider = context.read<AcceptAllItemsProvider>();

                // Show loader while API runs
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator()),
                );

                await acceptProvider.acceptAllItems(_orderDetails.orderId);

                Navigator.pop(context); // close loader

                if (!mounted) return;

                if (acceptProvider.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${acceptProvider.errorMessage}")),
                  );
                } else if (acceptProvider.response != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(acceptProvider.response!.message)),
                  );

                  // ✅ After success, navigate back to home
                  // Navigator.pushAndRemoveUntil(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => DistributorHomeNavigation(),
                  //   ),
                  //       (route) => false,
                  // );
                  _refreshData();
                }

                acceptProvider.reset();
              }),

              const Divider(),
              _dialogOption("Discard", Icons.delete, Colors.red, () async {
                Navigator.pop(dialogContext);

                final discardProvider =
                context.read<DiscardAllItemsProvider>();

                // Show loader while API runs
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator()),
                );

                await discardProvider.discardAllItems(_orderDetails.orderId);

                Navigator.pop(context); // close loader

                if (!mounted) return;

                if (discardProvider.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${discardProvider.errorMessage}")),
                  );
                } else if (discardProvider.response != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(discardProvider.response!.message)),
                  );

                  setState(() {
                    // ✅ Allow checkboxes to reappear after discard
                    _partiallyAcceptedIds.clear();
                    _selectedOrderDetails.clear();
                  });

                  _refreshData();
                }


                discardProvider
                    .notifyListeners(); // optional, but ensures UI updates
              }),
              const Divider(),
              _dialogOption("Complete", Icons.done_all, Colors.blue, () async {
                Navigator.pop(dialogContext); // close dialog first

                if (!mounted) return;

                final submitProvider = context.read<SubmitScanProvider>();
                await submitProvider.submitScan(orderId: _orderDetails.orderId);

                if (!mounted) return;

                if (submitProvider.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${submitProvider.errorMessage}")),
                  );
                } else if (submitProvider.response != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(submitProvider.response!.message)),
                  );

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DistributorHomeNavigation(),
                    ),
                        (route) => false,
                  );
                }

                submitProvider.reset();
              }),
            ],
          ),
        );
      },
    );
  }



  Widget _dialogOption(String text, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            const AppStatusBar(),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(left: 10, right: 10, top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios, color: Colors.black),
                  ),
                  const Text(
                    'Scan Details',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/trust_tags.png',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _showOptionsDialog(context),
                        child: const Icon(Icons.more_vert, color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
            ),


            /// Green scan details card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.topBarColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow('TO Location : ', _orderDetails.toId),
                  const SizedBox(height: 4),
                  _infoRow('Order No : ', _orderDetails.orderNo),
                  const SizedBox(height: 4),
                  // _infoRow('Delivery No : ', _orderDetails.orderId),
                  // const SizedBox(height: 4),
                  _infoRow('STO Status : ', _orderDetails.status),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  _tabItem('All', left: true),
                  _tabItem('Excess'),
                  _tabItem('Shortage', right: true),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Total Scanning : ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: _orderDetails.items.length,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemBuilder: (context, index) {
                  final item = _orderDetails.items[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.blueGrey, width: 0.5),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Total Scanning: ${item.inwardQty}/${item.totalQty}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              // Show checkbox only if inwardQty < totalQty
                              if (double.tryParse(item.inwardQty) != null &&
                                  double.tryParse(item.totalQty) != null &&
                                  double.parse(item.inwardQty) < double.parse(item.totalQty))
                                Checkbox(
                                  value: _selectedOrderDetails.contains(item.orderDetailsId),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedOrderDetails.add(item.orderDetailsId);
                                      } else {
                                        _selectedOrderDetails.remove(item.orderDetailsId);
                                      }
                                    });
                                  },
                                ),
                              Expanded(
                                child: Text(
                                  "Batch: ${item.batchNo}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),




                          Text(
                            "SKU:${item.sku}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GreenTapScreen(
                                        orderId: _orderDetails.orderId,
                                        orderDetailsId: item.orderDetailsId,
                                        type: 1,
                                      ),
                                    ),
                                  ).then((_) => _refreshData()); // Refresh after returning
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    border: Border.all(color: Colors.green),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    item.inwardQty,
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GreenTapScreen(
                                        orderId: _orderDetails.orderId,
                                        orderDetailsId: item.orderDetailsId,
                                        type: 2,
                                      ),
                                    ),
                                  ).then((_) => _refreshData()); // Refresh after returning
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    border: Border.all(color: Colors.red),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    item.missingQty,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
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

            Padding(
              padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InvoiceQRScannerScreen(
                              orderId: _orderDetails.orderId,
                            ),
                          ),
                        ).then((_) => _refreshData());
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: AppColors.topBarColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Scan',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Show Partial Accept button only if something is selected
                  if (_selectedOrderDetails.isNotEmpty)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final partialProvider =
                          context.read<PartialAcceptOrderProvider>();

                          // Show loader
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(child: CircularProgressIndicator()),
                          );

                          await partialProvider.partialAccept(
                            orderId: _orderDetails.orderId,
                            orderDetailsIds: _selectedOrderDetails.toList(),
                          );

                          Navigator.pop(context); // close loader

                          if (!mounted) return;

                          if (partialProvider.errorMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: ${partialProvider.errorMessage}")),
                            );
                          } else if (partialProvider.response != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(partialProvider.response!.message)),
                            );
                            setState(() {
                              _partiallyAcceptedIds.addAll(_selectedOrderDetails);
                              _selectedOrderDetails.clear(); // clear selection
                            });

                            // Refresh details after success
                            _refreshData();
                          }

                          partialProvider.reset();
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Partial Accept',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            softWrap: true,
          ),
        ),
      ],
    );
  }

  Widget _tabItem(String label, {bool left = false, bool right = false}) {
    return Expanded(
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.topBarColor,
          borderRadius: BorderRadius.horizontal(
            left: left ? const Radius.circular(10) : Radius.zero,
            right: right ? const Radius.circular(10) : Radius.zero,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
