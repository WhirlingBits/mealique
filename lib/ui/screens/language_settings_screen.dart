import 'package:flutter/material.dart';
import 'package:mealique/l10n/app_localizations.dart';
import 'package:mealique/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final currentLocale = settings.locale ?? Localizations.localeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sprache auswählen'), // TODO: l10n
      ),
      body: ListView(
        children: AppLocalizations.supportedLocales.map((locale) {
          final isSelected = currentLocale.languageCode == locale.languageCode;
          return ListTile(
            title: Text(locale.languageCode == 'de' ? 'Deutsch' : 'English'),
            trailing: isSelected
                ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                : null,
            onTap: () {
              settings.setLocale(locale);
              // Automatically pop back after selection
              Navigator.of(context).pop();
            },
          );
        }).toList(),
      ),
    );
  }
}
