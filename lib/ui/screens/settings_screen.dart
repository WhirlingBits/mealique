import 'package:flutter/material.dart';
import 'package:mealique/l10n/app_localizations.dart';
import '../../data/local/token_storage.dart';
import '../../data/sync/user_repository.dart';
import '../../models/user_self_model.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TokenStorage _tokenStorage = TokenStorage();
  final UserRepository _userRepository = UserRepository();

  UserSelf? _user;
  String? _serverUrl;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Parallel data fetching
    final results = await Future.wait<dynamic>([
      _tokenStorage.getServerUrl(),
      _userRepository.getSelfUser(),
    ]);

    final serverUrl = results[0] as String?;
    final user = results[1] as UserSelf?;

    if (mounted) {
      setState(() {
        _serverUrl = serverUrl?.replaceAll(RegExp(r'^https?://'), '');
        _user = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                    _serverUrl ?? 'Lade Server...',
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
                // TODO: Navigation zu Server Einstellungen
              },
            ),

            // Menüpunkt: Sprache
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Sprache'), // TODO: l10n
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                // TODO: Navigation zu Sprachauswahl-Dialog/Screen
              },
            ),

            // Menüpunkt: Notifications
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Notifications'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                // TODO: Navigation zu Notifications
              },
            ),

            // Menüpunkt: Dark Mode
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode),
              title: Text(l10n.darkMode),
              value: false, // TODO: Mit echtem State verbinden (z.B. ThemeProvider)
              onChanged: (bool value) {
                // TODO: Logik zum Umschalten des Themes
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

            const Divider(),

            // Menüpunkt: Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout', // TODO: l10n.logout verwenden
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                // Delete token on logout
                await _tokenStorage.deleteToken();

                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
