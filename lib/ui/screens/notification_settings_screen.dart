import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Benachrichtigungen'), // TODO: l10n
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: const [
          // TODO: Implement notification settings
          Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Hier werden bald die Benachrichtigungseinstellungen zu finden sein.'),
            ),
          )
        ],
      ),
    );
  }
}
