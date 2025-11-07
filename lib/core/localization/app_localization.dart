import 'dart:convert';
import 'package:flutter/services.dart';

class AppLocalization {
  static final AppLocalization _instance = AppLocalization._internal();
  factory AppLocalization() => _instance;
  AppLocalization._internal();

  Map<String, String> _localizedStrings = {};
  String currentLang = 'en';

  Future<void> load(String languageCode) async {
    final jsonString =
    await rootBundle.loadString('assets/translations/$languageCode.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    currentLang = languageCode;
  }

  String translate(String text) {
    // Try to find translation by value (reverse lookup)
    final entry = _localizedStrings.entries.firstWhere(
          (e) => e.value == text,
      orElse: () => const MapEntry('', ''),
    );
    if (entry.key.isNotEmpty) return _localizedStrings[entry.key]!;
    return text; // fallback
  }
}
