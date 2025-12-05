import 'dart:convert';
import 'dart:io';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/network/offline_cache_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/main.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import './api_endpoints.dart';

class DioClient {
  late Dio _dio;
  bool _isDialogShowing = false; // ✅ Added: Prevent multiple dialogs

  DioClient() {
    BaseOptions options = BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      responseType: ResponseType.json,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio = Dio(options);

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        request: true,
        requestBody: true,
        requestHeader: true,
        responseBody: true,
        responseHeader: false,
        error: true,
      ));
    }

    // ✅ Added: Global 401 interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) {
          debugPrint("🔥 Interceptor: Status ${error.response?.statusCode}");

          if (error.response?.statusCode == 401 && !_isDialogShowing) {
            debugPrint("🚨 401 Unauthorized - Showing dialog");
            _isDialogShowing = true;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _handleUnauthorized();
            });
          }

          handler.next(error);
        },
      ),
    );
  }

  Future<bool> _hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    debugPrint("📡 Connectivity result: $result");
    return result != ConnectivityResult.none;
  }

  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    final online = await _hasInternet();

    try {
      if (online) {
        final response = await _dio.get(path,
            queryParameters: queryParameters, options: options);
        await OfflineCacheService.cacheResponse(path, response.data);
        return response;
      } else {
        final cached = await OfflineCacheService.getCachedResponse(path);
        if (cached != null) {
          debugPrint("📴 Offline: Returning cached GET response for $path");
          return Response(
            requestOptions: RequestOptions(path: path),
            data: cached,
            statusCode: 200,
          );
        } else {
          throw Exception("No Internet and no cached data found.");
        }
      }
    } catch (e) {
      debugPrint("⚠️ Dio GET error: $e");
      final cached = await OfflineCacheService.getCachedResponse(path);
      if (cached != null) {
        debugPrint("♻️ Using cached GET data after Dio error");
        return Response(
          requestOptions: RequestOptions(path: path),
          data: cached,
          statusCode: 200,
        );
      }
      throw _handleError(e);
    }
  }

  Future<Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    final online = await _hasInternet();

    if (!online) {
      debugPrint("📴 No Internet — saving POST to pending queue: $path");
      await OfflineCacheService.savePendingRequest("POST", path, data);
      return Response(
        requestOptions: RequestOptions(path: path),
        data: {
          "message": "Saved offline. Will sync when online.",
          "offline": true,
        },
        statusCode: 200,
      );
    }

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options ??
            Options(
              headers: {
                "Content-Type": "application/json",
                "Accept": "application/json",
                "x-access-token": token ?? "",
              },
            ),
      );
      return response;
    } catch (e) {
      debugPrint("🚨 Dio POST failed for $path → $e");

      bool isOfflineError = false;

      if (e is DioException) {
        final msg = e.message ?? '';

        isOfflineError =
            e.type == DioExceptionType.connectionError ||
                e.type == DioExceptionType.unknown ||
                e.type == DioExceptionType.receiveTimeout ||
                e.type == DioExceptionType.sendTimeout ||
                e.type == DioExceptionType.connectionTimeout ||
                e.error is SocketException ||
                e.error is HandshakeException ||
                (e.error is OSError &&
                    (msg.contains("Failed host lookup") ||
                        msg.contains("No address associated")));

        if (isOfflineError) {
          debugPrint("📶 Network/DNS failure detected — saving POST to queue: $path");
          await OfflineCacheService.savePendingRequest("POST", path, data);
          return Response(
            requestOptions: RequestOptions(path: path),
            data: {
              "message": "Saved offline (network issue). Will sync later.",
              "offline": true,
            },
            statusCode: 200,
          );
        }

        // ✅ Modified: Removed separate 401 handling (now handled by interceptor)
        if (e.response?.statusCode == 401) {
          throw Exception("Unauthorized. Please log in again.");
        }
      }

      if (!isOfflineError) {
        try {
          if (e is SocketException || e.toString().contains("SocketException")) {
            debugPrint("⚡ SocketException fallback — saving POST request: $path");
            await OfflineCacheService.savePendingRequest("POST", path, data);
            return Response(
              requestOptions: RequestOptions(path: path),
              data: {"message": "Saved offline (fallback)."},
              statusCode: 200,
            );
          }
        } catch (_) {}
      }

      debugPrint("🛑 Unknown error, still queueing POST request: $path");
      await OfflineCacheService.savePendingRequest("POST", path, data);
      return Response(
        requestOptions: RequestOptions(path: path),
        data: {"message": "Saved offline (safe fallback)."},
        statusCode: 200,
      );
    }
  }

  Future<Response> put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    final online = await _hasInternet();

    try {
      if (!online) {
        await OfflineCacheService.savePendingRequest("PUT", path, data);
        debugPrint("📴 Offline detected — queueing PUT request: $path");
        return Response(
          requestOptions: RequestOptions(path: path),
          data: {"message": "Saved offline. Will sync later.", "offline": true},
          statusCode: 200,
        );
      }

      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } catch (e) {
      if (e is DioException &&
          (e.error is SocketException ||
              e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.unknown)) {
        debugPrint("⚠️ Network error — saving PUT to pending: $path");
        await OfflineCacheService.savePendingRequest("PUT", path, data);
        return Response(
          requestOptions: RequestOptions(path: path),
          data: {"message": "Saved offline. Will sync later.", "offline": true},
          statusCode: 200,
        );
      }
      throw _handleError(e);
    }
  }

  Future<Response> delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
      }) async {
    final online = await _hasInternet();

    try {
      if (!online) {
        await OfflineCacheService.savePendingRequest("DELETE", path, data);
        debugPrint("📴 Offline detected — queueing DELETE request: $path");
        return Response(
          requestOptions: RequestOptions(path: path),
          data: {"message": "Saved offline. Will sync later.", "offline": true},
          statusCode: 200,
        );
      }

      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } catch (e) {
      if (e is DioException &&
          (e.error is SocketException ||
              e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.unknown)) {
        debugPrint("⚠️ Network error — saving DELETE to pending: $path");
        await OfflineCacheService.savePendingRequest("DELETE", path, data);
        return Response(
          requestOptions: RequestOptions(path: path),
          data: {"message": "Saved offline. Will sync later.", "offline": true},
          statusCode: 200,
        );
      }
      throw _handleError(e);
    }
  }

  String _handleError(dynamic e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return "The request timed out. Please try again later.";
      } else if (e.type == DioExceptionType.badResponse) {
        switch (e.response?.statusCode) {
          case 400:
            return "Bad request.";
          case 401:
          // ✅ Modified: Don't call _handleUnauthorized here (interceptor handles it)
            return "Unauthorized. Please login again.";
          case 403:
            return "Access forbidden.";
          case 404:
            return "Resource not found.";
          case 500:
            return "Server error.";
          default:
            return "Server error: ${e.response?.statusCode}.";
        }
      } else if (e.type == DioExceptionType.unknown) {
        return "No Internet connection.";
      }
      return "Unexpected error.";
    } else {
      return "Something went wrong.";
    }
  }

  Dio get client => _dio;

  void _handleUnauthorized() {
    final context = navigatorKey.currentContext;
    debugPrint("🔔 _handleUnauthorized - context: $context");

    if (context == null) {
      debugPrint("❌ Context is NULL!");
      _isDialogShowing = false;
      return;
    }

    if (!context.mounted) {
      debugPrint("❌ Context NOT MOUNTED!");
      _isDialogShowing = false;
      return;
    }

    debugPrint("✅ Showing session expired dialog");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text("Session Expired"),
          content: const Text("Your session has expired. Please login again."),
          actions: [
            TextButton(
              onPressed: () async {
                debugPrint("👆 OK pressed - clearing data");
                _isDialogShowing = false;
                Navigator.of(ctx).pop();
                await SharedPrefsHelper.clearAll();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                        (route) => false,
                  );
                }
              },
              child: const Text("OK"),
            ),
          ],
        ),
      ),
    );
  }
}