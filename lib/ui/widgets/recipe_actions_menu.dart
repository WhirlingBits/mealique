import 'package:flutter/material.dart';

class RecipeActionsMenu extends StatelessWidget {
  const RecipeActionsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        // TODO: Implement menu actions
        print('Selected: $value');
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'sort_name',
          child: Text('Nach Name sortieren'), // TODO: l10n
        ),
        const PopupMenuItem<String>(
          value: 'sort_date',
          child: Text('Nach Datum sortieren'), // TODO: l10n
        ),
      ],
    );
  }
}
