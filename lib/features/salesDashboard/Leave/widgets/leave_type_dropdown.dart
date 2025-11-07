import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';
import '../../../../common/app_colors.dart'; // Adjust this if your path differs

class LeaveTypeDropdown extends StatelessWidget {
  final String? selectedLeaveType;
  final Function(String?) onChanged;

  const LeaveTypeDropdown({
    super.key,
    required this.selectedLeaveType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final leaveTypes = ['Sick Leave', 'Casual Leave', 'Earned Leave', 'Other'];

    return SizedBox(
      width: double.infinity,
      child: DropdownButtonFormField<String>(
        value: selectedLeaveType,
        isExpanded: true,
        decoration: InputDecoration(
          hintText: 'Please select leave type',
          hintStyle: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16), // Increased vertical padding
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        icon: const Icon(Icons.arrow_drop_down),
        dropdownColor: Colors.white,
        style: const TextStyle(fontSize: 14, color: Colors.black),
        items: leaveTypes.map((type) {
          return DropdownMenuItem<String>(
            value: type,
            child: AutoTranslateText(type),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
