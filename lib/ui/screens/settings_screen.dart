import 'package:flutter/material.dart';
import 'package:mealique/l10n/app_localizations.dart';
import 'package:mealique/providers/settings_provider.dart';
import 'package:mealique/ui/screens/server_api_settings_screen.dart';
import 'package:provider/provider.dart';
import '../../data/sync/user_repository.dart';
import '../../models/user_self_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserRepository _userRepository = UserRepository();

  UserSelf? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _userRepository.getSelfUser();
    if (mounted) {
      setState(() {
        _user = user;
      });
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final provider = Provider.of<SettingsProvider>(context, listen: false);
        return AlertDialog(
          title: const Text('Sprache auswählen'), // TODO: l10n
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppLocalizations.supportedLocales.map((locale) {
              return RadioListTile<Locale>(
                title: Text(locale.languageCode == 'de' ? 'Deutsch' : 'English'),
                value: locale,
                groupValue: provider.locale,
                onChanged: (newLocale) {
                  if (newLocale != null) {
                    provider.setLocale(newLocale);
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            // Header: Profil & Server Info
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _user?.fullName ?? 'Lade Benutzer...',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _user?.email ?? '',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Menüpunkt: Server & API
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Server & API'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ServerApiSettingsScreen(),
                  ),
                );
              },
            ),

            // Menüpunkt: Sprache
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Sprache'), // TODO: l10n
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: _showLanguageDialog,
            ),

            // Menüpunkt: Favoriten
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Favoriten'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                // TODO: Navigation zu Favoriten
              },
            ),

            // Menüpunkt: Dark Mode
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode),
              title: Text(l10n.darkMode),
              value: settings.themeMode == ThemeMode.dark,
              onChanged: (bool value) {
                final newMode = value ? ThemeMode.dark : ThemeMode.light;
                settings.setThemeMode(newMode);
              },
            ),

            // Menüpunkt: Sync
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Sync'),
              onTap: () {
                // TODO: Sync auslösen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Synchronisierung gestartet...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
