import 'package:flutter/material.dart';
import 'package:mealique/models/recipes_model.dart';
import '../../l10n/app_localizations.dart';

class RecipeDetailActionsMenu extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailActionsMenu({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      onSelected: (value) {
        // TODO: Implement menu actions for edit, delete, etc.
        print('Selected: $value for recipe ${recipe.id}');
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'edit',
          child: Text(l10n.edit),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Text(l10n.delete),
        ),
        PopupMenuItem<String>(
          value: 'share',
          child: Text(l10n.share),
        ),
      ],
    );
  }
}
