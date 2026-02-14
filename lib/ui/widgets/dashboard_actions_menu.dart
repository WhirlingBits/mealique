import 'package:flutter/material.dart';

class DashboardActionsMenu extends StatelessWidget {
  const DashboardActionsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        // TODO: Implement menu actions
        print('Selected: $value');
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'refresh',
          child: Text('Aktualisieren'), // TODO: l10n
        ),
      ],
    );
  }
}
