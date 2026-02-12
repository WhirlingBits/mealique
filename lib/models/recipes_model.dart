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
      servings: json['recipeYield'] ?? 0,
      ingredients: (json['recipeIngredient'] as List? ?? [])
          .map((i) => RecipeIngredient.fromJson(i))
          .toList(),
      instructions: (json['recipeInstructions'] as List? ?? [])
          .map((i) => RecipeInstruction.fromJson(i))
          .toList(),
    );
  }
}
