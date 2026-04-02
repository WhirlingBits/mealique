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
      name: json['name'] ?? '',
      color: json['color'] ?? '',
      groupId: json['groupId'] ?? '',
      id: json['id'] ?? '',
    );
  }
}

class ShoppingItemUnit {
  final String id;
  final String name;

  ShoppingItemUnit({required this.id, required this.name});

  factory ShoppingItemUnit.fromJson(Map<String, dynamic> json) {
    return ShoppingItemUnit(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
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
      id: json['id'] ?? '',
      name: json['name'] ?? '',
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
  final String? labelId;
  final String id;
  final ShoppingItemLabel? label;
  final Map<String, dynamic>? extras; // Add extras

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
    this.labelId,
    required this.id,
    this.label,
    this.extras,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] != null ? ShoppingItemUnit.fromJson(json['unit']) : null,
      food: json['food'] != null ? ShoppingItemFood.fromJson(json['food']) : null,
      note: json['note'] ?? '',
      display: json['display'] ?? '',
      shoppingListId: json['shoppingListId'] ?? '',
      checked: json['checked'] ?? false,
      position: (json['position'] as num?)?.toInt() ?? 0,
      foodId: json['foodId'],
      unitId: json['unitId'],
      labelId: json['labelId'],
      id: json['id'] ?? '',
      label: json['label'] != null ? ShoppingItemLabel.fromJson(json['label']) : null,
      extras: json['extras'],
    );
  }

  Map<String, dynamic> toJson() {
    final bool isNewItem = id.isEmpty;
    final Map<String, dynamic> data = {
      'quantity': quantity,
      'shoppingListId': shoppingListId,
      'checked': checked,
    };

    // Only include note if it has content
    if (note.isNotEmpty) {
      data['note'] = note;
    }

    // Only include position for existing items (updates) - API auto-assigns for new items
    if (!isNewItem) {
      data['position'] = position;
    }

    // Only include id for existing items (updates)
    if (!isNewItem) {
      data['id'] = id;
    }

    // Only include display and extras for existing items (updates)
    if (!isNewItem) {
      if (display.isNotEmpty) data['display'] = display;
      data['extras'] = extras ?? {};
    }

    if (isNewItem) {
      // For creation: only send IDs, not nested objects
      if (food != null) {
        data['foodId'] = food!.id;
      } else if (foodId != null && foodId!.isNotEmpty) {
        data['foodId'] = foodId;
      }

      if (unit != null) {
        data['unitId'] = unit!.id;
      } else if (unitId != null && unitId!.isNotEmpty) {
        data['unitId'] = unitId;
      }

      if (labelId != null && labelId!.isNotEmpty) {
        data['labelId'] = labelId;
      }
    } else {
      // For updates: send nested objects if available
      if (food != null) {
        data['food'] = {
          'id': food!.id,
          'name': food!.name,
        };
        data['foodId'] = food!.id;
      } else if (foodId != null && foodId!.isNotEmpty) {
        data['foodId'] = foodId;
      }

      if (unit != null) {
        data['unit'] = {
          'id': unit!.id,
          'name': unit!.name,
        };
        data['unitId'] = unit!.id;
      } else if (unitId != null && unitId!.isNotEmpty) {
        data['unitId'] = unitId;
      }

      if (labelId != null && labelId!.isNotEmpty) {
        data['labelId'] = labelId;
      }
      if (label != null) {
        data['label'] = {
          'id': label!.id,
          'name': label!.name,
          'color': label!.color,
          'groupId': label!.groupId,
        };
      }

      data['extras'] = extras ?? {};
    }

    return data;
  }

  /// Complete serialization for local cache storage.
  /// Unlike toJson() which is optimized for API calls, this always includes all fields.
  Map<String, dynamic> toCacheJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'quantity': quantity,
      'note': note,
      'display': display,
      'shoppingListId': shoppingListId,
      'checked': checked,
      'position': position,
      'extras': extras ?? {},
    };
    if (food != null) {
      data['food'] = {
        'id': food!.id,
        'name': food!.name,
        if (food!.label != null)
          'label': {
            'id': food!.label!.id,
            'name': food!.label!.name,
            'color': food!.label!.color,
            'groupId': food!.label!.groupId,
          },
      };
    }
    if (foodId != null) data['foodId'] = foodId;
    if (unit != null) {
      data['unit'] = {
        'id': unit!.id,
        'name': unit!.name,
      };
    }
    if (unitId != null) data['unitId'] = unitId;
    if (labelId != null) data['labelId'] = labelId;
    if (label != null) {
      data['label'] = {
        'id': label!.id,
        'name': label!.name,
        'color': label!.color,
        'groupId': label!.groupId,
      };
    }
    return data;
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
    String? labelId,
    String? id,
    ShoppingItemLabel? label,
    Map<String, dynamic>? extras,
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
      labelId: labelId ?? this.labelId,
      id: id ?? this.id,
      label: label ?? this.label,
      extras: extras ?? this.extras,
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
    var itemsList = (json['items'] as List?) ?? [];
    List<ShoppingItem> shoppingItems = itemsList.map((i) => ShoppingItem.fromJson(i)).toList();

    return ShoppingItemResponse(
      page: (json['page'] as num?)?.toInt() ?? 1,
      perPage: (json['per_page'] as num?)?.toInt() ?? 10,
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 0,
      items: shoppingItems,
      next: json['next'],
      previous: json['previous'],
    );
  }
}
