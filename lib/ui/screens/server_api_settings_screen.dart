import 'package:flutter/material.dart';
import 'package:mealique/data/local/token_storage.dart';
import 'package:mealique/ui/screens/login_screen.dart';

class ServerApiSettingsScreen extends StatefulWidget {
  const ServerApiSettingsScreen({super.key});

  @override
  State<ServerApiSettingsScreen> createState() => _ServerApiSettingsScreenState();
}

class _ServerApiSettingsScreenState extends State<ServerApiSettingsScreen> {
  final TokenStorage _tokenStorage = TokenStorage();
  String? _serverUrl;

  @override
  void initState() {
    super.initState();
    _loadServerUrl();
  }

  Future<void> _loadServerUrl() async {
    final url = await _tokenStorage.getServerUrl();
    if (mounted) {
      setState(() {
        _serverUrl = url;
      });
    }
  }

  Future<void> _logout() async {
    await _tokenStorage.deleteToken();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Server & API'), // TODO: l10n
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: const Text('Server URL'),
            subtitle: Text(_serverUrl ?? 'Lade...'),
            leading: const Icon(Icons.dns),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
