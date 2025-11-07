import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/beat_plan_doctor_details_screen.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/add_beat_plan_doctor_screen.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/get_beat_plan_doctor_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BeatPlanDoctorScreen extends StatefulWidget {
  const BeatPlanDoctorScreen({super.key});

  @override
  State<BeatPlanDoctorScreen> createState() => _BeatPlanDoctorScreenState();
}

class _BeatPlanDoctorScreenState extends State<BeatPlanDoctorScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<GetBeatPlanDoctorProvider>().fetchBeatPlanDoctor();
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 25.0),
          child: FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddBeatPlanDoctorScreen()),
              );
              if (result == true) {
                context.read<GetBeatPlanDoctorProvider>().fetchBeatPlanDoctor();
              }
            },
            backgroundColor: Colors.purple,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),
      body: Column(
        children: [
          const AppStatusBar(),

          // ✅ Custom AppBar
          Material(
            elevation: 2,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: AutoTranslateText(
                      'Beat Plan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // ✅ Beat Plan Cards
          Expanded(
            child: Consumer<GetBeatPlanDoctorProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null) {
                  return Center(
                    child: AutoTranslateText(
                      provider.errorMessage!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.redAccent,
                      ),
                    ),
                  );
                }

                final data = provider.beatPlanDoctorResponse?.data;
                if (data == null || data.isEmpty) {
                  return const Center(
                    child: AutoTranslateText("No beat plan doctor data found"),
                  );
                }

                return RefreshIndicator(
                  onRefresh: provider.refreshBeatPlanDoctor,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final beatPlan = data[index];
                      final farmers = beatPlan.farmers ?? [];
                      final farmerCount = farmers.length;
                      final status = beatPlan.status ?? 'Unknown';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BeatPlanDoctorDetailsScreen(
                                date: beatPlan.date ?? '',
                                routeName: beatPlan.routeName ?? '',
                                farmers: farmers,
                                routeId: beatPlan.id ?? '',
                                routeStatus: beatPlan.status ?? 'Pending',
                              ),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          color: const Color(0xFFF8F3FF),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.route,
                                    color: Colors.purple, size: 30),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AutoTranslateText(
                                        beatPlan.routeName ?? 'No Route Name',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today,
                                              size: 14, color: Colors.purple),
                                          const SizedBox(width: 4),
                                          AutoTranslateText(
                                            beatPlan.date ?? '',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // ✅ Status Badge (Global Status)
                                Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(status)
                                            .withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: AutoTranslateText(
                                        status,
                                        style: TextStyle(
                                          color: _getStatusColor(status),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: AutoTranslateText(
                                        "$farmerCount Farmers",
                                        style: const TextStyle(
                                          color: Colors.purple,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
