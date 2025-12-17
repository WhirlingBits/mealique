import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'ui/screens/auth_check_screen.dart';
import 'providers/locale_provider.dart';

void main() {
  runApp(
    // The ChangeNotifierProvider encapsulates the app so that the state is available everywhere.
    ChangeNotifierProvider(
      create: (context) => LocaleProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Here we access the provider to obtain the current language.
    final provider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'Mealique',
      // The locale is set dynamically from the provider.
      locale: provider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Start with the AuthCheckScreen to check the login status.
      home: const AuthCheckScreen(),
    );
  }
}
