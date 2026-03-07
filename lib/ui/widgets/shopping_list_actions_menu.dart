import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class ShoppingListActionsMenu extends StatelessWidget {
  final VoidCallback onAddList;
  final VoidCallback onRefresh;
  final VoidCallback? onSort;

  const ShoppingListActionsMenu({
    super.key,
    required this.onAddList,
    required this.onRefresh,
    this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'add_list':
            onAddList();
            break;
          case 'sort':
            onSort?.call();
            break;
          case 'refresh':
            onRefresh();
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'add_list',
          child: ListTile(
            leading: const Icon(Icons.add),
            title: Text(l10n.addList),
          ),
        ),
        if (onSort != null)
          PopupMenuItem<String>(
            value: 'sort',
            child: ListTile(
              leading: const Icon(Icons.sort),
              title: Text(l10n.sort),
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
