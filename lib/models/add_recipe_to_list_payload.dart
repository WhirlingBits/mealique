class AddRecipeToListPayload {
  final int recipeIncrementQuantity;
  final List<RecipeIngredientRef>? recipeIngredients;
  final String recipeId;

  AddRecipeToListPayload({
    required this.recipeIncrementQuantity,
    this.recipeIngredients,
    required this.recipeId,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'recipeIncrementQuantity': recipeIncrementQuantity,
      'recipeId': recipeId,
    };

    if (recipeIngredients != null && recipeIngredients!.isNotEmpty) {
      json['recipeIngredients'] = recipeIngredients!.map((i) => i.toJson()).toList();
    }

    return json;
  }
}

/// Referenz zu einer Rezept-Zutat für die Shopping List API
/// Entspricht dem Mealie RecipeIngredient-Input Schema
class RecipeIngredientRef {
  final String referenceId;
  final double? quantity;
  final String? note;
  final String? display;
  final String? foodId;
  final String? foodName;
  final String? unitId;
  final String? unitName;

  RecipeIngredientRef({
    required this.referenceId,
    this.quantity,
    this.note,
    this.display,
    this.foodId,
    this.foodName,
    this.unitId,
    this.unitName,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'referenceId': referenceId,
    };

    if (quantity != null) json['quantity'] = quantity;
    if (note != null && note!.isNotEmpty) json['note'] = note;
    if (display != null && display!.isNotEmpty) json['display'] = display;

    // Mealie API erwartet food als Objekt mit id und name (beide required!)
    if (foodId != null && foodId!.isNotEmpty) {
      json['food'] = {
        'id': foodId,
        'name': foodName ?? '', // name ist required
      };
    }

    // Mealie API erwartet unit als Objekt mit id und name (beide required!)
    if (unitId != null && unitId!.isNotEmpty) {
      json['unit'] = {
        'id': unitId,
        'name': unitName ?? '', // name ist required
      };
    }

    return json;
  }
}
