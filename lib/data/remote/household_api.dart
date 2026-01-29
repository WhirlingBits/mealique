import 'package:dio/dio.dart';
import '../../models/add_recipe_to_list_payload.dart';
import '../../models/cookbook_model.dart';
import '../../models/create_shopping_item_response_model.dart';
import '../../models/delete_response_model.dart';
import '../../models/email_invitation_response_model.dart';
import '../../models/event_notification_model.dart';
import '../../models/household_invitation_model.dart';
import '../../models/household_member_model.dart';
import '../../models/household_permissions_model.dart';
import '../../models/household_self_model.dart';
import '../../models/household_statistics_model.dart';
import '../../models/household_webhook_model.dart';
import '../../models/mealplan_model.dart';
import '../../models/mealplan_rule_model.dart';
import '../../models/recipe_action_model.dart';
import '../../models/recipe_status_model.dart';
import '../../models/shopping_item_model.dart';
import '../../models/shopping_list_model.dart';
import '../local/token_storage.dart';

class HouseholdApi {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  HouseholdApi({String? baseUrl})
      : _tokenStorage = TokenStorage(),
        _dio = Dio(BaseOptions(
          // If no URL has been provided, we start with an empty list.
          // The interceptor then places the URL before the request.
          baseUrl: baseUrl ?? '',
          headers: {'Content-Type': 'application/json'},
        )) {
    // Add interceptor for auth tokens and dynamic server URLs
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 1. Load server URL (if not set or empty in the constructor)
        if (options.baseUrl.isEmpty) {
          final serverUrl = await _tokenStorage.getServerUrl();
          if (serverUrl != null && serverUrl.isNotEmpty) {
            // Ensure that the URL is formatted correctly (slash at the end).
            options.baseUrl = serverUrl.endsWith('/') ? serverUrl : '$serverUrl/';
          }
        }

        // 2. load Auth Token
        final token = await _tokenStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        handler.next(options);
      },
    ));
  }

  Future<CookbookResponse> getCookbooks(int page, int perPage) async {
    try {
      final response = await _dio.get(
        'api/households/cookbooks',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return CookbookResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to get cookbooks: ${e.message}');
    }
  }

  Future<Cookbook> createCookbook({
    required String name,
    String? description,
    required String slug,
    required int position,
    bool public = false,
    String? queryFilterString,
  }) async {
    try {
      final response = await _dio.post(
        'api/households/cookbooks',
        data: {
          'name': name,
          'description': description ?? '',
          'slug': slug,
          'position': position,
          'public': public,
          'queryFilterString': queryFilterString ?? '',
        },
      );
      return Cookbook.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to create cookbook: ${e.response?.data ?? e.message}');
    }
  }

  Future<Cookbook> getCookbook(String itemId) async {
    try {
      final response = await _dio.get('api/households/cookbooks/$itemId');
      return Cookbook.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to get cookbook: ${e.response?.data ?? e.message}');
    }
  }

  Future<Cookbook> updateCookbook(
      String itemId, {
        required String name,
        String? description,
        required String slug,
        required int position,
        bool public = false,
        String? queryFilterString,
      }) async {
    try {
      final response = await _dio.put(
        'api/households/cookbooks/$itemId',
        data: {
          'name': name,
          'description': description ?? '',
          'slug': slug,
          'position': position,
          'public': public,
          'queryFilterString': queryFilterString ?? '',
        },
      );
      return Cookbook.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to update cookbook: ${e.response?.data ?? e.message}');
    }
  }

  Future<void> deleteCookbook(String itemId) async {
    try {
      await _dio.delete('api/households/cookbooks/$itemId');
    } on DioException catch (e) {
      throw Exception('Failed to delete cookbook: ${e.response?.data ?? e.message}');
    }
  }

  Future<EventNotification> createEventNotification({
    required String name,
    required String appriseUrl,
  }) async {
    try {
      final response = await _dio.post(
        'api/households/events/notifications',
        data: {
          'name': name,
          'appriseUrl': appriseUrl,
        },
      );
      return EventNotification.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to create event notification: ${e.response?.data ?? e.message}');
    }
  }

  Future<EventNotification> getEventNotification(String itemId) async {
    try {
      final response = await _dio.get('api/households/events/notifications/$itemId');
      return EventNotification.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to get event notification: ${e.response?.data ?? e.message}');
    }
  }

  Future<EventNotification> updateEventNotification(String itemId, EventNotification notification, String appriseUrl) async {
    try {
      final response = await _dio.put(
        'api/households/events/notifications/$itemId',
        data: notification.toJson(appriseUrl: appriseUrl),
      );
      return EventNotification.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to update event notification: ${e.response?.data ?? e.message}');
    }
  }

  Future<void> deleteEventNotification(String itemId) async {
    try {
      await _dio.delete('api/households/events/notifications/$itemId');
    } on DioException catch (e) {
      throw Exception('Failed to delete event notification: ${e.response?.data ?? e.message}');
    }
  }

  /// Triggers a test notification for the given event notification ID.
  ///
  /// A successful request will return a 204 No Content response.
  /// Throws an [Exception] if the request fails.
  Future<void> testEventNotification(String itemId) async {
    try {
      await _dio.post('api/households/events/notifications/$itemId/test');
    } on DioException catch (e) {
      throw Exception('Failed to test event notification: ${e.response?.data ?? e.message}');
    }
  }

  Future<RecipeActionResponse> getRecipeActions(int page, int perPage) async {
    try {
      final response = await _dio.get(
        'api/households/recipe-actions',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return RecipeActionResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to get recipe actions: ${e.message}');
    }
  }

  Future<HouseholdSelf> getSelfHousehold() async {
    try {
      final response = await _dio.get('api/households/self');
      return HouseholdSelf.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to get self household data: ${e.response?.data ?? e.message}');
    }
  }

  Future<RecipeStatus> getRecipeStatus(String recipeSlug) async {
    try {
      final response = await _dio.get('api/households/self/recipes/$recipeSlug');
      return RecipeStatus.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to get recipe status: ${e.response?.data ?? e.message}');
    }
  }

  Future<HouseholdMemberResponse> getHouseholdMembers(int page, int perPage) async {
    try {
      final response = await _dio.get(
        'api/households/members',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return HouseholdMemberResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to get household members: ${e.message}');
    }
  }

  Future<HouseholdPreferences> getHouseholdPreferences() async {
    try {
      final response = await _dio.get('api/households/preferences');
      return HouseholdPreferences.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to get household preferences: ${e.response?.data ?? e.message}');
    }
  }

  Future<HouseholdPreferences> updateHouseholdPreferences(HouseholdPreferences preferences) async {
    try {
      final response = await _dio.put(
        'api/households/preferences',
        data: preferences.toJson(),
      );
      return HouseholdPreferences.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to update household preferences: ${e.response?.data ?? e.message}');
    }
  }

  Future<HouseholdMember> updateHouseholdPermissions(HouseholdPermissions permissions) async {
    try {
      final response = await _dio.put(
        'api/households/permissions',
        data: permissions.toJson(),
      );
      return HouseholdMember.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to update household permissions: ${e.response?.data ?? e.message}');
    }
  }

  Future<HouseholdStatistics> getHouseholdStatistics() async {
    try {
      final response = await _dio.get('api/households/statistics');
      return HouseholdStatistics.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to get household statistics: ${e.response?.data ?? e.message}');
    }
  }

  Future<List<HouseholdInvitation>> getHouseholdInvitations() async {
    try {
      final response = await _dio.get('api/households/invitations');
      final List<dynamic> data = response.data;
      return data.map((json) => HouseholdInvitation.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to get household invitations: ${e.response?.data ?? e.message}');
    }
  }

  Future<HouseholdInvitation> createHouseholdInvitation({
    required int uses,
    required String groupId,
    required String householdId,
  }) async {
    try {
      final response = await _dio.post(
        'api/households/invitations',
        data: {
          'uses': uses,
          'groupId': groupId,
          'householdId': householdId,
        },
      );
      return HouseholdInvitation.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to create household invitation: ${e.response?.data ?? e.message}');
    }
  }

  Future<EmailInvitationResponse> sendInvitationEmail({
    required String email,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        'api/households/invitations/email',
        data: {
          'email': email,
          'token': token,
        },
      );
      return EmailInvitationResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to send invitation email: ${e.response?.data ?? e.message}');
    }
  }

  Future<ShoppingListResponse> getShoppingLists(int page, int perPage) async {
    try {
      final response = await _dio.get(
        'api/households/shopping/lists',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return ShoppingListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to get shopping lists: ${e.message}');
    }
  }

  Future<ShoppingList> createShoppingList({
    required String name,
    Map<String, dynamic>? extras,
  }) async {
    try {
      final response = await _dio.post(
        'api/households/shopping/lists',
        data: {
          'name': name,
          'extras': extras ?? {},
        },
      );
      return ShoppingList.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to create shopping list: ${e.response?.data ?? e.message}');
    }
  }

  Future<ShoppingList> getShoppingList(String itemId) async {
    try {
      final response = await _dio.get('api/households/shopping/lists/$itemId');
      return ShoppingList.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to get shopping list: ${e.response?.data ?? e.message}');
    }
  }

  Future<ShoppingList> updateShoppingList(String itemId, ShoppingList shoppingList) async {
    try {
      final response = await _dio.put(
        'api/households/shopping/lists/$itemId',
        data: shoppingList.toJson(),
      );
      return ShoppingList.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to update shopping list: ${e.response?.data ?? e.message}');
    }
  }

  Future<ShoppingList> deleteShoppingList(String itemId) async {
    try {
      final response = await _dio.delete('api/households/shopping/lists/$itemId');
      return ShoppingList.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to delete shopping list: ${e.response?.data ?? e.message}');
    }
  }

  Future<ShoppingList> updateShoppingListLabelSettings(
      String itemId, List<ShoppingListLabelSetting> labelSettings) async {
    try {
      final response = await _dio.put(
        'api/households/shopping/lists/$itemId/label-settings',
        data: labelSettings.map((s) => s.toJson()).toList(),
      );
      return ShoppingList.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to update shopping list label settings: ${e.response?.data ?? e.message}');
    }
  }

  Future<ShoppingList> addRecipeToShoppingList(
      String itemId, List<AddRecipeToListPayload> payload) async {
    try {
      final response = await _dio.post(
        'api/households/shopping/lists/$itemId/recipe',
        data: payload.map((p) => p.toJson()).toList(),
      );
      return ShoppingList.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to add recipe to shopping list: ${e.response?.data ?? e.message}');
    }
  }

  Future<ShoppingList> removeRecipeFromShoppingList({
    required String itemId,
    required String recipeId,
    required int recipeDecrementQuantity,
  }) async {
    try {
      final response = await _dio.post(
        'api/households/shopping/lists/$itemId/recipe/$recipeId/delete',
        data: {'recipeDecrementQuantity': recipeDecrementQuantity},
      );
      return ShoppingList.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to remove recipe from shopping list: ${e.response?.data ?? e.message}');
    }
  }

  Future<ShoppingItemResponse> getShoppingItems(int page, int perPage) async {
    try {
      final response = await _dio.get(
        'api/households/shopping/items',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return ShoppingItemResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to get shopping items: ${e.message}');
    }
  }

  Future<CreateShoppingItemResponse> createShoppingItem(ShoppingItem shoppingItem) async {
    try {
      final response = await _dio.post(
        'api/households/shopping/items',
        data: shoppingItem.toJson(),
      );
      return CreateShoppingItemResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to create shopping item: ${e.response?.data ?? e.message}');
    }
  }

  Future<CreateShoppingItemResponse> updateShoppingItems(List<ShoppingItem> shoppingItems) async {
    try {
      final response = await _dio.put(
        'api/households/shopping/items',
        data: shoppingItems.map((item) => item.toJson()).toList(),
      );
      return CreateShoppingItemResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to update shopping items: ${e.response?.data ?? e.message}');
    }
  }

  Future<DeleteResponse> deleteShoppingItems(List<String> itemIds) async {
    try {
      final response = await _dio.delete(
        'api/households/shopping/items',
        data: itemIds,
      );
      return DeleteResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to delete shopping items: ${e.response?.data ?? e.message}');
    }
  }

  Future<CreateShoppingItemResponse> createShoppingItemsBulk(List<ShoppingItem> shoppingItems) async {
    try {
      final response = await _dio.post(
        'api/households/shopping/items/create-bulk',
        data: shoppingItems.map((item) => item.toJson()).toList(),
      );
      return CreateShoppingItemResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to create shopping items in bulk: ${e.response?.data ?? e.message}');
    }
  }

  Future<ShoppingItem> getShoppingItem(String itemId) async {
    try {
      final response = await _dio.get('api/households/shopping/items/$itemId');
      return ShoppingItem.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to get shopping item: ${e.response?.data ?? e.message}');
    }
  }

  Future<CreateShoppingItemResponse> updateShoppingItem(String itemId, ShoppingItem shoppingItem) async {
    try {
      final response = await _dio.put(
        'api/households/shopping/items/$itemId',
        data: shoppingItem.toJson(),
      );
      return CreateShoppingItemResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to update shopping item: ${e.response?.data ?? e.message}');
    }
  }

  Future<DeleteResponse> deleteShoppingItem(String itemId) async {
    try {
      final response = await _dio.delete('api/households/shopping/items/$itemId');
      return DeleteResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to delete shopping item: ${e.response?.data ?? e.message}');
    }
  }

  Future<HouseholdWebhookResponse> getHouseholdWebhooks(int page, int perPage) async {
    try {
      final response = await _dio.get(
        'api/households/webhooks',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return HouseholdWebhookResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to get household webhooks: ${e.message}');
    }
  }

  Future<HouseholdWebhook> createHouseholdWebhook({
    required bool enabled,
    required String name,
    required String url,
    required String webhookType,
    String? scheduledTime,
  }) async {
    try {
      final response = await _dio.post(
        'api/households/webhooks',
        data: {
          'enabled': enabled,
          'name': name,
          'url': url,
          'webhookType': webhookType,
          'scheduledTime': scheduledTime,
        },
      );
      return HouseholdWebhook.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to create household webhook: ${e.response?.data ?? e.message}');
    }
  }

  Future<HouseholdWebhook> updateHouseholdWebhook(String itemId, HouseholdWebhook webhook) async {
    try {
      final response = await _dio.put(
        'api/households/webhooks/$itemId',
        data: webhook.toJson(),
      );
      return HouseholdWebhook.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to update household webhook: ${e.response?.data ?? e.message}');
    }
  }

  Future<HouseholdWebhook> deleteHouseholdWebhook(String itemId) async {
    try {
      final response = await _dio.delete('api/households/webhooks/$itemId');
      return HouseholdWebhook.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to delete household webhook: ${e.response?.data ?? e.message}');
    }
  }

  Future<void> rerunWebhooks() async {
    try {
      await _dio.post('api/households/webhooks/rerun');
    } on DioException catch (e) {
      throw Exception('Failed to rerun webhooks: ${e.response?.data ?? e.message}');
    }
  }

  Future<void> testHouseholdWebhook(String itemId) async {
    try {
      await _dio.post('api/households/webhooks/$itemId/test');
    } on DioException catch (e) {
      throw Exception('Failed to test household webhook: ${e.response?.data ?? e.message}');
    }
  }

  Future<MealplanRuleResponse> getMealplanRules(int page, int perPage) async {
    try {
      final response = await _dio.get(
        'api/households/mealplans/rules',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return MealplanRuleResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to get mealplan rules: ${e.message}');
    }
  }

  Future<MealplanRule> createMealplanRule({
    required String day,
    required String entryType,
    String? queryFilterString,
  }) async {
    try {
      final response = await _dio.post(
        'api/households/mealplans/rules',
        data: {
          'day': day,
          'entryType': entryType,
          'queryFilterString': queryFilterString ?? '',
        },
      );
      return MealplanRule.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to create mealplan rule: ${e.response?.data ?? e.message}');
    }
  }

  Future<MealplanRule> getMealplanRule(String itemId) async {
    try {
      final response = await _dio.get('api/households/mealplans/rules/$itemId');
      return MealplanRule.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to get mealplan rule: ${e.response?.data ?? e.message}');
    }
  }

  Future<MealplanRule> updateMealplanRule(String itemId, MealplanRule rule) async {
    try {
      final response = await _dio.put(
        'api/households/mealplans/rules/$itemId',
        data: rule.toJson(),
      );
      return MealplanRule.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to update mealplan rule: ${e.response?.data ?? e.message}');
    }
  }

  Future<MealplanRule> deleteMealplanRule(String itemId) async {
    try {
      final response = await _dio.delete('api/households/mealplans/rules/$itemId');
      return MealplanRule.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to delete mealplan rule: ${e.response?.data ?? e.message}');
    }
  }

  Future<MealplanResponse> getMealplans(int page, int perPage) async {
    try {
      final response = await _dio.get(
        'api/households/mealplans',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return MealplanResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to get mealplans: ${e.message}');
    }
  }

  Future<MealplanEntry> createMealplan(MealplanEntry entry) async {
    try {
      final response = await _dio.post(
        'api/households/mealplans',
        data: entry.toJson(),
      );
      return MealplanEntry.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to create mealplan entry: ${e.response?.data ?? e.message}');
    }
  }

  Future<MealplanEntry> getRandomMealplanEntry({
    required String date,
    required String entryType,
  }) async {
    try {
      final response = await _dio.post(
        'api/households/mealplans/random',
        data: {
          'date': date,
          'entryType': entryType,
        },
      );
      return MealplanEntry.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to get random mealplan entry: ${e.response?.data ?? e.message}');
    }
  }

  Future<MealplanEntry> getMealplan(String itemId) async {
    try {
      final response = await _dio.get('api/households/mealplans/$itemId');
      return MealplanEntry.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to get mealplan entry: ${e.response?.data ?? e.message}');
    }
  }

  Future<MealplanEntry> updateMealplan(String itemId, MealplanEntry entry) async {
    try {
      final response = await _dio.put(
        'api/households/mealplans/$itemId',
        data: entry.toJson(),
      );
      return MealplanEntry.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to update mealplan entry: ${e.response?.data ?? e.message}');
    }
  }
}
