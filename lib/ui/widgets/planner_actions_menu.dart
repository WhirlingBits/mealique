import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class PlannerActionsMenu extends StatelessWidget {
  final VoidCallback onAddMeal;
  final VoidCallback onRefresh;

  const PlannerActionsMenu({
    super.key,
    required this.onAddMeal,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'add_meal':
            onAddMeal();
            break;
          case 'refresh':
            onRefresh();
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'add_meal',
          child: ListTile(
            leading: const Icon(Icons.add),
            title: Text(l10n.addMeal),
          ),
        ),
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
