import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class ShoppingListDetailActionsMenu extends StatelessWidget {
  final VoidCallback onRefresh;
  final VoidCallback onEditList;
  final VoidCallback onUncheckAll;
  final VoidCallback onDeleteCompleted;
  final VoidCallback onDeleteList;
  final VoidCallback onSortItems;
  final bool showCompleted;
  final VoidCallback onToggleShowCompleted;
  final bool showCategories;
  final VoidCallback onToggleShowCategories;

  const ShoppingListDetailActionsMenu({
    super.key,
    required this.onRefresh,
    required this.onEditList,
    required this.onUncheckAll,
    required this.onDeleteCompleted,
    required this.onDeleteList,
    required this.onSortItems,
    required this.showCompleted,
    required this.onToggleShowCompleted,
    required this.showCategories,
    required this.onToggleShowCategories,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'refresh':
            onRefresh();
            break;
          case 'edit_list':
            onEditList();
            break;
          case 'toggle_completed':
            onToggleShowCompleted();
            break;
          case 'sort':
            onSortItems();
            break;
          case 'toggle_categories':
            onToggleShowCategories();
            break;
          case 'uncheck_all':
            onUncheckAll();
            break;
          case 'delete_completed':
            onDeleteCompleted();
            break;
          case 'delete_list':
            onDeleteList();
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
            leading: Icon(showCompleted
                ? Icons.check_box
                : Icons.check_box_outline_blank),
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
            leading: Icon(showCategories ? Icons.label : Icons.label_off),
            title: Text(showCategories
                ? l10n.hideCategories
                : l10n.showCategories),
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
            title: Text(l10n.deleteList,
                style: const TextStyle(color: Colors.red)),
          ),
        ),
      ],
    );
  }
}
