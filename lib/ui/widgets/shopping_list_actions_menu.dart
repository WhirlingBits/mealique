import 'package:flutter/material.dart';

class ShoppingListActionsMenu extends StatelessWidget {
  final VoidCallback onAddList;
  final VoidCallback onRefresh;

  const ShoppingListActionsMenu({
    super.key,
    required this.onAddList,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'add_list':
            onAddList();
            break;
          case 'refresh':
            onRefresh();
            break;
        }
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
