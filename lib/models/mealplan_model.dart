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
  final String? householdId;
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
    this.householdId,
    this.userId,
    this.recipe,
  });

  factory MealplanEntry.fromJson(Map<String, dynamic> json) {
    // id can be int or String depending on context
    int parsedId = 0;
    if (json['id'] is int) {
      parsedId = json['id'];
    } else if (json['id'] is String) {
      parsedId = int.tryParse(json['id']) ?? 0;
    }
    return MealplanEntry(
      date: json['date'],
      entryType: PlanEntryType.fromString(json['entryType'] ?? json['entry_type']),
      title: json['title'],
      text: json['text'],
      recipeId: json['recipeId'] ?? json['recipe_id'],
      id: parsedId,
      groupId: json['groupId'] ?? json['group_id'],
      householdId: json['householdId'] ?? json['household_id'],
      userId: json['userId'] ?? json['user_id'],
      recipe: json['recipe'] != null ? MealplanRecipe.fromJson(json['recipe']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'date': date,
      'entryType': entryType.name,
      'title': title ?? '',
      'text': text ?? '',
    };
    // Only include recipeId when a real recipe is assigned
    if (recipeId != null && recipeId!.isNotEmpty) {
      data['recipeId'] = recipeId;
    }
    if (groupId != null) {
      data['groupId'] = groupId;
    }
    if (householdId != null) {
      data['householdId'] = householdId;
    }
    // Only include id if it's an existing entry (id > 0)
    if (id > 0) {
      data['id'] = id;
    }
    return data;
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
