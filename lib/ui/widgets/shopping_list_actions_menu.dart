import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
        PopupMenuItem<String>(
          value: 'add_list',
          child: ListTile(
            leading: const Icon(Icons.add),
            title: Text(l10n.addList),
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
