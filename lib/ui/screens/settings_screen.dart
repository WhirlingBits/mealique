import 'package:flutter/material.dart';
import 'package:mealique/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mealique/ui/screens/appearance_settings_screen.dart';
import 'package:mealique/ui/screens/notification_settings_screen.dart';
import 'package:mealique/ui/screens/server_api_settings_screen.dart';
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
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = '${info.version} (${info.buildNumber})';
      });
    }
  }

  Future<void> _loadUser() async {
    final user = await _userRepository.getSelfUser();
    if (mounted) {
      setState(() {
        _user = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE58325),
        foregroundColor: Colors.white,
        title: Text(l10n.settings),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            // Header: Profil & Server Info
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFFE58325).withValues(alpha: 0.15),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/mealique.png',
                        width: 56,
                        height: 56,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _user?.fullName ?? l10n.loadingUser,
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
              title: Text(l10n.serverAndApi),
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

            // Menüpunkt: Darstellung & Sprache
            ListTile(
              leading: const Icon(Icons.palette),
              title: Text(l10n.appearanceAndLanguage),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppearanceSettingsScreen(),
                  ),
                );
              },
            ),

            // Menüpunkt: Benachrichtigungen
            ListTile(
              leading: const Icon(Icons.notifications),
              title: Text(l10n.notifications),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationSettingsScreen(),
                  ),
                );
              },
            ),

            // Menüpunkt: Sync
            ListTile(
              leading: const Icon(Icons.sync),
              title: Text(l10n.sync),
              onTap: () {
                // TODO: Sync auslösen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.syncStarted)),
                );
              },
            ),

            const Divider(height: 1),

            // App-Version
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  '${l10n.appVersion}: $_appVersion',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
