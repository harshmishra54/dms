import 'package:flutter/material.dart';

class LoaderProvider extends ChangeNotifier {
  int _loadingCount = 0;

  bool get isLoading => _loadingCount > 0;

  void showLoader() {
    _loadingCount++;
    notifyListeners();
  }

  void hideLoader() {
    if (_loadingCount > 0) {
      _loadingCount--;
      notifyListeners();
    }
  }
}
