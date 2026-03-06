import 'package:mealique/models/shopping_item_model.dart';

class Food {
  final String id;
  final String name;
  final String pluralName;
  final String? description;
  final Map<String, dynamic> extras;
  final String? labelId;
  final List<String> aliases;
  final List<dynamic> householdsWithIngredientFood;
  final ShoppingItemLabel? label;
  final String createdAt;
  final String updatedAt;

  Food({
    required this.id,
    required this.name,
    required this.pluralName,
    this.description,
    required this.extras,
    this.labelId,
    required this.aliases,
    required this.householdsWithIngredientFood,
    this.label,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'],
      name: json['name'],
      pluralName: json['pluralName'] ?? json['name'],
      description: json['description'],
      extras: json['extras'] as Map<String, dynamic>? ?? {},
      labelId: json['labelId'],
      aliases: List<String>.from(json['aliases'] ?? []),
      householdsWithIngredientFood: json['householdsWithIngredientFood'] ?? [],
      label: json['label'] != null ? ShoppingItemLabel.fromJson(json['label']) : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'pluralName': pluralName,
      'description': description ?? '',
      'extras': extras,
      'labelId': labelId,
      'aliases': aliases,
    };
  }
}

class FoodResponse {
  final int page;
  final int perPage;
  final int total;
  final int totalPages;
  final List<Food> items;
  final String? next;
  final String? previous;

  FoodResponse({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.items,
    this.next,
    this.previous,
  });

  factory FoodResponse.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List;
    List<Food> foodItems = itemsList.map((i) => Food.fromJson(i)).toList();

    return FoodResponse(
      page: json['page'],
      perPage: json['per_page'],
      total: json['total'],
      totalPages: json['total_pages'],
      items: foodItems,
      next: json['next'],
      previous: json['previous'],
    );
  }
}
