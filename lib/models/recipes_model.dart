class RecipeIngredient {
  final String? referenceId;
  final String note;
  final String display;
  final double quantity;
  final String? unitId;
  final String? unit;
  final String? foodId;
  final String? food;

  RecipeIngredient({
    this.referenceId,
    required this.note,
    this.display = '',
    required this.quantity,
    this.unitId,
    this.unit,
    this.foodId,
    this.food,
  });

  /// Gibt den anzuzeigenden Text für die Zutat zurück.
  /// Priorisiert: display > zusammengesetzt aus quantity/unit/food > note
  String get displayText {
    // Wenn display vorhanden ist, diesen verwenden
    if (display.isNotEmpty) return display;

    // Zusammensetzen aus Menge, Einheit und Lebensmittel
    final parts = <String>[];
    if (quantity > 0) {
      // Formatiere Menge (keine Dezimalstellen wenn ganze Zahl)
      final qtyStr = quantity == quantity.roundToDouble()
          ? quantity.toInt().toString()
          : quantity.toString();
      parts.add(qtyStr);
    }
    if (unit != null && unit!.isNotEmpty) {
      parts.add(unit!);
    }
    if (food != null && food!.isNotEmpty) {
      parts.add(food!);
    }

    if (parts.isNotEmpty) {
      final composed = parts.join(' ');
      // Wenn note zusätzliche Info enthält, anhängen
      if (note.isNotEmpty && note != composed && !composed.contains(note)) {
        return '$composed ($note)';
      }
      return composed;
    }

    // Fallback auf note
    return note.isNotEmpty ? note : '(Keine Angabe)';
  }

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      // Mealie uses 'id' for ingredient reference, but we call it referenceId internally
      referenceId: json['id'] as String? ?? json['referenceId'] as String?,
      note: json['note'] ?? '',
      display: json['display'] ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unitId: json['unit']?['id'] as String?,
      unit: json['unit']?['name'] as String?,
      foodId: json['food']?['id'] as String?,
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

class RecipeNote {
  final String title;
  final String text;

  RecipeNote({this.title = '', required this.text});

  factory RecipeNote.fromJson(Map<String, dynamic> json) {
    return RecipeNote(
      title: json['title'] ?? '',
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
  final String? recipeYield;
  final int rating;
  final bool isFavorite;
  final List<RecipeIngredient> ingredients;
  final List<RecipeInstruction> instructions;
  final List<String> recipeCategory;
  final List<String> tags;
  final List<String> tools;
  final List<RecipeNote> notes;

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
    this.recipeYield,
    this.rating = 0,
    this.isFavorite = false,
    required this.ingredients,
    required this.instructions,
    this.recipeCategory = const [],
    this.tags = const [],
    this.tools = const [],
    this.notes = const [],
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

  Recipe copyWith({
    String? id,
    String? name,
    String? slug,
    String? image,
    String? description,
    String? totalTime,
    String? prepTime,
    String? performTime,
    int? servings,
    String? recipeYield,
    int? rating,
    bool? isFavorite,
    List<RecipeIngredient>? ingredients,
    List<RecipeInstruction>? instructions,
    List<String>? recipeCategory,
    List<String>? tags,
    List<String>? tools,
    List<RecipeNote>? notes,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      image: image ?? this.image,
      description: description ?? this.description,
      totalTime: totalTime ?? this.totalTime,
      prepTime: prepTime ?? this.prepTime,
      performTime: performTime ?? this.performTime,
      servings: servings ?? this.servings,
      recipeYield: recipeYield ?? this.recipeYield,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      recipeCategory: recipeCategory ?? this.recipeCategory,
      tags: tags ?? this.tags,
      tools: tools ?? this.tools,
      notes: notes ?? this.notes,
    );
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
      servings: _parseServings(json['recipeServings'] ?? json['recipeYield']),
      recipeYield: json['recipeYield']?.toString(),
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      isFavorite: (json['isFavorite'] as bool?) ?? false,
      ingredients: (json['recipeIngredient'] as List? ?? [])
          .map((i) => RecipeIngredient.fromJson(i))
          .toList(),
      instructions: (json['recipeInstructions'] as List? ?? [])
          .map((i) => RecipeInstruction.fromJson(i))
          .toList(),
      recipeCategory: (json['recipeCategory'] as List? ?? [])
          .map((c) => (c is Map ? c['name'] : c)?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList(),
      tags: (json['tags'] as List? ?? [])
          .map((t) => (t is Map ? t['name'] : t)?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList(),
      tools: (json['tools'] as List? ?? [])
          .map((t) => (t is Map ? t['name'] : t)?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList(),
      notes: (json['notes'] as List? ?? [])
          .map((n) => RecipeNote.fromJson(n))
          .toList(),
    );
  }
}
