import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/spinner_history_model.dart';
import 'package:TrustTags_DMS/features/spinner/presentation/spinner.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../provider/spinner_history_provider.dart';

class SpinnerHistoryScreen extends StatefulWidget {
  const SpinnerHistoryScreen({Key? key}) : super(key: key);

  @override
  State<SpinnerHistoryScreen> createState() => _SpinnerHistoryScreenState();
}

class _SpinnerHistoryScreenState extends State<SpinnerHistoryScreen> {
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserAndFetch();
  }

  Future<void> _loadUserAndFetch() async {
    final id = await SharedPrefsHelper.getUserId();
    if (id != null && id.isNotEmpty) {
      setState(() => userId = id);
      context.read<SpinnerHistoryProvider>().getSpinnerHistory(id);
    }
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "";
    return DateFormat("dd MMM yyyy").format(DateTime.parse(date));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SpinnerHistoryProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          const AppStatusBar(),

          /// ✅ Custom AppBar
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
                      'Spinner Rewards',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          Expanded(
            child: userId == null
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
              onRefresh: () => provider.getSpinnerHistory(userId!),
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.error.isNotEmpty
                  ? Center(child: Text(provider.error))
                  : provider.spinnerHistory.isEmpty
                  ? const Center(
                child: AutoTranslateText(
                  "No reward history found",
                  style: TextStyle(fontSize: 14),
                ),
              )

              /// ✅ Grid View 2 Cards In Row
                  : Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  itemCount: provider.spinnerHistory.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.82,
                  ),
                  itemBuilder: (context, index) {
                    final item =
                    provider.spinnerHistory[index];
                    return GestureDetector(
                      onTap: ()async {
                        if (item.isUsed == true) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: AutoTranslateText(
                                  "This reward is already used!"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SpinnerWidget(
                                spinnerId: item.id!,
                                segments: item.segments ?? [],
                              ),
                            ),
                          );

// ✅ Refresh API when coming back
                          if (userId != null) {
                            context.read<SpinnerHistoryProvider>().getSpinnerHistory(userId!);
                          }

                        }
                      },
                      child: _RewardCard(
                        item: item,
                        formatDate: formatDate,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ✅ Reward Card Styled Like Scratch Card
class _RewardCard extends StatelessWidget {
  final SpinnerHistoryData item;
  final String Function(String?) formatDate;

  const _RewardCard({required this.item, required this.formatDate});

  @override
  Widget build(BuildContext context) {
    bool used = item.isUsed == true;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: used
            ? LinearGradient(
            colors: [Colors.grey.shade400, Colors.grey.shade300])
            : const LinearGradient(colors: [Color(0xff4facfe), Color(0xff00f2fe)]),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 12,
            right: 12,
            child: Icon(
              used ? Icons.lock : Icons.star,
              color: Colors.white70,
              size: 22,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  used ? "USED" : "REWARD",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  "${item.points} POINTS",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Level: ${item.level ?? "-"}",
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Colors.white70, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      formatDate(item.createdAt),
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                  ],
                )
              ],
            ),
          ),

          /// ✅ Scratch CARD CUTOUT LOOK (Bottom Notch)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 18,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
