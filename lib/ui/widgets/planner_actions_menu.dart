import 'package:flutter/material.dart';

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
        const PopupMenuItem<String>(
          value: 'add_meal',
          child: ListTile(
            leading: Icon(Icons.add),
            title: Text('Mahlzeit hinzufügen'), // TODO: l10n
          ),
        ),
        const PopupMenuItem<String>(
          value: 'refresh',
          child: ListTile(
            leading: Icon(Icons.refresh),
            title: Text('Aktualisieren'), // TODO: l10n
          ),
        ),
      ],
    );
  }
}
