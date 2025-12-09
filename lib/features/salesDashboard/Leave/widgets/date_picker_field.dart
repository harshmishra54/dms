import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../../../common/app_colors.dart'; // Adjust path as needed

class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final String? halfDay; // "Morning" or "Evening"
  final Function(DateTime, String) onDateSelected;

  const DatePickerField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.halfDay,
    required this.onDateSelected,
  });

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2125),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.topBarColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Show half-day selection after picking date
      String? selectedHalfDay = await showDialog<String>(
        context: context,
        builder: (context) {
          String? tempValue = halfDay ?? 'Morning';
          return AlertDialog(
            title: const Text('Select Half Day'),
            content: SizedBox(
              width: 150,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8), // ✅ top margin
                  DropdownSearch<String>(
                    items: const ['Morning', 'Afternoon', 'Evening',],
                    selectedItem: tempValue,
                    onChanged: (v) => tempValue = v,
                    popupProps: PopupProps.menu(
                      showSearchBox: false,
                      constraints: const BoxConstraints(
                        maxHeight: 120,
                        minWidth: 150,
                      ),
                      menuProps: MenuProps(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Rounded popup
                        ),
                        elevation: 4,
                      ),
                      itemBuilder: (context, item, isSelected) {
                        return Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected ? Theme.of(context).primaryColor : Colors.black,
                            ),
                          ),
                        );
                      },
                    ),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12), // Rounded field
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, tempValue),
                child: const AutoTranslateText('OK'),
              ),
            ],
          );
        },
      );


      if (selectedHalfDay != null) {
        onDateSelected(picked, selectedHalfDay);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = selectedDate != null
        ? '${DateFormat('dd MMM yyyy').format(selectedDate!)}${halfDay != null ? ' ($halfDay)' : ''}'
        : 'Select date';

    return SizedBox(
      width: double.infinity,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _selectDate(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                dateText,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
