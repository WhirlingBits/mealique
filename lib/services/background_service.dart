import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart' as wm;
import 'package:mealique/data/local/sync_queue_storage.dart';
import 'package:mealique/services/sync_service.dart';

/// Task identifiers for Workmanager.
class BackgroundTasks {
  static const String syncQueue = 'de.mealique.task.sync_queue';
  static const String periodicSync = 'de.mealique.task.periodic_sync';
  static const String mealReminder = 'de.mealique.task.meal_reminder';
}

/// Top-level callback dispatcher for Workmanager.
/// MUST be a top-level function, not a class method.
@pragma('vm:entry-point')
void callbackDispatcher() {
  wm.Workmanager().executeTask((task, inputData) async {
    debugPrint('BackgroundService: Executing task "$task"');

    try {
      switch (task) {
        case BackgroundTasks.syncQueue:
        case BackgroundTasks.periodicSync:
        case wm.Workmanager.iOSBackgroundTask:
          // Process the offline sync queue
          final syncService = SyncService();
          final synced = await syncService.processQueue();
          debugPrint('BackgroundService: Synced $synced operations');
          return true;

        case BackgroundTasks.mealReminder:
          // Handle meal reminder notification
          // This is triggered by a scheduled notification, not Workmanager
          return true;

        default:
          debugPrint('BackgroundService: Unknown task "$task"');
          return true;
      }
    } catch (e) {
      debugPrint('BackgroundService: Error executing task "$task": $e');
      return false; // Will retry later
    }
  });
}

/// Service that manages background task scheduling using Workmanager.
class BackgroundService {
  BackgroundService._();
  static final BackgroundService instance = BackgroundService._();

  bool _isInitialized = false;

  /// Initialize the background service. Call once at app startup.
  Future<void> initialize() async {
    if (_isInitialized) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;

    await wm.Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );

    _isInitialized = true;
    debugPrint('BackgroundService: Initialized');

    // Register periodic sync task
    await _registerPeriodicSync();
  }

  /// Registers a periodic task that runs every 15 minutes (minimum on Android).
  Future<void> _registerPeriodicSync() async {
    if (!_isInitialized) return;

    if (Platform.isAndroid) {
      await wm.Workmanager().registerPeriodicTask(
        BackgroundTasks.periodicSync,
        BackgroundTasks.periodicSync,
        frequency: const Duration(minutes: 15),
        constraints: wm.Constraints(
          networkType: wm.NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
        existingWorkPolicy: wm.ExistingPeriodicWorkPolicy.keep,
        backoffPolicy: wm.BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(minutes: 1),
      );
      debugPrint('BackgroundService: Registered periodic sync task (Android)');
    } else if (Platform.isIOS) {
      // iOS uses different background fetch mechanism
      await wm.Workmanager().registerPeriodicTask(
        BackgroundTasks.periodicSync,
        BackgroundTasks.periodicSync,
        frequency: const Duration(minutes: 15),
        constraints: wm.Constraints(
          networkType: wm.NetworkType.connected,
        ),
      );
      debugPrint('BackgroundService: Registered periodic sync task (iOS)');
    }
  }

  /// Schedules an immediate one-time sync task.
  /// Useful when the app goes to background with pending changes.
  Future<void> scheduleSyncNow() async {
    if (!_isInitialized) return;

    // Check if there are pending operations
    final queue = SyncQueueStorage();
    final count = await queue.count();
    if (count == 0) return;

    debugPrint('BackgroundService: Scheduling immediate sync for $count pending ops');

    await wm.Workmanager().registerOneOffTask(
      '${BackgroundTasks.syncQueue}_${DateTime.now().millisecondsSinceEpoch}',
      BackgroundTasks.syncQueue,
      constraints: wm.Constraints(
        networkType: wm.NetworkType.connected,
      ),
      existingWorkPolicy: wm.ExistingWorkPolicy.replace,
      backoffPolicy: wm.BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(seconds: 30),
    );
  }

  /// Cancels all background tasks (e.g., on logout).
  Future<void> cancelAllTasks() async {
    if (!_isInitialized) return;
    await wm.Workmanager().cancelAll();
    debugPrint('BackgroundService: Cancelled all tasks');
  }

  /// Cancels a specific task by unique name.
  Future<void> cancelTask(String uniqueName) async {
    if (!_isInitialized) return;
    await wm.Workmanager().cancelByUniqueName(uniqueName);
    debugPrint('BackgroundService: Cancelled task "$uniqueName"');
  }
}
