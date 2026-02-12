class AddRecipeToListPayload {
  final int recipeIncrementQuantity;
  final List<Map<String, dynamic>> recipeIngredients;
  final String recipeId;

  AddRecipeToListPayload({
    required this.recipeIncrementQuantity,
    required this.recipeIngredients,
    required this.recipeId,
  });

  Map<String, dynamic> toJson() {
    return {
      'recipeIncrementQuantity': recipeIncrementQuantity,
      'recipeIngredients': recipeIngredients,
      'recipeId': recipeId,
    };
  }
}
