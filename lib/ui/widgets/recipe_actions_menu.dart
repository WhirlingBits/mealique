import 'package:flutter/material.dart';

class RecipeActionsMenu extends StatelessWidget {
  const RecipeActionsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        // TODO: Implement menu actions
        print('Selected: $value');
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'add_recipe',
          child: ListTile(
            leading: Icon(Icons.add),
            title: Text('Rezept hinzufügen'), // TODO: l10n
          ),
        ),
        const PopupMenuItem<String>(
          value: 'sort',
          child: ListTile(
            leading: Icon(Icons.sort),
            title: Text('Sortieren'), // TODO: l10n
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
