import 'package:mealique/models/shopping_item_model.dart';

class ShoppingListLabel {
  final String name;
  final String color;
  final String groupId;
  final String id;

  ShoppingListLabel({
    required this.name,
    required this.color,
    required this.groupId,
    required this.id,
  });

  factory ShoppingListLabel.fromJson(Map<String, dynamic> json) {
    return ShoppingListLabel(
      name: json['name'],
      color: json['color'],
      groupId: json['groupId'],
      id: json['id'],
    );
  }
}

class ShoppingListLabelSetting {
  final String shoppingListId;
  final String labelId;
  final int position;
  final String id;
  final ShoppingListLabel label;

  ShoppingListLabelSetting({
    required this.shoppingListId,
    required this.labelId,
    required this.position,
    required this.id,
    required this.label,
  });

  factory ShoppingListLabelSetting.fromJson(Map<String, dynamic> json) {
    return ShoppingListLabelSetting(
      shoppingListId: json['shoppingListId'],
      labelId: json['labelId'],
      position: json['position'] ?? 0,
      id: json['id'],
      label: ShoppingListLabel.fromJson(json['label']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shoppingListId': shoppingListId,
      'labelId': labelId,
      'position': position,
      'id': id,
    };
  }
}

class ShoppingListRecipe {
  final String id;
  final String name;
  final String slug;
  final int recipeServings;

  ShoppingListRecipe({
    required this.id,
    required this.name,
    required this.slug,
    required this.recipeServings,
  });

  factory ShoppingListRecipe.fromJson(Map<String, dynamic> json) {
    return ShoppingListRecipe(
      id: json['id'],
      name: json['name'],
      slug: json['slug'] ?? '',
      recipeServings: json['recipeServings'] ?? 0,
    );
  }
}

class ShoppingListRecipeReference {
  final String id;
  final String shoppingListId;
  final String recipeId;
  final int recipeQuantity;
  final ShoppingListRecipe recipe;

  ShoppingListRecipeReference({
    required this.id,
    required this.shoppingListId,
    required this.recipeId,
    required this.recipeQuantity,
    required this.recipe,
  });

  factory ShoppingListRecipeReference.fromJson(Map<String, dynamic> json) {
    return ShoppingListRecipeReference(
      id: json['id'],
      shoppingListId: json['shoppingListId'],
      recipeId: json['recipeId'],
      recipeQuantity: json['recipeQuantity'] ?? 0,
      recipe: ShoppingListRecipe.fromJson(json['recipe']),
    );
  }
}

class ShoppingList {
  final String name;
  final Map<String, dynamic> extras;
  final String createdAt;
  final String updatedAt;
  final String? groupId;
  final String? userId;
  final String id;
  final String? householdId;
  final List<ShoppingListRecipeReference> recipeReferences;
  final List<ShoppingListLabelSetting> labelSettings;
  final List<ShoppingItem> listItems;
  final int itemCount; // Added field

  ShoppingList({
    required this.name,
    required this.extras,
    required this.createdAt,
    required this.updatedAt,
    this.groupId,
    this.userId,
    required this.id,
    this.householdId,
    required this.recipeReferences,
    required this.labelSettings,
    required this.listItems,
    this.itemCount = 0, // Default value
  });

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      name: json['name'],
      extras: json['extras'] as Map<String, dynamic>? ?? {},
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      groupId: json['groupId'],
      userId: json['userId'],
      id: json['id'],
      householdId: json['householdId'],
      recipeReferences: (json['recipeReferences'] as List? ?? [])
          .map((i) => ShoppingListRecipeReference.fromJson(i))
          .toList(),
      labelSettings: (json['labelSettings'] as List? ?? [])
          .map((i) => ShoppingListLabelSetting.fromJson(i))
          .toList(),
      listItems: (json['listItems'] as List? ?? [])
          .map((i) => ShoppingItem.fromJson(i))
          .toList(),
      // Item count is not from JSON, will be set manually
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'extras': extras,
      'createdAt': createdAt,
      'update_at': updatedAt,
      'groupId': groupId,
      'userId': userId,
      'id': id,
      'listItems': listItems.map((item) => item.toJson()).toList(),
    };
  }

  ShoppingList copyWith({
    String? name,
    Map<String, dynamic>? extras,
    String? createdAt,
    String? updatedAt,
    String? groupId,
    String? userId,
    String? id,
    String? householdId,
    List<ShoppingListRecipeReference>? recipeReferences,
    List<ShoppingListLabelSetting>? labelSettings,
    List<ShoppingItem>? listItems,
    int? itemCount,
  }) {
    return ShoppingList(
      name: name ?? this.name,
      extras: extras ?? this.extras,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      recipeReferences: recipeReferences ?? this.recipeReferences,
      labelSettings: labelSettings ?? this.labelSettings,
      listItems: listItems ?? this.listItems,
      itemCount: itemCount ?? this.itemCount,
    );
  }
}

class ShoppingListResponse {
  final int page;
  final int perPage;
  final int total;
  final int totalPages;
  final List<ShoppingList> items;
  final String? next;
  final String? previous;

  ShoppingListResponse({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.items,
    this.next,
    this.previous,
  });

  factory ShoppingListResponse.fromJson(Map<String, dynamic> json) {
    return ShoppingListResponse(
      page: json['page'],
      perPage: json['per_page'],
      total: json['total'],
      totalPages: json['total_pages'],
      items: (json['items'] as List)
          .map((i) => ShoppingList.fromJson(i))
          .toList(),
      next: json['next'],
      previous: json['previous'],
    );
  }
}
