import 'package:TrustTags_DMS/data/models/rout_list_response.dart';
import 'package:TrustTags_DMS/data/repositories/rout_repository.dart';
import 'package:flutter/material.dart';

class RoutProvider extends ChangeNotifier {
  final RoutRepository repository;

  RoutProvider(this.repository);

  bool isLoading = false;
  List<TsiRoute> routes = [];
  String error = '';

  Future<void> loadRoutes(String token, String tsmId) async {
    try {
      isLoading = true;
      error = '';
      notifyListeners();

      // Debug print
      print('🔐 Token: $token');
      print('🆔 TSM ID: $tsmId');

      if (token.isEmpty || tsmId.isEmpty) {
        error = 'Token or TSM ID is empty';
        print('❌ Token or TSM ID is empty');
        return;
      }

      final data = await repository.fetchRoutes(token: token, tsmId: tsmId);
      routes = data.data;
      print('✅ Routes fetched: ${routes.length}');
    } catch (e) {
      error = e.toString();
      print('❌ Error loading routes: $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
