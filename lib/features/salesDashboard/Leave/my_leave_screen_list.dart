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
                      child: Text(
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
                    return Center(child: Text(provider.errorMessage!));
                  }

                  if (provider.leaves.isEmpty) {
                    return const Center(child: Text("No leaves found"));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: provider.leaves.length,
                    itemBuilder: (context, index) {
                      final leave = provider.leaves[index];
                      return Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Row: Reason + Status
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      leave.reason,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(leave.status),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      leave.status,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 4),
                              Text(
                                "${leave.startDate} → ${leave.endDate}\nTotal Days: ${leave.totalDays}",
                              ),
                              const SizedBox(height: 8),

                              /// Approve / Reject buttons
                              if (leave.status.toLowerCase() == "pending")
                                Consumer<UpdateLeaveStatusProvider>(
                                  builder: (context, updateProvider, _) {
                                    return Row(
                                      children: [
                                        OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: Colors.purple),
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                          onPressed: updateProvider.isLoading
                                              ? null
                                              : () => _updateStatus(
                                            "Accepted",
                                            leave.id, // ✅ leave.id is String
                                            provider,
                                            updateProvider,
                                          ),
                                          child: updateProvider.isLoading
                                              ? const SizedBox(
                                            width: 16,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              color: Colors.purple,
                                              strokeWidth: 2,
                                            ),
                                          )
                                              : const Text(
                                            "Approve",
                                            style: TextStyle(color: Colors.purple),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: Colors.purple),
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                          onPressed: updateProvider.isLoading
                                              ? null
                                              : () => _updateStatus(
                                            "Rejected",
                                            leave.id, // ✅ leave.id is String
                                            provider,
                                            updateProvider,
                                          ),
                                          child: updateProvider.isLoading
                                              ? const SizedBox(
                                            width: 16,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              color: Colors.purple,
                                              strokeWidth: 2,
                                            ),
                                          )
                                              : const Text(
                                            "Reject",
                                            style: TextStyle(color: Colors.purple),
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

  /// Update leave status using leaveId (String)
  void _updateStatus(
      String status,
      String leaveId, // ✅ String
      MyLeaveProvider myLeaveProvider,
      UpdateLeaveStatusProvider updateProvider,
      ) async {
    final request = UpdateLeaveStatusRequest(
      id: leaveId, // ✅ send as String
      status: status,
    );

    await updateProvider.updateLeaveStatus(request);

    if (updateProvider.response != null &&
        updateProvider.response!.success == 1) {
      myLeaveProvider.fetchMyLeaves();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Leave ${status.toLowerCase()} successfully")),
      );
    } else if (updateProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(updateProvider.errorMessage!)),
      );
    }
  }

  /// Helper for status colors
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
