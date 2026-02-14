import 'package:flutter/material.dart';

class ShoppingListDetailActionsMenu extends StatelessWidget {
  const ShoppingListDetailActionsMenu({super.key});

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
          child: ListTile(
            leading: Icon(Icons.refresh),
            title: Text('Aktualisieren'), // TODO: l10n
          ),
        ),
        const PopupMenuItem<String>(
          value: 'edit_list',
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text('Liste bearbeiten'), // TODO: l10n
          ),
        ),
        const PopupMenuItem<String>(
          value: 'toggle_completed',
          child: ListTile(
            leading: Icon(Icons.check_box_outline_blank),
            title: Text('Abgeschlossene Items anzeigen'), // TODO: l10n
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
          value: 'toggle_categories',
          child: ListTile(
            leading: Icon(Icons.label_off),
            title: Text('Kategorien ausblenden'), // TODO: l10n
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'uncheck_all',
          child: ListTile(
            leading: Icon(Icons.radio_button_unchecked),
            title: Text('Markierung aller Elemente entfernen'), // TODO: l10n
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete_completed',
          child: ListTile(
            leading: Icon(Icons.delete_sweep),
            title: Text('Erledigte Elemente löschen'), // TODO: l10n
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'delete_list',
          child: ListTile(
            leading: Icon(Icons.delete_forever, color: Colors.red),
            title: Text('Liste löschen', style: TextStyle(color: Colors.red)), // TODO: l10n
          ),
        ),
      ],
    );
  }
}
