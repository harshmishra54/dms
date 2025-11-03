// import 'package:TrustTags_DMS/features/points/providers/points_provider.dart';
// import 'package:TrustTags_DMS/features/points/providers/scheme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../common/app_colors.dart';
import '../widgets/history_points_section.dart';
import '../widgets/history_summary_section.dart';
import '../../../common/widgets/app_status_bar.dart';

class HistoryScreen extends StatefulWidget {
  final int initialTab;

  const HistoryScreen({super.key, this.initialTab = 0});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late int _selectedTab;

  final List<String> _tabs = ['Points', 'Summary'];

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;

    // if (_selectedTab == 0) {
    //   _fetchHistory();
    // } else {
    //   _fetchSchemes();
    // }
  }

  // Future<void> _fetchHistory() async {
  //   final provider = Provider.of<PointsProvider>(context, listen: false);
  //   await provider.fetchScanHistory("1900-01-01", "2100-12-31");
  // }

  // Future<void> _fetchSchemes() async {
  //   final schemeProvider = Provider.of<SchemeProvider>(context, listen: false);
  //   await schemeProvider.fetchSchemes();
  // }

  void _onTabSelected(int index) {
    setState(() {
      _selectedTab = index;
    });

    // if (index == 0) {
    //   _fetchHistory();
    // } else if (index == 1) {
    //   _fetchSchemes();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const AppStatusBar(),
            Material(
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: kToolbarHeight,
                alignment: Alignment.centerLeft,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "History",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Image.asset(
                      'assets/images/trust_tags.png',
                      height: 40,
                      width: 45,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final isSelected = _selectedTab == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _onTabSelected(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryPurple
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            _tabs[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            Expanded(
              child: _selectedTab == 0
                  ? const PointsSection()
                  : const HistorySummarySection(),
            ),
          ],
        ),
      ),
    );
  }
}
