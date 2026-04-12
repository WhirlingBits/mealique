import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mealique/data/remote/dio_client.dart';
import 'package:mealique/l10n/app_localizations.dart';
import 'package:mealique/providers/settings_provider.dart';
import 'package:mealique/services/background_service.dart';
import 'package:mealique/services/notification_service.dart';
import 'package:mealique/ui/screens/auth_check_screen.dart';
import 'package:mealique/ui/screens/login_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-load settings before building the widget tree to avoid
  // unnecessary rebuilds and frame drops on startup.
  final settingsProvider = SettingsProvider();
  await settingsProvider.init();

  // Initialize background services and notifications
  await _initializeServices(settingsProvider);

  runApp(MyApp(settingsProvider: settingsProvider));
}

/// Initialize background services for sync and notifications.
Future<void> _initializeServices(SettingsProvider settings) async {
  // Initialize background task manager (Workmanager)
  await BackgroundService.instance.initialize();

  // Initialize local notifications
  await NotificationService.instance.initialize();

  // Restore scheduled notifications from saved settings
  // Note: We use German defaults here since the app context is not available yet
  // The proper titles will be set when user interacts with notification settings
  await NotificationService.instance.restoreScheduledNotifications(
    notificationsEnabled: settings.notificationsEnabled,
    breakfastEnabled: settings.breakfastReminderEnabled,
    lunchEnabled: settings.lunchReminderEnabled,
    dinnerEnabled: settings.dinnerReminderEnabled,
    breakfastTime: settings.breakfastTime,
    lunchTime: settings.lunchTime,
    dinnerTime: settings.dinnerTime,
    breakfastTitle: 'Zeit für das Frühstück!',
    lunchTitle: 'Zeit für das Mittagessen!',
    dinnerTitle: 'Zeit für das Abendessen!',
    body: 'Schau in deinen Essensplan, was heute auf dem Speiseplan steht.',
  );
}

class MyApp extends StatelessWidget {
  final SettingsProvider settingsProvider;

  const MyApp({super.key, required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: settingsProvider,
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Mealie',
            navigatorKey: navigatorKey,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: settings.themeMode,
            locale: settings.locale,
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              // If the user has already chosen a language, use that.
              if (settings.locale != null) {
                return settings.locale;
              }
              // Otherwise, determine the initial locale based on the device's language.
              if (deviceLocale != null) {
                for (var supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == deviceLocale.languageCode) {
                    // If device language is German, use it.
                    if (deviceLocale.languageCode == 'de') {
                      return supportedLocale;
                    }
                  }
                }
              }
              // If the device language is not German or not supported, default to English.
              return supportedLocales.firstWhere((l) => l.languageCode == 'en');
            },
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            routes: {
              '/login': (context) => const LoginScreen(),
            },
            home: const AuthCheckScreen(),
          );
        },
      ),
    );
  }
}
