import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class DashboardActionsMenu extends StatelessWidget {
  const DashboardActionsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      onSelected: (value) {
        // TODO: Implement menu actions
        print('Selected: $value');
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'refresh',
          child: ListTile(
            leading: const Icon(Icons.refresh),
            title: Text(l10n.refresh),
          ),
        ),
      ],
    );
  }
}
