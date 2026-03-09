import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mealique/data/remote/api_exceptions.dart';

/// Generic helper that implements the offline-first pattern:
/// 1. Try the API call
/// 2. On success, cache the result locally
/// 3. On network failure, return cached data
///
/// Returns a record with the data and whether it came from cache.
Future<({T data, bool fromCache})> withOfflineFallback<T>({
  required Future<T> Function() apiCall,
  required Future<T?> Function() cacheRead,
  Future<void> Function(T data)? cacheWrite,
}) async {
  try {
    final result = await apiCall();
    // Cache the result in the background
    if (cacheWrite != null) {
      try {
        await cacheWrite(result);
        debugPrint('Offline cache write succeeded for ${T.toString()}');
      } catch (e) {
        debugPrint('Offline cache write failed for ${T.toString()}: $e');
      }
    }
    return (data: result, fromCache: false);
  } on DioException catch (e) {
    if (_isNetworkError(e)) {
      debugPrint('DioException network error, falling back to cache for ${T.toString()}: ${e.type} / ${e.error}');
      final cached = await _tryReadCache(cacheRead);
      if (cached != null) {
        return (data: cached, fromCache: true);
      }
    }
    rethrow;
  } on NetworkException catch (e) {
    debugPrint('NetworkException, falling back to cache for ${T.toString()}: $e');
    final cached = await _tryReadCache(cacheRead);
    if (cached != null) {
      return (data: cached, fromCache: true);
    }
    rethrow;
  } catch (e) {
    // Catch-all for other connectivity errors (SocketException, HttpException, etc.)
    if (_isLikelyNetworkError(e)) {
      debugPrint('Likely network error ($e), falling back to cache for ${T.toString()}');
      final cached = await _tryReadCache(cacheRead);
      if (cached != null) {
        return (data: cached, fromCache: true);
      }
    }
    rethrow;
  }
}

/// Simplified version that just returns the data (no fromCache flag).
Future<T> withOfflineFallbackSimple<T>({
  required Future<T> Function() apiCall,
  required Future<T?> Function() cacheRead,
  Future<void> Function(T data)? cacheWrite,
}) async {
  final result = await withOfflineFallback(
    apiCall: apiCall,
    cacheRead: cacheRead,
    cacheWrite: cacheWrite,
  );
  return result.data;
}

/// Safely try to read from cache, swallowing any cache errors.
Future<T?> _tryReadCache<T>(Future<T?> Function() cacheRead) async {
  try {
    final cached = await cacheRead();
    if (cached != null) {
      debugPrint('Cache hit for ${T.toString()}');
    } else {
      debugPrint('Cache miss (null) for ${T.toString()}');
    }
    return cached;
  } catch (e) {
    debugPrint('Cache read error: $e');
    return null;
  }
}

/// Checks whether a DioException represents a network connectivity issue.
bool _isNetworkError(DioException e) {
  // Check if our custom ErrorInterceptor wrapped it as a NetworkException
  if (e.error is NetworkException) return true;

  // Also check raw Dio exception types that indicate connectivity issues
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.unknown:
    case DioExceptionType.connectionError:
      return true;
    default:
      return false;
  }
}

/// Heuristic check for non-Dio exceptions that likely indicate network issues.
bool _isLikelyNetworkError(Object e) {
  final msg = e.toString().toLowerCase();
  return msg.contains('socket') ||
      msg.contains('connection') ||
      msg.contains('network') ||
      msg.contains('timeout') ||
      msg.contains('unreachable') ||
      msg.contains('no address') ||
      msg.contains('errno') ||
      msg.contains('failed host lookup') ||
      msg.contains('xmlhttprequest');
}

/// Helper for write operations (create/update/delete) that should
/// apply changes locally when offline, so the UI stays responsive.
///
/// If [enqueue] is provided it will be called after [localWrite] so the
/// operation is persisted in the sync queue and can be replayed when the
/// device is back online.
///
/// Returns `true` if the operation was applied only locally (offline),
/// `false` if it was successfully sent to the API.
/// Throws if it's a non-network error.
Future<bool> withOfflineWriteFallback({
  required Future<void> Function() apiCall,
  required Future<void> Function() localWrite,
  Future<void> Function()? enqueue,
}) async {
  try {
    await apiCall();
    // Also update local cache to keep it in sync
    try {
      await localWrite();
    } catch (e) {
      debugPrint('Local write after API success failed: $e');
    }
    return false; // not offline
  } on DioException catch (e) {
    if (_isNetworkError(e)) {
      debugPrint('Offline write fallback: applying locally');
      await localWrite();
      await _tryEnqueue(enqueue);
      return true; // applied offline
    }
    rethrow;
  } on NetworkException {
    debugPrint('Offline write fallback (NetworkException): applying locally');
    await localWrite();
    await _tryEnqueue(enqueue);
    return true;
  } catch (e) {
    if (_isLikelyNetworkError(e)) {
      debugPrint('Offline write fallback (likely network): applying locally');
      await localWrite();
      await _tryEnqueue(enqueue);
      return true;
    }
    rethrow;
  }
}

/// Safely call the enqueue callback, swallowing errors so they never
/// prevent the local-write fallback from succeeding.
Future<void> _tryEnqueue(Future<void> Function()? enqueue) async {
  if (enqueue == null) return;
  try {
    await enqueue();
  } catch (e) {
    debugPrint('SyncQueue enqueue failed: $e');
  }
}

