import 'package:flutter/material.dart';
import 'package:mealique/models/shopping_item_model.dart';
import '../../l10n/app_localizations.dart';

class ShoppingListItemDetailScreen extends StatelessWidget {
  final ShoppingItem item;

  const ShoppingListItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(item.display),
      ),
      body: Center(
        child: Text(l10n.itemDetailsPlaceholder),
      ),
    );
  }
}
