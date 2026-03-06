class RecipeIngredient {
  final String note;
  final double quantity;
  final String? unit;
  final String? food;

  RecipeIngredient({
    required this.note,
    required this.quantity,
    this.unit,
    this.food,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      note: json['note'] ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit']?['name'] as String?,
      food: json['food']?['name'] as String?,
    );
  }
}

class RecipeInstruction {
  final String text;

  RecipeInstruction({required this.text});

  factory RecipeInstruction.fromJson(Map<String, dynamic> json) {
    return RecipeInstruction(
      text: json['text'] ?? '',
    );
  }
}

class Recipe {
  final String id;
  final String name;
  final String slug;
  final String? image;
  final String? description;
  final String? totalTime;
  final String? prepTime;
  final String? performTime;
  final int servings;
  final List<RecipeIngredient> ingredients;
  final List<RecipeInstruction> instructions;

  Recipe({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    this.description,
    this.totalTime,
    this.prepTime,
    this.performTime,
    required this.servings,
    required this.ingredients,
    required this.instructions,
  });

  /// Parses recipeYield which can be a String ("4 servings"), int, or null.
  static int _parseServings(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final match = RegExp(r'(\d+)').firstMatch(value);
      if (match != null) return int.parse(match.group(1)!);
    }
    return 0;
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unbenannt',
      slug: json['slug'] ?? '',
      image: json['image'],
      description: json['description'],
      totalTime: json['totalTime'],
      prepTime: json['prepTime'],
      performTime: json['performTime'],
      servings: _parseServings(json['recipeYield']),
      ingredients: (json['recipeIngredient'] as List? ?? [])
          .map((i) => RecipeIngredient.fromJson(i))
          .toList(),
      instructions: (json['recipeInstructions'] as List? ?? [])
          .map((i) => RecipeInstruction.fromJson(i))
          .toList(),
    );
  }
}
