import 'package:flutter/services.dart';

class MaxAmountInputFormatter extends TextInputFormatter {
  final int maxValue;

  MaxAmountInputFormatter(this.maxValue);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isEmpty) return newValue;

    final value = int.tryParse(newValue.text) ?? 0;

    if (value > maxValue) {
      return oldValue; // prevent typing after limit reached
    }

    return newValue;
  }
}
