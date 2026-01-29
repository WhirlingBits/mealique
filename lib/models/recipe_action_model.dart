class RecipeAction {
  final String actionType;
  final String title;
  final String url;
  final String groupId;
  final String householdId;
  final String id;

  RecipeAction({
    required this.actionType,
    required this.title,
    required this.url,
    required this.groupId,
    required this.householdId,
    required this.id,
  });

  factory RecipeAction.fromJson(Map<String, dynamic> json) {
    return RecipeAction(
      actionType: json['actionType'],
      title: json['title'],
      url: json['url'],
      groupId: json['groupId'],
      householdId: json['householdId'],
      id: json['id'],
    );
  }
}

class RecipeActionResponse {
  final int page;
  final int perPage;
  final int total;
  final int totalPages;
  final List<RecipeAction> items;
  final String? next;
  final String? previous;

  RecipeActionResponse({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.items,
    this.next,
    this.previous,
  });

  factory RecipeActionResponse.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List;
    List<RecipeAction> recipeActions = itemsList.map((i) => RecipeAction.fromJson(i)).toList();

    return RecipeActionResponse(
      page: json['page'],
      perPage: json['per_page'],
      total: json['total'],
      totalPages: json['total_pages'],
      items: recipeActions,
      next: json['next'],
      previous: json['previous'],
    );
  }
}
