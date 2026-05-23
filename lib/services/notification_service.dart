import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

/// Notification channel IDs.
class NotificationChannels {
  static const String mealReminder = 'meal_reminder';
  static const String sync = 'sync_status';
  static const String general = 'general';
}

/// Notification IDs for specific notifications.
class NotificationIds {
  static const int breakfastReminder = 1001;
  static const int lunchReminder = 1002;
  static const int dinnerReminder = 1003;
  static const int syncComplete = 2001;
  static const int syncFailed = 2002;
}

/// Payload actions for notification taps.
class NotificationPayloads {
  static const String openPlanner = 'open_planner';
  static const String openShoppingList = 'open_shopping_list';
  static const String openRecipes = 'open_recipes';
}

/// Service that manages local notifications for meal reminders and sync status.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Callback for when a notification is tapped.
  void Function(String? payload)? onNotificationTapped;

  /// Initialize the notification service. Call once at app startup.
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone data for scheduled notifications
    tz_data.initializeTimeZones();
    
    // Set the local timezone based on the device's timezone
    await _configureLocalTimeZone();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationResponse,
    );

    // Create notification channels on Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }

    _isInitialized = true;
    debugPrint('NotificationService: Initialized');
  }

  /// Configures the local timezone based on the device's timezone.
  Future<void> _configureLocalTimeZone() async {
    try {
      final String timeZoneName = await _getDeviceTimeZone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('NotificationService: Timezone set to $timeZoneName');
    } catch (e) {
      debugPrint('NotificationService: Failed to get device timezone, using UTC: $e');
      tz.setLocalLocation(tz.UTC);
    }
  }

  /// Gets the device's timezone name.
  Future<String> _getDeviceTimeZone() async {
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        const channel = MethodChannel('flutter_local_notifications');
        final String? timeZone = await channel.invokeMethod<String>('getTimeZoneName');
        if (timeZone != null && timeZone.isNotEmpty) {
          return timeZone;
        }
      } catch (_) {}
    }
    
    final now = DateTime.now();
    final offset = now.timeZoneOffset;
    
    if (offset.inHours == 1) return 'Europe/Berlin';
    if (offset.inHours == 2) return 'Europe/Berlin';
    if (offset.inHours == 0) return 'Europe/London';
    if (offset.inHours == -5) return 'America/New_York';
    if (offset.inHours == -8) return 'America/Los_Angeles';
    
    return 'Europe/Berlin';
  }

  /// Creates Android notification channels.
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        NotificationChannels.mealReminder,
        'Mahlzeiten-Erinnerungen',
        description: 'Erinnerungen für geplante Mahlzeiten',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        NotificationChannels.sync,
        'Synchronisierung',
        description: 'Status der Datensynchronisierung',
        importance: Importance.low,
        enableVibration: false,
        playSound: false,
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        NotificationChannels.general,
        'Allgemein',
        description: 'Allgemeine App-Benachrichtigungen',
        importance: Importance.defaultImportance,
      ),
    );

    debugPrint('NotificationService: Created notification channels');
  }

  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('NotificationService: Notification tapped: ${response.payload}');
    onNotificationTapped?.call(response.payload);
  }

  /// Request notification permissions.
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }
    return true;
  }

  /// Check if notification permissions are granted.
  Future<bool> hasPermission() async {
    if (Platform.isAndroid) {
      return await Permission.notification.isGranted;
    } else if (Platform.isIOS) {
      final settings = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.checkPermissions();
      return settings?.isEnabled ?? false;
    }
    return true;
  }

  /// Schedule a meal reminder notification.
  Future<void> scheduleMealReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (!_isInitialized) return;

    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    if (tzScheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
      debugPrint('NotificationService: Skipping past notification');
      return;
    }

    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzScheduledTime,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationChannels.mealReminder,
          'Mahlzeiten-Erinnerungen',
          channelDescription: 'Erinnerungen für geplante Mahlzeiten',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFFE58325),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload ?? NotificationPayloads.openPlanner,
    );

    debugPrint('NotificationService: Scheduled meal reminder for $scheduledTime');
  }

  /// Schedule daily meal reminders at specific times.
  Future<void> scheduleDailyMealReminders({
    TimeOfDay? breakfastTime,
    TimeOfDay? lunchTime,
    TimeOfDay? dinnerTime,
    required String breakfastTitle,
    required String lunchTitle,
    required String dinnerTitle,
    required String body,
  }) async {
    if (!_isInitialized) return;

    await cancelDailyMealReminders();

    final now = tz.TZDateTime.now(tz.local);

    if (breakfastTime != null) {
      var scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day,
        breakfastTime.hour, breakfastTime.minute,
      );
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notifications.zonedSchedule(
        id: NotificationIds.breakfastReminder,
        title: breakfastTitle,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            NotificationChannels.mealReminder,
            'Mahlzeiten-Erinnerungen',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFFE58325),
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: NotificationPayloads.openPlanner,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }

    if (lunchTime != null) {
      var scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day,
        lunchTime.hour, lunchTime.minute,
      );
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notifications.zonedSchedule(
        id: NotificationIds.lunchReminder,
        title: lunchTitle,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            NotificationChannels.mealReminder,
            'Mahlzeiten-Erinnerungen',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFFE58325),
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: NotificationPayloads.openPlanner,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }

    if (dinnerTime != null) {
      var scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day,
        dinnerTime.hour, dinnerTime.minute,
      );
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _notifications.zonedSchedule(
        id: NotificationIds.dinnerReminder,
        title: dinnerTitle,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            NotificationChannels.mealReminder,
            'Mahlzeiten-Erinnerungen',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFFE58325),
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: NotificationPayloads.openPlanner,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }

    debugPrint('NotificationService: Scheduled daily meal reminders');
  }

  /// Cancel all daily meal reminders.
  Future<void> cancelDailyMealReminders() async {
    await _notifications.cancel(id: NotificationIds.breakfastReminder);
    await _notifications.cancel(id: NotificationIds.lunchReminder);
    await _notifications.cancel(id: NotificationIds.dinnerReminder);
    debugPrint('NotificationService: Cancelled daily meal reminders');
  }

  /// Show an immediate notification (e.g., sync complete).
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String channelId = NotificationChannels.general,
    String? payload,
  }) async {
    if (!_isInitialized) return;

    await _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId == NotificationChannels.sync ? 'Synchronisierung' : 'Allgemein',
          importance: channelId == NotificationChannels.sync
              ? Importance.low
              : Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFFE58325),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  /// Cancel a specific notification.
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id: id);
  }

  /// Cancel all notifications.
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('NotificationService: Cancelled all notifications');
  }

  /// Get pending notification requests (for debugging).
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Restore scheduled notifications from saved settings.
  Future<void> restoreScheduledNotifications({
    required bool notificationsEnabled,
    required bool breakfastEnabled,
    required bool lunchEnabled,
    required bool dinnerEnabled,
    required TimeOfDay breakfastTime,
    required TimeOfDay lunchTime,
    required TimeOfDay dinnerTime,
    required String breakfastTitle,
    required String lunchTitle,
    required String dinnerTitle,
    required String body,
  }) async {
    if (!_isInitialized) return;

    final hasPermissionGranted = await hasPermission();
    if (!hasPermissionGranted || !notificationsEnabled) {
      debugPrint('NotificationService: Skipping restore - notifications disabled or no permission');
      return;
    }

    final pending = await getPendingNotifications();
    final hasMealReminders = pending.any((n) =>
        n.id == NotificationIds.breakfastReminder ||
        n.id == NotificationIds.lunchReminder ||
        n.id == NotificationIds.dinnerReminder);

    if (hasMealReminders) {
      debugPrint('NotificationService: Meal reminders already scheduled');
      return;
    }

    await scheduleDailyMealReminders(
      breakfastTime: breakfastEnabled ? breakfastTime : null,
      lunchTime: lunchEnabled ? lunchTime : null,
      dinnerTime: dinnerEnabled ? dinnerTime : null,
      breakfastTitle: breakfastTitle,
      lunchTitle: lunchTitle,
      dinnerTitle: dinnerTitle,
      body: body,
    );

    debugPrint('NotificationService: Restored scheduled notifications');
  }
}

/// Background notification response handler (must be top-level).
@pragma('vm:entry-point')
void _onBackgroundNotificationResponse(NotificationResponse response) {
  debugPrint('NotificationService: Background notification: ${response.payload}');
}
