class NotificationOptions {
  final bool testMessage;
  final bool webhookTask;
  final bool recipeCreated;
  final bool recipeUpdated;
  final bool recipeDeleted;
  final bool userSignup;
  final bool dataMigrations;
  final bool dataExport;
  final bool dataImport;
  final bool mealplanEntryCreated;
  final bool shoppingListCreated;
  final bool shoppingListUpdated;
  final bool shoppingListDeleted;
  final bool cookbookCreated;
  final bool cookbookUpdated;
  final bool cookbookDeleted;
  final bool tagCreated;
  final bool tagUpdated;
  final bool tagDeleted;
  final bool categoryCreated;
  final bool categoryUpdated;
  final bool categoryDeleted;
  final bool labelCreated;
  final bool labelUpdated;
  final bool labelDeleted;
  final String id;

  NotificationOptions({
    required this.testMessage,
    required this.webhookTask,
    required this.recipeCreated,
    required this.recipeUpdated,
    required this.recipeDeleted,
    required this.userSignup,
    required this.dataMigrations,
    required this.dataExport,
    required this.dataImport,
    required this.mealplanEntryCreated,
    required this.shoppingListCreated,
    required this.shoppingListUpdated,
    required this.shoppingListDeleted,
    required this.cookbookCreated,
    required this.cookbookUpdated,
    required this.cookbookDeleted,
    required this.tagCreated,
    required this.tagUpdated,
    required this.tagDeleted,
    required this.categoryCreated,
    required this.categoryUpdated,
    required this.categoryDeleted,
    required this.labelCreated,
    required this.labelUpdated,
    required this.labelDeleted,
    required this.id,
  });

  factory NotificationOptions.fromJson(Map<String, dynamic> json) {
    return NotificationOptions(
      testMessage: json['testMessage'] ?? false,
      webhookTask: json['webhookTask'] ?? false,
      recipeCreated: json['recipeCreated'] ?? false,
      recipeUpdated: json['recipeUpdated'] ?? false,
      recipeDeleted: json['recipeDeleted'] ?? false,
      userSignup: json['userSignup'] ?? false,
      dataMigrations: json['dataMigrations'] ?? false,
      dataExport: json['dataExport'] ?? false,
      dataImport: json['dataImport'] ?? false,
      mealplanEntryCreated: json['mealplanEntryCreated'] ?? false,
      shoppingListCreated: json['shoppingListCreated'] ?? false,
      shoppingListUpdated: json['shoppingListUpdated'] ?? false,
      shoppingListDeleted: json['shoppingListDeleted'] ?? false,
      cookbookCreated: json['cookbookCreated'] ?? false,
      cookbookUpdated: json['cookbookUpdated'] ?? false,
      cookbookDeleted: json['cookbookDeleted'] ?? false,
      tagCreated: json['tagCreated'] ?? false,
      tagUpdated: json['tagUpdated'] ?? false,
      tagDeleted: json['tagDeleted'] ?? false,
      categoryCreated: json['categoryCreated'] ?? false,
      categoryUpdated: json['categoryUpdated'] ?? false,
      categoryDeleted: json['categoryDeleted'] ?? false,
      labelCreated: json['labelCreated'] ?? false,
      labelUpdated: json['labelUpdated'] ?? false,
      labelDeleted: json['labelDeleted'] ?? false,
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'testMessage': testMessage,
      'webhookTask': webhookTask,
      'recipeCreated': recipeCreated,
      'recipeUpdated': recipeUpdated,
      'recipeDeleted': recipeDeleted,
      'userSignup': userSignup,
      'dataMigrations': dataMigrations,
      'dataExport': dataExport,
      'dataImport': dataImport,
      'mealplanEntryCreated': mealplanEntryCreated,
      'shoppingListCreated': shoppingListCreated,
      'shoppingListUpdated': shoppingListUpdated,
      'shoppingListDeleted': shoppingListDeleted,
      'cookbookCreated': cookbookCreated,
      'cookbookUpdated': cookbookUpdated,
      'cookbookDeleted': cookbookDeleted,
      'tagCreated': tagCreated,
      'tagUpdated': tagUpdated,
      'tagDeleted': tagDeleted,
      'categoryCreated': categoryCreated,
      'categoryUpdated': categoryUpdated,
      'categoryDeleted': categoryDeleted,
      'labelCreated': labelCreated,
      'labelUpdated': labelUpdated,
      'labelDeleted': labelDeleted,
    };
  }
}

class EventNotification {
  final String id;
  final String name;
  final bool enabled;
  final String groupId;
  final String householdId;
  final NotificationOptions options;

  EventNotification({
    required this.id,
    required this.name,
    required this.enabled,
    required this.groupId,
    required this.householdId,
    required this.options,
  });

  factory EventNotification.fromJson(Map<String, dynamic> json) {
    return EventNotification(
      id: json['id'],
      name: json['name'],
      enabled: json['enabled'] ?? false,
      groupId: json['groupId'],
      householdId: json['householdId'],
      options: NotificationOptions.fromJson(json['options']),
    );
  }

  Map<String, dynamic> toJson({required String appriseUrl}) {
    return {
      'id': id,
      'name': name,
      'appriseUrl': appriseUrl,
      'enabled': enabled,
      'groupId': groupId,
      'householdId': householdId,
      'options': options.toJson(),
    };
  }
}
