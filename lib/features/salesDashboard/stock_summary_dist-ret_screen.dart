import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/data/models/dist_stock_models.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/dist_retailer_list_for_rout_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/stock_data_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/cfa_stock_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/stock_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/dist_retailer_rout_model.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/common/app_colors.dart';

class DistributorRetailerScreen extends StatefulWidget {
  final String? tsiId;

  const DistributorRetailerScreen({Key? key, this.tsiId}) : super(key: key);

  @override
  _DistributorRetailerScreenState createState() =>
      _DistributorRetailerScreenState();
}

class _DistributorRetailerScreenState extends State<DistributorRetailerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TerritoryProvider>(
          create: (_) {
            final provider = TerritoryProvider();
            _initProvider(provider, widget.tsiId);
            return provider;
          },
        ),
        ChangeNotifierProvider<CfaStockProvider>(
          create: (_) => CfaStockProvider()..fetchCfaStock(),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Consumer2<TerritoryProvider, CfaStockProvider>(
          builder: (context, territoryProvider, cfaProvider, child) {
            if (territoryProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (territoryProvider.errorMessage != null) {
              return Center(
                child: Text(
                  territoryProvider.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            List<TerritoryData> filterList(List<TerritoryData> list) {
              if (_searchText.isEmpty) return list;
              return list
                  .where((item) =>
              item.name != null &&
                  item.name!
                      .toLowerCase()
                      .contains(_searchText.toLowerCase()))
                  .toList();
            }

            final distributors = filterList(territoryProvider.distributors);
            final retailers = filterList(territoryProvider.retailers);

            return Column(
              children: [
                const AppStatusBar(),
                // Header
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
                            'Members',
                            textAlign: TextAlign.center,
                            style: TextStyle(
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
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search by name...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                // TabBar
                Expanded(
                  child: DefaultTabController(
                    length: 3,
                    child: Column(
                      children: [
                        Container(
                          color: Colors.white,
                          child: const TabBar(
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: AppColors.topBarColor,
                            tabs: [
                              Tab(text: 'Distributors'),
                              Tab(text: 'Retailers'),
                              Tab(text: 'CFA Stocks'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              // Distributors Tab
                              distributors.isEmpty
                                  ? const Center(
                                  child: Text(
                                      "No distributors found"))
                                  : ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: distributors.length,
                                itemBuilder: (context, index) {
                                  final distributor = distributors[index];
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                             ChangeNotifierProvider(
                                                create: (_) => DistStockProvider(
                                                    dioClient:
                                                    DioClient())
                                                  ..fetchDistStock(
                                                    request:
                                                    DistStockRequest(
                                                      exportType: "1",
                                                      locationId:
                                                      distributor.id,
                                                    ),
                                                  ),
                                                child: StockDetailsScreen(
                                                  title: distributor.name ??
                                                      "Stock Details",
                                                ),
                                              ),
                                        ),
                                      );
                                    },
                                    borderRadius:
                                    BorderRadius.circular(12),
                                    child: _buildCard(
                                        distributor.name,
                                        distributor.phone),
                                  );
                                },
                              ),
                              // Retailers Tab
                              retailers.isEmpty
                                  ? const Center(
                                  child: AutoTranslateText(
                                      "No retailers found"))
                                  : ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: retailers.length,
                                itemBuilder: (context, index) {
                                  final retailer = retailers[index];
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ChangeNotifierProvider(
                                                create: (_) => DistStockProvider(
                                                    dioClient:
                                                    DioClient())
                                                  ..fetchDistStock(
                                                    request:
                                                    DistStockRequest(
                                                      exportType: "3",
                                                      locationId:
                                                      retailer.id,
                                                    ),
                                                  ),
                                                child: StockDetailsScreen(
                                                  title: retailer.name ??
                                                      "Stock Details",
                                                ),
                                              ),
                                        ),
                                      );
                                    },
                                    borderRadius:
                                    BorderRadius.circular(12),
                                    child: _buildCard(
                                        retailer.name, retailer.phone),
                                  );
                                },
                              ),
                              // CNF/VFS Stocks Tab
                              cfaProvider.loading
                                  ? const Center(
                                  child: CircularProgressIndicator())
                                  : cfaProvider.error != null
                                  ? Center(
                                child: AutoTranslateText(
                                  cfaProvider.error!,
                                  style: const TextStyle(
                                      color: Colors.black),
                                ),
                              )
                                  : cfaProvider.stockData.isEmpty
                                  ? const Center(
                                  child: Text(
                                      "No CNF stocks found"))
                                  : ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount:
                                cfaProvider.stockData.length,
                                itemBuilder: (context, index) {
                                  final vfsStock =
                                  cfaProvider.stockData[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 6),
                                    child: Padding(
                                      padding:
                                      const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          // Location Name Heading
                                          Text(
                                            "Location Name: ${vfsStock.locationName}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),

                                          const SizedBox(height: 8),
                                          // Column Headers
                                          Container(
                                            padding: const EdgeInsets
                                                .symmetric(
                                                vertical: 8,
                                                horizontal: 8),
                                            decoration: BoxDecoration(
                                              color: Colors
                                                  .blueGrey.shade100,
                                              borderRadius:
                                              BorderRadius.circular(
                                                  12),
                                            ),
                                            child: Row(
                                              children: const [
                                                Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                        "Product",
                                                        style: TextStyle(
                                                            fontWeight:
                                                            FontWeight
                                                                .bold))),
                                                Expanded(
                                                    flex: 1,
                                                    child: Text("Pack",
                                                        style: TextStyle(
                                                            fontWeight:
                                                            FontWeight.bold))),
                                                Expanded(
                                                    flex: 1,
                                                    child: Text("Bin",
                                                        style: TextStyle(
                                                            fontWeight:
                                                            FontWeight.bold))),
                                                Expanded(
                                                    flex: 1,
                                                    child: Text("Qty",
                                                        style: TextStyle(
                                                            fontWeight:
                                                            FontWeight.bold))),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          // Stocks List
                                          ...vfsStock.stocks.map((stock) {
                                            return Container(
                                              margin:
                                              const EdgeInsets.symmetric(
                                                  vertical: 2),
                                              padding:
                                              const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color:
                                                Colors.blueGrey.shade50,
                                                borderRadius:
                                                BorderRadius.circular(
                                                    12),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      flex: 2,
                                                      child: Text(stock
                                                          .product
                                                          ?.name ??
                                                          "")),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                          stock.packagingLevel)),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Text(stock
                                                          .bin
                                                          ?.name ??
                                                          "")),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4,
                                                          horizontal: 6),
                                                      decoration: BoxDecoration(
                                                        color: (stock.qty ??
                                                            0) >
                                                            4
                                                            ? Colors.green
                                                            .withOpacity(0.2)
                                                            : Colors.red
                                                            .withOpacity(0.2),
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                      ),
                                                      child: Text(
                                                        (stock.qty ?? 0)
                                                            .toString(),
                                                        textAlign:
                                                        TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          color: (stock.qty ??
                                                              0) >
                                                              4
                                                              ? Colors.green
                                                              : Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _initProvider(TerritoryProvider provider, String? tsiId) async {
    final roleId = await SharedPrefsHelper.getRoleId();
    final userId = await SharedPrefsHelper.getUserId();

    if (userId != null && userId.isNotEmpty) {
      if (roleId == 19 && tsiId != null && tsiId.isNotEmpty) {
        await provider.fetchDistributors(tsiId);
        await provider.fetchRetailers(tsiId);
      } else {
        await provider.fetchDistributors(userId);
        await provider.fetchRetailers(userId ?? "");
      }
    }
  }

  Widget _buildCard(String? name, String? phone) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name ?? "",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(phone ?? "",
              style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        ],
      ),
    );
  }
}
