import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/data/models/repeat_beat_plan.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/beat_plan_doctor_details_screen.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/add_beat_plan_doctor_screen.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/get_beat_plan_doctor_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/repeat_plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  /// Date Picker for Re-Plan
  Future<DateTime?> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    return await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.purple,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final repeatProvider = context.watch<RepeatPlanProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      floatingActionButton: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 25.0),
          child: FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddBeatPlanDoctorScreen()),
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
      body: Stack(
        children: [
          Column(
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

              // ✅ Beat Plan Cards List
              Expanded(
                child: Consumer<GetBeatPlanDoctorProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: Colors.purple));
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
                        child:
                        AutoTranslateText("No beat plan doctor data found"),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: provider.refreshBeatPlanDoctor,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final beatPlan = data[index];
                          final farmers = beatPlan.farmers ?? [];
                          final farmerCount = farmers.length;
                          final status = beatPlan.status ?? 'Unknown';
                          final statusColor = _getStatusColor(status);

                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            splashColor: Colors.purple.withOpacity(0.1),
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      BeatPlanDoctorDetailsScreen(
                                        date: beatPlan.date ?? '',
                                        routeName: beatPlan.routeName ?? '',
                                        farmers: farmers,
                                        routeId: beatPlan.id ?? '',
                                        routeStatus:
                                        beatPlan.status ?? 'Pending',
                                      ),
                                  transitionsBuilder: (_, animation, __, child) {
                                    return SlideTransition(
                                      position: Tween(
                                        begin: const Offset(1, 0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12.withOpacity(0.05),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.route,
                                        color: Colors.purple, size: 28),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          AutoTranslateText(
                                            beatPlan.routeName ??
                                                'No Route Name',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.calendar_today,
                                                  size: 14,
                                                  color: Colors.purple),
                                              const SizedBox(width: 4),
                                              Text(
                                                beatPlan.date ?? '',
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.black54),
                                              ),
                                              const SizedBox(width: 10),
                                              const Icon(Icons.people,
                                                  size: 14,
                                                  color: Colors.purple),
                                              const SizedBox(width: 4),
                                              Text(
                                                "$farmerCount Farmers",
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.black54),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // ✅ Status + Re-Plan
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color:
                                            statusColor.withOpacity(0.1),
                                            borderRadius:
                                            BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            status,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: statusColor,
                                            ),
                                          ),
                                        ),
                                        if (status.toLowerCase() ==
                                            'completed') ...[
                                          const SizedBox(height: 8),
                                          GestureDetector(
                                            onTap: () async {
                                              final selectedDate =
                                              await _selectDate(context);
                                              if (selectedDate == null) return;

                                              final formattedDate =
                                              DateFormat('yyyy-MM-dd')
                                                  .format(selectedDate);

                                              final req = RepeatPlanRequest(
                                                planId: beatPlan.id ?? '',
                                                newDate: formattedDate,
                                              );

                                              final success =
                                              await repeatProvider
                                                  .repeatPlan(
                                                  request: req);

                                              if (success) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        "✅ Beat plan repeated successfully!"),
                                                    backgroundColor:
                                                    Colors.green,
                                                  ),
                                                );
                                                context
                                                    .read<
                                                    GetBeatPlanDoctorProvider>()
                                                    .fetchBeatPlanDoctor();
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      repeatProvider
                                                          .errorMessage ??
                                                          "Failed to repeat beat plan.",
                                                    ),
                                                    backgroundColor:
                                                    Colors.redAccent,
                                                  ),
                                                );
                                              }
                                            },
                                            child: Container(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                  color:
                                                  Colors.grey.shade300,
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                mainAxisSize:
                                                MainAxisSize.min,
                                                children: const [
                                                  // Icon(Icons.refresh,
                                                  //     size: 14,
                                                  //     color: Colors.black),
                                                  // SizedBox(width: 4),
                                                  // Text(
                                                  //   "Re-Plan",
                                                  //   style: TextStyle(
                                                  //     fontSize: 12,
                                                  //     color: Colors.black,
                                                  //     fontWeight:
                                                  //     FontWeight.w600,
                                                  //   ),
                                                  // ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
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

          // ✅ Loader overlay when repeat plan API is running
          if (repeatProvider.isLoading)
            Container(
              color: Colors.black.withOpacity(0.25),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.purple),
              ),
            ),
        ],
      ),
    );
  }
}
