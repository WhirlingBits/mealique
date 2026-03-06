import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class RecipeActionsMenu extends StatelessWidget {
  const RecipeActionsMenu({super.key});

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
          value: 'add_recipe',
          child: ListTile(
            leading: const Icon(Icons.add),
            title: Text(l10n.addRecipe),
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
