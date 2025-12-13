import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
// Importiere den neuen AuthCheckScreen
import 'ui/screens/auth_check_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mealique',
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
