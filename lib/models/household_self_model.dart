class HouseholdPreferences {
  final bool privateHousehold;
  final bool lockRecipeEditsFromOtherHouseholds;
  final int firstDayOfWeek;
  final bool recipePublic;
  final bool recipeShowNutrition;
  final bool recipeShowAssets;
  final bool recipeLandscapeView;
  final bool recipeDisableComments;
  final String id;

  HouseholdPreferences({
    required this.privateHousehold,
    required this.lockRecipeEditsFromOtherHouseholds,
    required this.firstDayOfWeek,
    required this.recipePublic,
    required this.recipeShowNutrition,
    required this.recipeShowAssets,
    required this.recipeLandscapeView,
    required this.recipeDisableComments,
    required this.id,
  });

  factory HouseholdPreferences.fromJson(Map<String, dynamic> json) {
    return HouseholdPreferences(
      privateHousehold: json['privateHousehold'] ?? true,
      lockRecipeEditsFromOtherHouseholds: json['lockRecipeEditsFromOtherHouseholds'] ?? true,
      firstDayOfWeek: json['firstDayOfWeek'] ?? 0,
      recipePublic: json['recipePublic'] ?? true,
      recipeShowNutrition: json['recipeShowNutrition'] ?? false,
      recipeShowAssets: json['recipeShowAssets'] ?? false,
      recipeLandscapeView: json['recipeLandscapeView'] ?? false,
      recipeDisableComments: json['recipeDisableComments'] ?? false,
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'privateHousehold': privateHousehold,
      'lockRecipeEditsFromOtherHouseholds': lockRecipeEditsFromOtherHouseholds,
      'firstDayOfWeek': firstDayOfWeek,
      'recipePublic': recipePublic,
      'recipeShowNutrition': recipeShowNutrition,
      'recipeShowAssets': recipeShowAssets,
      'recipeLandscapeView': recipeLandscapeView,
      'recipeDisableComments': recipeDisableComments,
    };
  }
}

class HouseholdUser {
  final String id;
  final String fullName;

  HouseholdUser({required this.id, required this.fullName});

  factory HouseholdUser.fromJson(Map<String, dynamic> json) {
    return HouseholdUser(
      id: json['id'],
      fullName: json['fullName'],
    );
  }
}

class HouseholdSelf {
  final String groupId;
  final String name;
  final String id;
  final String slug;
  final HouseholdPreferences preferences;
  final String group;
  final List<HouseholdUser> users;
  final List<dynamic> webhooks;

  HouseholdSelf({
    required this.groupId,
    required this.name,
    required this.id,
    required this.slug,
    required this.preferences,
    required this.group,
    required this.users,
    required this.webhooks,
  });

  factory HouseholdSelf.fromJson(Map<String, dynamic> json) {
    var usersList = json['users'] as List? ?? [];
    List<HouseholdUser> users = usersList.map((i) => HouseholdUser.fromJson(i)).toList();

    return HouseholdSelf(
      groupId: json['groupId'],
      name: json['name'],
      id: json['id'],
      slug: json['slug'],
      preferences: HouseholdPreferences.fromJson(json['preferences']),
      group: json['group'],
      users: users,
      webhooks: json['webhooks'] as List? ?? [],
    );
  }
}
