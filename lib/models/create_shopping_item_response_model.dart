import './shopping_item_model.dart';

class CreateShoppingItemResponse {
  final List<ShoppingItem> createdItems;
  final List<ShoppingItem> updatedItems;
  final List<String> deletedItems;

  CreateShoppingItemResponse({
    required this.createdItems,
    required this.updatedItems,
    required this.deletedItems,
  });

  factory CreateShoppingItemResponse.fromJson(Map<String, dynamic> json) {
    return CreateShoppingItemResponse(
      createdItems: (json['createdItems'] as List? ?? [])
          .map((i) => ShoppingItem.fromJson(i))
          .toList(),
      updatedItems: (json['updatedItems'] as List? ?? [])
          .map((i) => ShoppingItem.fromJson(i))
          .toList(),
      deletedItems: (json['deletedItems'] as List? ?? [])
          .map((i) => i.toString())
          .toList(),
    );
  }
}
