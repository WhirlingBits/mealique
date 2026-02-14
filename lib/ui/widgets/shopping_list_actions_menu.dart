import 'package:flutter/material.dart';

class ShoppingListActionsMenu extends StatelessWidget {
  const ShoppingListActionsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        // TODO: Implement menu actions
        print('Selected: $value');
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'add_list',
          child: ListTile(
            leading: Icon(Icons.add),
            title: Text('Liste hinzufügen'), // TODO: l10n
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
