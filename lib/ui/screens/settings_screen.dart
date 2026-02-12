import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
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

            // Menüpunkt: Darstellung & Sprache
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Darstellung & Sprache'), // TODO: l10n
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
              title: const Text('Benachrichtigungen'), // TODO: l10n
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
