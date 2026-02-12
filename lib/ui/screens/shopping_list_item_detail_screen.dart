import 'package:flutter/material.dart';
import 'package:mealique/models/shopping_item_model.dart';

class ShoppingListItemDetailScreen extends StatelessWidget {
  final ShoppingItem item;

  const ShoppingListItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.display),
      ),
      body: const Center(
        child: Text('Details for the shopping list item will be displayed here.'),
      ),
    );
  }
}
