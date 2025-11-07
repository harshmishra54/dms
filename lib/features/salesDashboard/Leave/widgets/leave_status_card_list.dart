import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Leave/provider/leave_provider.dart';
import 'package:TrustTags_DMS/data/models/leave_management_response.dart';

class LeaveStatusCardList extends StatelessWidget {
  const LeaveStatusCardList({super.key});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) return 'Invalid Date';
    try {
      final date = DateTime.parse(rawDate);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LeaveProvider>(
      builder: (context, leaveProvider, _) {
        final List<LeaveManagementData> list = leaveProvider.leaveList;

        if (leaveProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (list.isEmpty) {
          return const Center(child: AutoTranslateText('No leave history found.'));
        }

        return SizedBox(
          height: 150,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.96),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final leave = list[index];
                final color = _getStatusColor(leave.status);

                final formattedStartDate = _formatDate(leave.startDate);
                final formattedEndDate = _formatDate(leave.endDate);

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: AutoTranslateText(
                            leave.status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoTranslateText(
                            'Leave Type: ${leave.leaveType}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 10),
                          AutoTranslateText('From: $formattedStartDate', style: const TextStyle(fontSize: 14)),
                          AutoTranslateText('To:   $formattedEndDate', style: const TextStyle(fontSize: 14)),
                          AutoTranslateText('Reason: ${leave.reason}', style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
