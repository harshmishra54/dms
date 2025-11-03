import 'package:TrustTags_DMS/features/dashboard/distributor_home_navigation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/features/dashboard/widgets/credit_limit_update.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/credit_limit_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/credit_limit_history_provider.dart';
import 'package:TrustTags_DMS/data/models/credit_limit_response.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:intl/intl.dart';

class CreditLimit extends StatefulWidget {
  const CreditLimit({super.key});

  @override
  State<CreditLimit> createState() => _CreditLimitState();
}

class _CreditLimitState extends State<CreditLimit> {
  final String _roleId = "1";

  final NumberFormat _formatter = NumberFormat.currency(
    locale: "en_IN",
    symbol: "₹",
    decimalDigits: 0,
  );

  String formatAmount(dynamic value) {
    if (value == null) return "₹0";
    final double? numValue = double.tryParse(value.toString());
    if (numValue == null) return "₹0";
    return _formatter.format(numValue);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<CreditLimitProvider>(context, listen: false)
          .fetchCreditLimitList(roleId: _roleId);
      _fetchCreditHistory();
    });
  }

  Future<void> _fetchCreditHistory() async {
    final userId = await SharedPrefsHelper.getUserId();
    final token = await SharedPrefsHelper.getAccessToken();

    if (userId != null && token != null) {
      final requestBody = {'user_id': userId};
      Provider.of<CreditLimitHistoryProvider>(context, listen: false)
          .fetchCreditHistory(requestBody, token: token);
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
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DistributorHomeNavigation(),
                        ),
                      );
                    },
                  ),
                ),
                const Center(
                  child: Text(
                    'Credit Limit',
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

          // ✅ Top static part + scrollable history
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Credit Request Card (Static)
                Consumer<CreditLimitProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (provider.creditList.isEmpty) {
                      return const Center(child: Text('No credit data found.'));
                    }

                    final CreditListDataResponse data = provider.creditList.first;

                    Color statusColor;
                    switch (data.status?.toLowerCase()) {
                      case "pending":
                        statusColor = Colors.yellow[700]!;
                        break;
                      case "rejected":
                        statusColor = Colors.red;
                        break;
                      case "approved":
                      case "fully approved":
                      case "partially approved":
                        statusColor = Colors.green;
                        break;
                      default:
                        statusColor = Colors.black;
                    }

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Credit Request",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Current Limit: ${formatAmount(data.currentLimit)}",
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Requested: ${formatAmount(data.requestedLimit)}",
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              "Approved: ${formatAmount(data.approvedLimit)}",
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text(
                                  "Status: ",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Flexible(
                                  child: Text(
                                    data.status ?? "N/A",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: statusColor,
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

                // History Heading (Static)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Text(
                    "Credit Limit History",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Scrollable History List
                Expanded(
                  child: Consumer<CreditLimitHistoryProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (provider.errorMessage != null) {
                        return Center(
                          child: Text(
                            provider.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }
                      if (provider.creditHistory.isEmpty) {
                        return const Center(child: Text("No history found."));
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        itemCount: provider.creditHistory.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = provider.creditHistory[index];
                          return Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${item.changeType} - ${formatAmount(item.changeAmount)}",
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(item.description),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('dd MMM yyyy').format(item.createdAt),
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
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
          ),
        ],
      ),
      floatingActionButton: SafeArea(
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CreditLimitUpdateScreen(),
              ),
            );

            if (result == true) {
              // Refresh both request and history
              Provider.of<CreditLimitProvider>(context, listen: false)
                  .fetchCreditLimitList(roleId: _roleId);
              _fetchCreditHistory();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Credit limit request submitted successfully"),
                ),
              );
            }
          },
          backgroundColor: const Color(0xFFA259FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add, size: 30, color: Colors.white),
        ),
      ),
    );
  }
}
