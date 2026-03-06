import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // TODO: Implement notification settings
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(l10n.notificationSettingsComingSoon),
            ),
          )
        ],
      ),
    );
  }
}
