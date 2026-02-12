enum PlanEntryType {
  breakfast,
  lunch,
  dinner,
  side,
  snack,
  drink,
  dessert;

  static PlanEntryType fromString(String? value) {
    switch (value) {
      case 'breakfast':
        return PlanEntryType.breakfast;
      case 'lunch':
        return PlanEntryType.lunch;
      case 'dinner':
        return PlanEntryType.dinner;
      case 'side':
        return PlanEntryType.side;
      case 'snack':
        return PlanEntryType.snack;
      case 'drink':
        return PlanEntryType.drink;
      case 'dessert':
        return PlanEntryType.dessert;
      default:
        return PlanEntryType.breakfast; // Fallback default
    }
  }
}

class MealplanRecipe {
  final String id;
  final String name;
  final String slug;

  MealplanRecipe({required this.id, required this.name, required this.slug});

  factory MealplanRecipe.fromJson(Map<String, dynamic> json) {
    return MealplanRecipe(
      id: json['id'],
      name: json['name'],
      slug: json['slug'] ?? '',
    );
  }
}

class MealplanEntry {
  final String date;
  final PlanEntryType entryType;
  final String? title;
  final String? text;
  final String? recipeId;
  final int id;
  final String? groupId;
  final String? userId;
  final MealplanRecipe? recipe;

  MealplanEntry({
    required this.date,
    required this.entryType,
    this.title,
    this.text,
    this.recipeId,
    required this.id,
    this.groupId,
    this.userId,
    this.recipe,
  });

  factory MealplanEntry.fromJson(Map<String, dynamic> json) {
    return MealplanEntry(
      date: json['date'],
      entryType: PlanEntryType.fromString(json['entryType']),
      title: json['title'],
      text: json['text'],
      recipeId: json['recipeId'],
      id: json['id'],
      groupId: json['groupId'],
      userId: json['userId'],
      recipe: json['recipe'] != null ? MealplanRecipe.fromJson(json['recipe']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'entryType': entryType.name,
      'title': title,
      'text': text,
      'recipeId': recipeId,
      'id': id,
      'groupId': groupId,
      'userId': userId,
    };
  }
}

class MealplanResponse {
  final int page;
  final int perPage;
  final int total;
  final int totalPages;
  final List<MealplanEntry> items;
  final String? next;
  final String? previous;

  MealplanResponse({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.items,
    this.next,
    this.previous,
  });

  factory MealplanResponse.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List;
    List<MealplanEntry> entries = itemsList.map((i) => MealplanEntry.fromJson(i)).toList();

    return MealplanResponse(
      page: json['page'],
      perPage: json['per_page'],
      total: json['total'],
      totalPages: json['total_pages'],
      items: entries,
      next: json['next'],
      previous: json['previous'],
    );
  }
}
