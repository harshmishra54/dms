import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimePickerField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;

  const DateTimePickerField({
    Key? key,
    required this.controller,
    this.labelText = '',
    this.hintText = 'Tap to select date and time',
  }) : super(key: key);

  @override
  State<DateTimePickerField> createState() => _DateTimePickerFieldState();
}

class _DateTimePickerFieldState extends State<DateTimePickerField> {
  DateTime? selectedDateTime;

  // Format: Aug 12, 2025 04:04:49 PM
  final DateFormat formatter = DateFormat('MMM dd, yyyy hh:mm:ss a');

  // Define the input border consistent with your other fields
  final OutlineInputBorder inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(6),
    borderSide: const BorderSide(color: Colors.grey),
  );

  Future<void> _pickDateTime() async {
    DateTime now = DateTime.now();

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select Meeting Date',
    );

    if (date == null) return; // User canceled

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: selectedDateTime != null
          ? TimeOfDay(hour: selectedDateTime!.hour, minute: selectedDateTime!.minute)
          : TimeOfDay.now(),
      helpText: 'Select Meeting Time',
    );

    if (time == null) return; // User canceled

    final selectedDateTimeFinal = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      selectedDateTime = selectedDateTimeFinal;
      widget.controller.text = formatter.format(selectedDateTimeFinal);
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller.text.isNotEmpty) {
      try {
        selectedDateTime = formatter.parse(widget.controller.text);
      } catch (_) {
        selectedDateTime = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      readOnly: true,
      onTap: _pickDateTime,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        suffixIcon: const Icon(Icons.calendar_today),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: Colors.grey),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true, // optional: makes the field a bit more compact
      ),
    );
  }
}
