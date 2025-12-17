import 'shopping_item.dart';

class ShoppingList {
  final String id;
  final String name;
  final List<ShoppingItem> items;

  ShoppingList({
    required this.id,
    required this.name,
    this.items = const [],
  });

  // Factory for creating a ShoppingList from JSON
  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    var list = json['listItems'] as List? ?? [];
    List<ShoppingItem> itemsList = list.map((i) => ShoppingItem.fromJson(i)).toList();

    return ShoppingList(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      items: itemsList,
    );
  }
}