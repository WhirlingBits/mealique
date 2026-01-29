class HouseholdStatistics {
  final int totalRecipes;
  final int totalUsers;
  final int totalCategories;
  final int totalTags;
  final int totalTools;

  HouseholdStatistics({
    required this.totalRecipes,
    required this.totalUsers,
    required this.totalCategories,
    required this.totalTags,
    required this.totalTools,
  });

  factory HouseholdStatistics.fromJson(Map<String, dynamic> json) {
    return HouseholdStatistics(
      totalRecipes: json['totalRecipes'] ?? 0,
      totalUsers: json['totalUsers'] ?? 0,
      totalCategories: json['totalCategories'] ?? 0,
      totalTags: json['totalTags'] ?? 0,
      totalTools: json['totalTools'] ?? 0,
    );
  }
}
