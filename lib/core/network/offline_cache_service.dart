import 'package:TrustTags_DMS/core/model/cached_response.dart';
import 'package:TrustTags_DMS/core/model/pending_request.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:dio/dio.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';


class OfflineCacheService {
  static Isar? _isar;

  // ---------------------------------------------------------------------------
  // ✅ INIT ISAR (Singleton)
  // ---------------------------------------------------------------------------
  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar ??= await Isar.open(
      [PendingRequestSchema, CachedResponseSchema],
      directory: dir.path,
    );
  }

  // ---------------------------------------------------------------------------
  // ✅ CACHE GET API RESPONSES
  // ---------------------------------------------------------------------------
  static Future<void> cacheResponse(String endpoint, dynamic data) async {
    await init();
    await _isar!.writeTxn(() async {
      final existing = await _isar!.cachedResponses
          .filter()
          .endpointEqualTo(endpoint)
          .findFirst();

      final response = existing ?? CachedResponse()..endpoint = endpoint;
      response.data = jsonEncode(data);
      response.updatedAt = DateTime.now();

      await _isar!.cachedResponses.put(response);
    });
  }

  static Future<dynamic> getCachedResponse(String endpoint) async {
    await init();
    final result = await _isar!.cachedResponses
        .filter()
        .endpointEqualTo(endpoint)
        .findFirst();

    return result != null ? jsonDecode(result.data!) : null;
  }

  // ---------------------------------------------------------------------------
  // ✅ SAVE OFFLINE REQUEST (POST / PUT / DELETE)
  // ---------------------------------------------------------------------------
  static Future<void> savePendingRequest(
      String method,
      String endpoint,
      dynamic body,
      ) async {
    await init();

    final token = await SharedPrefsHelper.getAccessToken();

    final request = PendingRequest()
      ..method = method
      ..endpoint = endpoint
      ..body = body != null ? jsonEncode(body) : null
      ..token = token
      ..createdAt = DateTime.now();

    await _isar!.writeTxn(() async {
      await _isar!.pendingRequests.put(request);
    });

    debugPrint("💾 Saved pending request: $method $endpoint | token attached: ${token != null}");
  }

  static Future<List<PendingRequest>> getPendingRequests() async {
    await init();
    return await _isar!.pendingRequests.where().findAll();
  }

  static Future<void> deletePendingRequest(int id) async {
    await init();
    await _isar!.writeTxn(() async {
      await _isar!.pendingRequests.delete(id);
    });
  }

  // ---------------------------------------------------------------------------
  // ✅ RETRY / SYNC PENDING REQUESTS (WHEN ONLINE)
  // ---------------------------------------------------------------------------
  static Future<void> syncPendingRequests(Dio dio) async {
    await init();

    final pendingList = await _isar!.pendingRequests.where().findAll();
    if (pendingList.isEmpty) {
      debugPrint("✅ No pending requests to sync.");
      return;
    }

    final latestToken = await SharedPrefsHelper.getAccessToken();

    debugPrint("🌐 Syncing ${pendingList.length} pending requests with token: ${latestToken != null}");

    for (final req in pendingList) {
      try {
        final effectiveToken = latestToken ?? req.token ?? '';
        final headers = {
          "x-access-token": effectiveToken,
          "Content-Type": "application/json",
          "Accept": "application/json",
        };

        final data = req.body != null ? jsonDecode(req.body!) : null;

        debugPrint("📤 Retrying ${req.method} ${req.endpoint} with token: ${effectiveToken.isNotEmpty}");

        Response response;
        switch (req.method.toUpperCase()) {
          case "POST":
            response = await dio.post(req.endpoint!, data: data, options: Options(headers: headers));
            break;
          case "PUT":
            response = await dio.put(req.endpoint!, data: data, options: Options(headers: headers));
            break;
          case "DELETE":
            response = await dio.delete(req.endpoint!, data: data, options: Options(headers: headers));
            break;
          default:
            debugPrint("⚠️ Skipping unsupported method: ${req.method}");
            continue;
        }

        if (response.statusCode == 200 || response.statusCode == 201) {
          await _isar!.writeTxn(() async {
            await _isar!.pendingRequests.delete(req.id);
          });
          debugPrint("✅ Synced successfully → ${req.endpoint}");
        } else {
          debugPrint("⚠️ Failed (non-200) → ${req.endpoint} (${response.statusCode})");
        }
      } catch (e) {
        debugPrint("❌ Error syncing ${req.endpoint}: $e");
      }
    }
  }
}
