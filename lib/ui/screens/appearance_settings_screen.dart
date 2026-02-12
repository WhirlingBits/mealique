import 'package:flutter/material.dart';
import 'package:mealique/l10n/app_localizations.dart';
import 'package:mealique/providers/settings_provider.dart';
import 'package:mealique/ui/screens/language_settings_screen.dart';
import 'package:provider/provider.dart';

class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Darstellung & Sprache'), // TODO: l10n
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // --- Theme Section ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'DARSTELLUNG', // TODO: l10n
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Heller Modus'), // TODO: l10n
            value: ThemeMode.light,
            groupValue: settings.themeMode,
            onChanged: (mode) => settings.setThemeMode(mode!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dunkler Modus'), // TODO: l10n
            value: ThemeMode.dark,
            groupValue: settings.themeMode,
            onChanged: (mode) => settings.setThemeMode(mode!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Systemeinstellung verwenden'), // TODO: l10n
            value: ThemeMode.system,
            groupValue: settings.themeMode,
            onChanged: (mode) => settings.setThemeMode(mode!),
          ),
          const Divider(height: 24),

          // --- Language Section ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'SPRACHE', // TODO: l10n
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ListTile(
            title: const Text('App-Sprache'), // TODO: l10n
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  (settings.locale?.languageCode == 'de') ? 'Deutsch' : 'English',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LanguageSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
