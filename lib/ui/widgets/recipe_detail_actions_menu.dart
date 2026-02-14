import 'package:flutter/material.dart';
import 'package:mealique/models/recipes_model.dart';

class RecipeDetailActionsMenu extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailActionsMenu({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        // TODO: Implement menu actions for edit, delete, etc.
        print('Selected: $value for recipe ${recipe.id}');
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'edit',
          child: Text('Bearbeiten'), // TODO: l10n
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Text('Löschen'), // TODO: l10n
        ),
        const PopupMenuItem<String>(
          value: 'share',
          child: Text('Teilen'), // TODO: l10n
        ),
      ],
    );
  }
}
