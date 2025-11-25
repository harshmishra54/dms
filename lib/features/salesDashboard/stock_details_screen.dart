import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/stock_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StockDetailsScreen extends StatefulWidget {
  final String title;

  const StockDetailsScreen({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  State<StockDetailsScreen> createState() => _StockDetailsScreenState();
}

class _StockDetailsScreenState extends State<StockDetailsScreen> {
  String? selectedAging;

  List<dynamic> displayedList = []; // frontend shown list

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final stockProvider = Provider.of<DistStockProvider>(context);

    // Load full list initially
    if (displayedList.isEmpty && stockProvider.stockList.isNotEmpty) {
      displayedList = List.from(stockProvider.stockList);
    }
  }

  // Quantity color logic
  Color getQuantityColor(int? quantity) {
    if (quantity == null) return Colors.grey;
    return quantity > 4 ? Colors.green.shade400 : Colors.red.shade400;
  }

  @override
  Widget build(BuildContext context) {
    final stockProvider = Provider.of<DistStockProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          const AppStatusBar(),

          // Header
          Material(
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.1),
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: AutoTranslateText(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // 🔽 AGING FILTER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedAging,
                      underline: const SizedBox(),
                      hint: const Text("Filter Aging"),
                      items: const [
                        DropdownMenuItem(value: "3", child: Text("Last 3 Months")),
                        DropdownMenuItem(value: "6", child: Text("Last 6 Months")),
                        DropdownMenuItem(value: "9", child: Text("Last 9 Months")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedAging = value;

                          // Dummy filtering logic
                          if (value == "3") {
                            displayedList = stockProvider.stockList.take(3).toList();
                          } else if (value == "6") {
                            displayedList = stockProvider.stockList.take(6).toList();
                          } else if (value == "9") {
                            displayedList = stockProvider.stockList.take(9).toList();
                          }
                        });
                      },
                    ),
                  ),
                ),

                if (selectedAging != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        selectedAging = null;
                        displayedList = List.from(stockProvider.stockList);
                      });
                    },
                  ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: Builder(
              builder: (_) {
                if (stockProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (stockProvider.errorMessage != null) {
                  return Center(
                    child: AutoTranslateText(
                      stockProvider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (displayedList.isEmpty) {
                  return const Center(
                    child: AutoTranslateText(
                      "No stock data found",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: displayedList.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Expanded(flex: 2, child: AutoTranslateText("Item Code", style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(flex: 2, child: AutoTranslateText("Batch No.", style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(flex: 1, child: AutoTranslateText("Pack", style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(flex: 1, child: AutoTranslateText("Bin", style: TextStyle(fontWeight: FontWeight.bold))),
                            Expanded(flex: 1, child: AutoTranslateText("Qty", style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                        ),
                      );
                    }

                    final stock = displayedList[index - 1];
                    final isEven = (index - 1) % 2 == 0;

                    return Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      decoration: BoxDecoration(
                        color: isEven ? Colors.white : Colors.blueGrey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: AutoTranslateText(stock.itemCode)),
                          Expanded(flex: 2, child: AutoTranslateText(stock.batchNo)),
                          Expanded(flex: 1, child: AutoTranslateText(stock.packagingLevel)),
                          Expanded(flex: 1, child: AutoTranslateText(stock.bin)),
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                              decoration: BoxDecoration(
                                color: getQuantityColor(stock.quantity).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: AutoTranslateText(
                                stock.quantity.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: getQuantityColor(stock.quantity),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
