import 'package:flutter/material.dart';
import 'package:mealique/l10n/app_localizations.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale;

  // Default system language or fallback to English
  LocaleProvider() : _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!AppLocalizations.supportedLocales.contains(locale)) return;
    _locale = locale;
    notifyListeners();
  }
}
