import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/data/models/update_leave_model.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Leave/provider/update_leave_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Leave/provider/my_leave_list_provider.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';

class MyLeaveScreen extends StatefulWidget {
  const MyLeaveScreen({super.key});

  @override
  State<MyLeaveScreen> createState() => _MyLeaveScreenState();
}

class _MyLeaveScreenState extends State<MyLeaveScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<MyLeaveProvider>(context, listen: false).fetchMyLeaves();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UpdateLeaveStatusProvider()),
      ],
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Column(
          children: [
            const AppStatusBar(),

            /// App Bar
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
                        'Leave Approval',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),

            /// Main Content
            Expanded(
              child: Consumer<MyLeaveProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.errorMessage != null) {
                    return Center(
                      child: AutoTranslateText(provider.errorMessage!),
                    );
                  }

                  if (provider.leaves.isEmpty) {
                    return const Center(
                      child: AutoTranslateText("No leaves found"),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: provider.leaves.length,
                    itemBuilder: (context, index) {
                      final leave = provider.leaves[index];

                      return Card(
                        color: Colors.white,
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Reason + Status
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: AutoTranslateText(
                                      "Reason: ${leave.reason}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(leave.status),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: AutoTranslateText(
                                      leave.status,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              /// Requested By
                              AutoTranslateText(
                                "Requested by: ${leave.userName}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 4),

                              /// Date Range
                              AutoTranslateText(
                                "${leave.startDate} → ${leave.endDate}",
                                style: const TextStyle(color: Colors.grey),
                              ),

                              const SizedBox(height: 12),

                              /// Approve / Reject Buttons
                              if (leave.status.toLowerCase() == "pending")
                                Consumer<UpdateLeaveStatusProvider>(
                                  builder: (context, updateProvider, _) {
                                    return Row(
                                      children: [
                                        OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                                color: Colors.green),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(20),
                                            ),
                                          ),
                                          onPressed:
                                          updateProvider.isLoading
                                              ? null
                                              : () => _updateStatus(
                                            "Accepted",
                                            leave.id,
                                            provider,
                                            updateProvider,
                                          ),
                                          child: updateProvider.isLoading
                                              ? const SizedBox(
                                            width: 16,
                                            height: 14,
                                            child:
                                            CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                              : const AutoTranslateText(
                                            "Approve",
                                            style: TextStyle(
                                                color: Colors.green),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                                color: Colors.red),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(20),
                                            ),
                                          ),
                                          onPressed:
                                          updateProvider.isLoading
                                              ? null
                                              : () => _updateStatus(
                                            "Rejected",
                                            leave.id,
                                            provider,
                                            updateProvider,
                                          ),
                                          child: updateProvider.isLoading
                                              ? const SizedBox(
                                            width: 16,
                                            height: 14,
                                            child:
                                            CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                              : const AutoTranslateText(
                                            "Reject",
                                            style: TextStyle(
                                                color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
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
    );
  }

  /// Update Leave Status
  Future<void> _updateStatus(
      String status,
      String leaveId,
      MyLeaveProvider myLeaveProvider,
      UpdateLeaveStatusProvider updateProvider,
      ) async {
    final request = UpdateLeaveStatusRequest(
      id: leaveId,
      status: status,
    );

    await updateProvider.updateLeaveStatus(request);

    if (updateProvider.response?.success == 1) {
      myLeaveProvider.fetchMyLeaves();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
          AutoTranslateText("Leave ${status.toLowerCase()} successfully"),
        ),
      );
    } else if (updateProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AutoTranslateText(updateProvider.errorMessage!),
        ),
      );
    }
  }

  /// Status Color Helper
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "accepted":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "rejected":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
