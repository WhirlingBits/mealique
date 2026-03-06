import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class DashboardActionsMenu extends StatelessWidget {
  final VoidCallback onRefresh;

  const DashboardActionsMenu({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'refresh':
            onRefresh();
            break;
        }
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
