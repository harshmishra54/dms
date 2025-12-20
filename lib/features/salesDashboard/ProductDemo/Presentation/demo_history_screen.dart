import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/demo_history_model.dart';
import 'package:TrustTags_DMS/features/salesDashboard/ProductDemo/provider/demo_history_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/ProductDemo/provider/complete_demo_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:TrustTags_DMS/common/app_colors.dart';

class DemoHistoryScreen extends StatefulWidget {
  const DemoHistoryScreen({super.key});

  @override
  State<DemoHistoryScreen> createState() => _DemoHistoryScreenState();
}

class _DemoHistoryScreenState extends State<DemoHistoryScreen>
    with SingleTickerProviderStateMixin {
  String? _userId;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _loadUserId();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final userId = await SharedPrefsHelper.getUserId();
    if (!mounted) return;
    setState(() => _userId = userId);

    if (_userId != null && _userId!.isNotEmpty) {
      context.read<DemoHistoryProvider>().fetchDemoHistory(
        request: DemoHistoryRequest(userId: _userId!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          const AppStatusBar(),
          Material(
            elevation: 3,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Demo History',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: Consumer2<DemoHistoryProvider, CompleteDemoProvider>(
              builder: (context, historyProvider, completeProvider, _) {
                if (_userId == null || historyProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Do not show error in red, just show nothing if error
                if (historyProvider.errorMessage != null) {
                  return const Center(child: SizedBox.shrink());
                }

                final list = historyProvider.demoHistoryList;
                if (list.isEmpty) return const Center(child: Text("No demo history found"));

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    final parsed = _parseDemoMessage(item.data?.message ?? '');
                    final followUpStr = parsed['followUp'] ?? '';
                    final followUpDate = _parseFollowUpDate(followUpStr);
                    final bool isFollowUpPending =
                        followUpDate != null && DateTime.now().isBefore(followUpDate.add(const Duration(days: 1)));

                    return Material(
                      color: Colors.transparent,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: isFollowUpPending ? Colors.orange[50] : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: isFollowUpPending
                              ? Border.all(color: Colors.orange, width: 2)
                              : Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Demo Meeting",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isFollowUpPending ? Colors.orange[800] : Colors.black87,
                                    ),
                                  ),
                                  if (item.createdAt != null)
                                    Text(
                                      _formatDate(item.createdAt!),
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Product
                              if (parsed['product']!.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(Icons.science, size: 16, color: Colors.teal),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        parsed['product']!,
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 6),

                              // Address
                              if (parsed['address']!.isNotEmpty)
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _openMap(parsed['latitude']!, parsed['longitude']!),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.location_on, size: 16, color:AppColors.topBarColor),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            parsed['address']!,
                                            style: const TextStyle(
                                                color: AppColors.topBarColor,
                                                decoration: TextDecoration.underline,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 6),

                              // Demo Date
                              if (parsed['demoDate']!.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(Icons.event, size: 16, color: Colors.blue),
                                    const SizedBox(width: 6),
                                    Text(parsed['demoDate']!),
                                  ],
                                ),
                              const SizedBox(height: 6),

                              // Next Follow-up
                              if (followUpStr.isNotEmpty)
                                Row(
                                  children: [
                                    Icon(Icons.repeat, size: 16, color: isFollowUpPending ? Colors.orange : Colors.grey),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Follow-up: $followUpStr",
                                      style: TextStyle(
                                        fontWeight: isFollowUpPending ? FontWeight.bold : FontWeight.normal,
                                        color: isFollowUpPending ? Colors.orange[800] : Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 8),

                              // Description
                              if (parsed['description']!.isNotEmpty)
                                Text(
                                  parsed['description']!,
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              const SizedBox(height: 12),

                              // Status & Complete Button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Status Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: item.isActive! ? Colors.green[50] : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      item.isActive! ? "Active" : "Completed",
                                      style: TextStyle(
                                        color: item.isActive! ? Colors.green[800] : Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),

                                  // Complete Button
                                  if (item.isActive == true)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        backgroundColor: Colors.teal,
                                      ),
                                      onPressed: completeProvider.isLoading
                                          ? null
                                          : () async {
                                        if (item.id != null) {
                                          await completeProvider.completeDemo(item.id!);
                                          await historyProvider.fetchDemoHistory(
                                              request: DemoHistoryRequest(userId: _userId!));
                                        }
                                      },
                                      child: completeProvider.isLoading
                                          ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                          : const Text("Complete"),
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
    );
  }

  String _formatDate(DateTime date) => DateFormat('dd-MM-yyyy').format(date);

  void _openMap(String lat, String lng) {
    if (lat.isEmpty || lng.isEmpty) return;
    final url = "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Map<String, String> _parseDemoMessage(String message) {
    String extract(String start, String end) {
      final startIndex = message.indexOf(start);
      if (startIndex == -1) return '';
      final endIndex = message.indexOf(end, startIndex + start.length);
      if (endIndex == -1) {
        return message.substring(startIndex + start.length).trim();
      }
      return message.substring(startIndex + start.length, endIndex).trim();
    }

    return {
      "address": extract("📍 *Resolved Address*:\n", "\n\n🌐"),
      "latitude": extract("Latitude: ", "\n"),
      "longitude": extract("Longitude: ", "\n\n🧪"),
      "product": extract("🧪 *Product*:\n", "\n\n📅"),
      "demoDate": extract("📅 *Demo Date*:\n", "\n\n📝"),
      "description": extract("📝 *Description*:\n", "\n\n📆"),
      "followUp": extract("📆 *Next Follow-up*:\n", "\n").trim(),
    };
  }

  DateTime? _parseFollowUpDate(String dateStr) {
    try {
      return DateFormat('dd-MM-yyyy').parse(dateStr);
    } catch (_) {
      return null;
    }
  }
}
