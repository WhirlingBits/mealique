class Household {
  final String id;
  final String name;

  Household({required this.id, required this.name});

  factory Household.fromJson(Map<String, dynamic> json) {
    return Household(
      id: json['id'],
      name: json['name'],
    );
  }
}

class QueryFilter {
  final List<dynamic> parts;

  QueryFilter({required this.parts});

  factory QueryFilter.fromJson(Map<String, dynamic> json) {
    return QueryFilter(
      parts: json['parts'] ?? [],
    );
  }
}

class Cookbook {
  final String id;
  final String name;
  final String? description;
  final String slug;
  final int position;
  final bool public;
  final String queryFilterString;
  final String groupId;
  final String householdId;
  final QueryFilter queryFilter;
  final Household household;

  Cookbook({
    required this.id,
    required this.name,
    this.description,
    required this.slug,
    required this.position,
    required this.public,
    required this.queryFilterString,
    required this.groupId,
    required this.householdId,
    required this.queryFilter,
    required this.household,
  });

  factory Cookbook.fromJson(Map<String, dynamic> json) {
    return Cookbook(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      slug: json['slug'],
      position: json['position'],
      public: json['public'],
      queryFilterString: json['queryFilterString'] ?? '',
      groupId: json['groupId'],
      householdId: json['householdId'],
      queryFilter: QueryFilter.fromJson(json['queryFilter']),
      household: Household.fromJson(json['household']),
    );
  }
}

class CookbookResponse {
  final int page;
  final int perPage;
  final int total;
  final int totalPages;
  final List<Cookbook> items;
  final String? next;
  final String? previous;

  CookbookResponse({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.items,
    this.next,
    this.previous,
  });

  factory CookbookResponse.fromJson(Map<String, dynamic> json) {
    return CookbookResponse(
      page: json['page'],
      perPage: json['per_page'],
      total: json['total'],
      totalPages: json['total_pages'],
      items: (json['items'] as List)
          .map((item) => Cookbook.fromJson(item))
          .toList(),
      next: json['next'],
      previous: json['previous'],
    );
  }
}
