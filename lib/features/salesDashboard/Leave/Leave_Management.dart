import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Leave/provider/leave_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Leave/widgets/leave_status_card_list.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Leave/widgets/leave_status_calendar.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Leave/widgets/leave_type_dropdown.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Leave/widgets/date_picker_field.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Leave/widgets/reason_text_field.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Leave/widgets/apply_button.dart';
import 'package:TrustTags_DMS/data/models/leave_list_request.dart';
import 'package:TrustTags_DMS/data/models/leave_request_data.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  String? selectedLeaveType;
  DateTime? fromDate, toDate;
  final reasonController = TextEditingController();

  // New dropdown values
  String? startDay;
  String? endDay;

  final Map<String, int> leaveTypeMap = {
    'Sick Leave': 1,
    'Casual Leave': 2,
    'Earned Leave': 3,
  };

  @override
  void initState() {
    super.initState();
    _fetchLeaveList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LeaveProvider>();
      provider.addListener(() {
        final error = provider.error;
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              duration: const Duration(seconds: 1),
            ),
          );
          provider.clearError();
        }
      });
    });
  }

  Future<void> _fetchLeaveList() async {
    final roleId = await SharedPrefsHelper.getRoleId() ?? 0;
    final requestId = await SharedPrefsHelper.getUserId() ?? '';
    final token = await SharedPrefsHelper.getAccessToken() ?? '';

    if (token.isEmpty) return;

    final request = LeaveListRequest(roleId: roleId, requestId: requestId);
    await context.read<LeaveProvider>().fetchLeaveList(request, token: token);
  }

  Future<void> _submitLeave() async {
    if (selectedLeaveType == null || fromDate == null || toDate == null || reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (toDate!.isBefore(fromDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('To Date cannot be before From Date')),
      );
      return;
    }

    final token = await SharedPrefsHelper.getAccessToken() ?? '';
    final roleId = (await SharedPrefsHelper.getRoleId() ?? 0).toString();
    final requestId = await SharedPrefsHelper.getUserId() ?? '';

    // Only send date, no Morning/Evening
    final startDateString = fromDate!.toIso8601String().split("T").first; // "yyyy-MM-dd"
    final endDateString = toDate!.toIso8601String().split("T").first;

    final req = LeaveRequestData(
      startDate: startDateString,
      endDate: endDateString,
      roleId: roleId,
      requestId: requestId,
      reason: reasonController.text,
      leaveType: leaveTypeMap[selectedLeaveType!] ?? 0,
    );

    final resp = await context.read<LeaveProvider>().submitLeaveRequest(req, token: token);

    if (!mounted) return;

    if (resp != null && resp.success == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resp.message)),
      );
      await _fetchLeaveList();
      setState(() {
        selectedLeaveType = null;
        fromDate = null;
        toDate = null;
        reasonController.clear();
        startDay = null;
        endDay = null;
      });
    }
  }



  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeaveProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          const AppStatusBar(),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            height: 56,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'Leave Management',
                    style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Colors.black12),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LeaveTypeDropdown(
                    selectedLeaveType: selectedLeaveType,
                    onChanged: (v) => setState(() => selectedLeaveType = v),
                  ),
                  const SizedBox(height: 16),
                  DatePickerField(
                    label: 'From Date',
                    selectedDate: fromDate,
                    halfDay: startDay,
                    onDateSelected: (date, half) => setState(() {
                      fromDate = date;
                      startDay = half;
                    }),
                  ),
                  const SizedBox(height: 10,),

                  DatePickerField(
                    label: 'To Date',
                    selectedDate: toDate,
                    halfDay: endDay,
                    onDateSelected: (date, half) => setState(() {
                      toDate = date;
                      endDay = half;
                    }),
                  ),



                  // Two half-width searchable dropdowns

                  const SizedBox(height: 10),
                  ReasonTextField(controller: reasonController),
                  const SizedBox(height: 16),
                  ApplyButton(onPressed: _submitLeave),
                  const SizedBox(height: 24),
                  const LeaveStatusCalendar(),
                  const SizedBox(height: 16),
                  const Text(
                    'Leave Status',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const LeaveStatusCardList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
