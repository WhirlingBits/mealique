import 'package:app_version_update/app_version_update.dart';
import 'package:flutter/material.dart';
import 'package:mealique/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mealique/ui/screens/appearance_settings_screen.dart';
import 'package:mealique/ui/screens/notification_settings_screen.dart';
import 'package:mealique/ui/screens/server_api_settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';
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
  String? _storeVersion;
  String? _storeUrl;
  bool _checkingUpdate = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadAppVersion();
    _checkForUpdate();
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

  Future<void> _checkForUpdate() async {
    setState(() => _checkingUpdate = true);
    try {
      final result = await AppVersionUpdate.checkForUpdates(
        playStoreId: 'de.mealique.app',
      );
      if (mounted) {
        setState(() {
          _storeVersion = result.canUpdate == true ? result.storeVersion : null;
          _storeUrl = result.canUpdate == true ? result.storeUrl : null;
          _checkingUpdate = false;
        });
      }
    } catch (e) {
      // App not yet available on the Play Store → skip for now
      debugPrint('Update check skipped: $e');
      if (mounted) {
        setState(() {
          _storeVersion = null;
          _storeUrl = null;
          _checkingUpdate = false;
        });
      }
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

            // App-Version & Update
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Column(
                children: [
                  Text(
                    '${l10n.appVersion}: $_appVersion',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                  if (_checkingUpdate)
                    const Padding(
                      padding: EdgeInsets.only(top: 12.0),
                      child: SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else if (_storeVersion != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE58325).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE58325).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.system_update, color: Color(0xFFE58325)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.updateAvailableMessage(_storeVersion!),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFE58325),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            onPressed: () {
                              if (_storeUrl != null) {
                                final uri = Uri.parse(_storeUrl!);
                                launchUrl(uri, mode: LaunchMode.externalApplication);
                              }
                            },
                            child: Text(
                              l10n.updateNow,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
