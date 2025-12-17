import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mealique/l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      children: [
        // Language Selection
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(l10n.language),
          subtitle: Text(l10n.selectLanguage),
          onTap: () {
            _showLanguageDialog(context, l10n);
          },
        ),
        const Divider(),

        // Dark Mode
        SwitchListTile(
          secondary: const Icon(Icons.dark_mode),
          title: Text(l10n.darkMode),
          subtitle: Text(l10n.enableDarkMode),
          value: false, // TODO: Mit echtem State verbinden (z.B. ThemeProvider)
          onChanged: (bool value) {
            // TODO: Logik zum Umschalten des Themes
          },
        ),
        const Divider(),

        // Benachrichtigungen
        ListTile(
          leading: const Icon(Icons.notifications),
          title: Text(l10n.notifications),
          subtitle: Text(l10n.notificationSettings),
          onTap: () {
            // TODO: Navigieren zu Detail-Einstellungen
          },
        ),
        const Divider(),

        // Über die App
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(l10n.about),
          subtitle: Text('${l10n.version} 1.0.0'),
          onTap: () {
            // TODO: Dialog oder Lizenzseite anzeigen
          },
        ),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return SimpleDialog(
          title: Text(l10n.selectLanguage),
          children: AppLocalizations.supportedLocales.map((Locale locale) {
            return SimpleDialogOption(
              onPressed: () {
                // Hier wird die Sprache global über den Provider geändert
                context.read<LocaleProvider>().setLocale(locale);

                // Dialog schließen
                Navigator.pop(dialogContext);
              },
              child: Text(_getLanguageName(locale.languageCode)),
            );
          }).toList(),
        );
      },
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'de':
        return 'Deutsch';
      case 'en':
        return 'English';
      default:
        return code.toUpperCase();
    }
  }
}