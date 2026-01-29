class RecipeStatus {
  final String? lastMade;
  final String recipeId;

  RecipeStatus({this.lastMade, required this.recipeId});

  factory RecipeStatus.fromJson(Map<String, dynamic> json) {
    return RecipeStatus(
      lastMade: json['lastMade'],
      recipeId: json['recipeId'],
    );
  }
}
