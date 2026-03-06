import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class RecipeActionsMenu extends StatelessWidget {
  final VoidCallback? onAddRecipe;
  final VoidCallback? onSort;
  final VoidCallback? onRefresh;

  const RecipeActionsMenu({
    super.key,
    this.onAddRecipe,
    this.onSort,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'add_recipe':
            onAddRecipe?.call();
            break;
          case 'sort':
            onSort?.call();
            break;
          case 'refresh':
            onRefresh?.call();
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        if (onAddRecipe != null)
          PopupMenuItem<String>(
            value: 'add_recipe',
            child: ListTile(
              leading: const Icon(Icons.add),
              title: Text(l10n.addRecipe),
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
        if (onRefresh != null)
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
