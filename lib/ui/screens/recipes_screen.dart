import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: const Center(
        child: Text('Rezepte'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Logik zum Hinzufügen eines Rezepts implementieren
        },
        tooltip: l10n.addRecipe,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}