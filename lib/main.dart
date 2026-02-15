import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mealique/l10n/app_localizations.dart';
import 'package:mealique/providers/settings_provider.dart';
import 'package:mealique/ui/screens/auth_check_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Mealie',
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
            home: const AuthCheckScreen(),
          );
        },
      ),
    );
  }
}
