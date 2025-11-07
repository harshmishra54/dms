import 'package:flutter/material.dart';
import 'app_localization.dart';

class LocalizationProvider extends ChangeNotifier {
  String _currentLang = 'en';
  String get currentLang => _currentLang;

  Future<void> changeLanguage(String code) async {
    await AppLocalization().load(code);
    _currentLang = code;
    notifyListeners();
  }
}
