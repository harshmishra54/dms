import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Leave/provider/leave_calender_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';


class LeaveStatusCalendar extends StatefulWidget {
  const LeaveStatusCalendar({super.key});

  @override
  State<LeaveStatusCalendar> createState() => _LeaveStatusCalendarState();
}

class _LeaveStatusCalendarState extends State<LeaveStatusCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, String> leaveStatuses = {};
  Map<DateTime, String> festivals = {}; // Optional if you want static holidays

  @override
  void initState() {
    super.initState();
    _fetchLeaveCalendar();
  }

  Future<void> _fetchLeaveCalendar() async {
    final userId = await SharedPrefsHelper.getUserId();
    if (userId == null) return;

    final provider = Provider.of<LeaveCalendarProvider>(context, listen: false);
    await provider.fetchLeaveCalendar(userId: userId);

    if (provider.leaveCalendar != null) {
      setState(() {
        leaveStatuses = {
          for (var leave in provider.leaveCalendar!.data)
            DateTime.utc(
              leave.holidayDate.year,
              leave.holidayDate.month,
              leave.holidayDate.day,
            ): leave.holidayName,
        };
      });
    }
  }

  Color _getStatusColor(DateTime day) {
    if (festivals.containsKey(day)) return Colors.red;
    if (leaveStatuses.containsKey(day)) {
      // You can map leave name/type to status colors if needed
      return Colors.green;
    }
    if (day.weekday == DateTime.sunday) return Colors.red;
    return Colors.transparent;
  }

  String? _getTooltip(DateTime day) {
    if (festivals.containsKey(day)) return festivals[day];
    if (leaveStatuses.containsKey(day)) return leaveStatuses[day];
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LeaveCalendarProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          return Center(child: Text(provider.errorMessage!));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              firstDay: DateTime.utc(1900, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              sixWeekMonthsEnforced: true,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });

                final tooltip = _getTooltip(selectedDay);
                if (tooltip != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$tooltip on ${selectedDay.day}-${selectedDay.month}-${selectedDay.year}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final color = _getStatusColor(day);
                  return _buildDay(day, color);
                },
                selectedBuilder: (context, day, focusedDay) {
                  final color = _getStatusColor(day);
                  return _buildDay(day, color, isSelected: true);
                },
                todayBuilder: (context, day, focusedDay) {
                  final color = _getStatusColor(day);
                  return _buildDay(day, color, isToday: true);
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        );
      },
    );
  }

  Widget _buildDay(DateTime day, Color color, {bool isSelected = false, bool isToday = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: color != Colors.transparent
            ? LinearGradient(
          colors: [color.withOpacity(0.7), color.withOpacity(0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        border: isSelected
            ? Border.all(color: Colors.black, width: 2)
            : isToday
            ? Border.all(color: Colors.blueAccent, width: 2)
            : null,
        boxShadow: isSelected
            ? [BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(2, 2))]
            : isToday
            ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 8, spreadRadius: 1)]
            : [],
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: color == Colors.transparent ? Colors.black : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _LegendDot(color: Colors.green, label: 'Leave'),
          _LegendDot(color: Colors.red, label: 'Festival'),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
