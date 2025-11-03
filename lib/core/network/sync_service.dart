import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'offline_cache_service.dart';
import 'dio_client.dart';

class SyncService {

  static Future<void> syncPendingRequests() async {
    if (!await hasInternet()) return;

    final requests = await OfflineCacheService.getPendingRequests();
    final dioClient = DioClient();

    for (final req in requests) {
      try {
        switch (req.method) {
          case "POST":
            await dioClient.post(req.endpoint, data: jsonDecode(req.body ?? '{}'));
            break;
          case "PUT":
            await dioClient.put(req.endpoint, data: jsonDecode(req.body ?? '{}'));
            break;
          case "DELETE":
            await dioClient.delete(req.endpoint, data: jsonDecode(req.body ?? '{}'));
            break;
        }
        await OfflineCacheService.deletePendingRequest(req.id);
      } catch (_) {
        // keep it in queue if still failing
      }
    }
  }
}
Future<bool> hasInternet() async {
  final connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}
