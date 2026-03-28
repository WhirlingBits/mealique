import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mealique/data/local/household_storage.dart';
import 'package:mealique/data/local/recipe_storage.dart';
import 'package:mealique/data/local/token_storage.dart';
import 'package:mealique/services/sync_service.dart';
import 'package:mealique/ui/screens/login_screen.dart';
import '../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    // Confirm logout
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.confirmLogout),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.logout, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Clear all stored data; wrap each in try-catch so one failure
    // doesn't block the others or the navigation.
    try { await _tokenStorage.clearAll(); } catch (e) { debugPrint('Logout: clearAll token error: $e'); }
    try { await HouseholdStorage().clearAll(); } catch (e) { debugPrint('Logout: clearAll household error: $e'); }
    try { await RecipeStorage().clearAll(); } catch (e) { debugPrint('Logout: clearAll recipe error: $e'); }
    try { await SyncService().clearQueue(); } catch (e) { debugPrint('Logout: clearQueue error: $e'); }

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.serverAndApi),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: Text(l10n.serverUrl),
            subtitle: Text(_serverUrl ?? l10n.loading),
            leading: const Icon(Icons.dns),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              l10n.logout,
              style: const TextStyle(color: Colors.red),
            ),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
