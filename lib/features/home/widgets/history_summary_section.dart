import 'package:TrustTags_DMS/features/points/providers/scheme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../common/app_colors.dart';

class HistorySummarySection extends StatefulWidget {
  const HistorySummarySection({super.key});

  @override
  State<HistorySummarySection> createState() => _HistorySummarySectionState();
}

class _HistorySummarySectionState extends State<HistorySummarySection> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    // Fetch schemes when widget is built
    Future.microtask(() {
      final provider = Provider.of<SchemeProvider>(context, listen: false);
      provider.fetchSchemes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SchemeProvider>(
      builder: (context, schemeProvider, _) {
        if (schemeProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final schemes = schemeProvider.schemes;

        if (schemes.isEmpty) {
          return const Center(child: Text("No scheme data found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: schemes.length,
          itemBuilder: (context, index) {
            final scheme = schemes[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                children: [
                  // Scheme header
                  GestureDetector(
                    onTap: () => schemeProvider.toggleExpand(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              scheme.schemeImage,
                              height: 24,
                              width: 24,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // fallback if image fails
                                return Image.asset(
                                  "assets/images/trust_tags.png",
                                  height: 24,
                                  width: 24,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              scheme.schemeName ?? "-",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Icon(
                            (scheme.isExpanded ?? false)
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: AppColors.primaryPurple,
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (scheme.isExpanded ?? false)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Column(
                        children: [
                          const Divider(),

                          // Table header
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: const [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    "Product",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                    child: Text("Lvl",
                                        style: TextStyle(fontWeight: FontWeight.bold))),
                                Expanded(
                                    child: Text("Points",
                                        style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                            ),
                          ),
                          const Divider(height: 1),

                          // Products list
                          ...?scheme.products?.map((brand) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 6),
                                  child: Text(
                                    brand.displayName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                ...brand.levels.map((level) {
                                  return Padding(
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        const Spacer(flex: 3),
                                        Expanded(child: Text(level.level)),
                                        Expanded(child: Text(level.totalPoints.toString())),

                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
