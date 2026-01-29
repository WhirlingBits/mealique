class MealplanRuleQueryFilter {
  final List<dynamic> parts;

  MealplanRuleQueryFilter({required this.parts});

  factory MealplanRuleQueryFilter.fromJson(Map<String, dynamic> json) {
    return MealplanRuleQueryFilter(
      parts: json['parts'] as List? ?? [],
    );
  }
}

class MealplanRule {
  final String day;
  final String entryType;
  final String queryFilterString;
  final String groupId;
  final String householdId;
  final String id;
  final MealplanRuleQueryFilter queryFilter;

  MealplanRule({
    required this.day,
    required this.entryType,
    required this.queryFilterString,
    required this.groupId,
    required this.householdId,
    required this.id,
    required this.queryFilter,
  });

  factory MealplanRule.fromJson(Map<String, dynamic> json) {
    return MealplanRule(
      day: json['day'],
      entryType: json['entryType'],
      queryFilterString: json['queryFilterString'] ?? '',
      groupId: json['groupId'],
      householdId: json['householdId'],
      id: json['id'],
      queryFilter: MealplanRuleQueryFilter.fromJson(json['queryFilter']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'entryType': entryType,
      'queryFilterString': queryFilterString,
    };
  }
}

class MealplanRuleResponse {
  final int page;
  final int perPage;
  final int total;
  final int totalPages;
  final List<MealplanRule> items;
  final String? next;
  final String? previous;

  MealplanRuleResponse({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.items,
    this.next,
    this.previous,
  });

  factory MealplanRuleResponse.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List;
    List<MealplanRule> rules = itemsList.map((i) => MealplanRule.fromJson(i)).toList();

    return MealplanRuleResponse(
      page: json['page'],
      perPage: json['per_page'],
      total: json['total'],
      totalPages: json['total_pages'],
      items: rules,
      next: json['next'],
      previous: json['previous'],
    );
  }
}
