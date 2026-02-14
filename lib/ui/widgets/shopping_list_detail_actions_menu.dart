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
          value: 'clear_checked',
          child: Text('Erledigte entfernen'), // TODO: l10n
        ),
      ],
    );
  }
}
