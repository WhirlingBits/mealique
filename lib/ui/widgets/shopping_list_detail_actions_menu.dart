import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class ShoppingListDetailActionsMenu extends StatelessWidget {
  const ShoppingListDetailActionsMenu({super.key});

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
        PopupMenuItem<String>(
          value: 'edit_list',
          child: ListTile(
            leading: const Icon(Icons.edit),
            title: Text(l10n.editList),
          ),
        ),
        PopupMenuItem<String>(
          value: 'toggle_completed',
          child: ListTile(
            leading: const Icon(Icons.check_box_outline_blank),
            title: Text(l10n.showCompletedItems),
          ),
        ),
        PopupMenuItem<String>(
          value: 'sort',
          child: ListTile(
            leading: const Icon(Icons.sort),
            title: Text(l10n.sort),
          ),
        ),
         PopupMenuItem<String>(
          value: 'toggle_categories',
          child: ListTile(
            leading: const Icon(Icons.label_off),
            title: Text(l10n.hideCategories),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'uncheck_all',
          child: ListTile(
            leading: const Icon(Icons.radio_button_unchecked),
            title: Text(l10n.uncheckAllItems),
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete_completed',
          child: ListTile(
            leading: const Icon(Icons.delete_sweep),
            title: Text(l10n.deleteCompletedItems),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'delete_list',
          child: ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(l10n.deleteList, style: const TextStyle(color: Colors.red)),
          ),
        ),
      ],
    );
  }
}
