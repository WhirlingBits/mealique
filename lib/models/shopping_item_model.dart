class ShoppingItemLabel {
  final String name;
  final String color;
  final String groupId;
  final String id;

  ShoppingItemLabel({
    required this.name,
    required this.color,
    required this.groupId,
    required this.id,
  });

  factory ShoppingItemLabel.fromJson(Map<String, dynamic> json) {
    return ShoppingItemLabel(
      name: json['name'],
      color: json['color'],
      groupId: json['groupId'],
      id: json['id'],
    );
  }
}

class ShoppingItemUnit {
  final String id;
  final String name;

  ShoppingItemUnit({required this.id, required this.name});

  factory ShoppingItemUnit.fromJson(Map<String, dynamic> json) {
    return ShoppingItemUnit(
      id: json['id'],
      name: json['name'],
    );
  }
}

class ShoppingItemFood {
  final String id;
  final String name;
  final ShoppingItemLabel? label;

  ShoppingItemFood({required this.id, required this.name, this.label});

  factory ShoppingItemFood.fromJson(Map<String, dynamic> json) {
    return ShoppingItemFood(
      id: json['id'],
      name: json['name'],
      label: json['label'] != null ? ShoppingItemLabel.fromJson(json['label']) : null,
    );
  }
}

class ShoppingItem {
  final double quantity;
  final ShoppingItemUnit? unit;
  final ShoppingItemFood? food;
  final String note;
  final String display;
  final String shoppingListId;
  final bool checked;
  final int position;
  final String? foodId;
  final String? unitId;
  final String id;
  final ShoppingItemLabel? label;

  ShoppingItem({
    required this.quantity,
    this.unit,
    this.food,
    required this.note,
    required this.display,
    required this.shoppingListId,
    required this.checked,
    required this.position,
    this.foodId,
    this.unitId,
    required this.id,
    this.label,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] != null ? ShoppingItemUnit.fromJson(json['unit']) : null,
      food: json['food'] != null ? ShoppingItemFood.fromJson(json['food']) : null,
      note: json['note'] ?? '',
      display: json['display'] ?? '',
      shoppingListId: json['shoppingListId'],
      checked: json['checked'] ?? false,
      position: json['position'] ?? 0,
      foodId: json['foodId'],
      unitId: json['unitId'],
      id: json['id'],
      label: json['label'] != null ? ShoppingItemLabel.fromJson(json['label']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'note': note,
      'display': display,
      'shoppingListId': shoppingListId,
      'checked': checked,
      'position': position,
      'foodId': foodId,
      'unitId': unitId,
      'id': id,
    };
  }

  ShoppingItem copyWith({
    double? quantity,
    ShoppingItemUnit? unit,
    ShoppingItemFood? food,
    String? note,
    String? display,
    String? shoppingListId,
    bool? checked,
    int? position,
    String? foodId,
    String? unitId,
    String? id,
    ShoppingItemLabel? label,
  }) {
    return ShoppingItem(
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      food: food ?? this.food,
      note: note ?? this.note,
      display: display ?? this.display,
      shoppingListId: shoppingListId ?? this.shoppingListId,
      checked: checked ?? this.checked,
      position: position ?? this.position,
      foodId: foodId ?? this.foodId,
      unitId: unitId ?? this.unitId,
      id: id ?? this.id,
      label: label ?? this.label,
    );
  }
}

class ShoppingItemResponse {
  final int page;
  final int perPage;
  final int total;
  final int totalPages;
  final List<ShoppingItem> items;
  final String? next;
  final String? previous;

  ShoppingItemResponse({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.items,
    this.next,
    this.previous,
  });

  factory ShoppingItemResponse.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List;
    List<ShoppingItem> shoppingItems = itemsList.map((i) => ShoppingItem.fromJson(i)).toList();

    return ShoppingItemResponse(
      page: json['page'],
      perPage: json['per_page'],
      total: json['total'],
      totalPages: json['total_pages'],
      items: shoppingItems,
      next: json['next'],
      previous: json['previous'],
    );
  }
}
