import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:mealique/data/remote/dio_client.dart';
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
        _dio = DioClient.createDio() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (options.baseUrl.isEmpty) {
          final serverUrl = await _tokenStorage.getServerUrl();
          if (serverUrl != null && serverUrl.isNotEmpty) {
            options.baseUrl = serverUrl.endsWith('/') ? serverUrl : '$serverUrl/';
          }
        }

        final token = await _tokenStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        handler.next(options);
      },
    ));
  }

  Future<CookbookResponse> getCookbooks(int page, int perPage) async {
    final response = await _dio.get(
      'api/households/cookbooks',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    return CookbookResponse.fromJson(response.data);
  }

  Future<Cookbook> createCookbook({
    required String name,
    String? description,
    required String slug,
    required int position,
    bool public = false,
    String? queryFilterString,
  }) async {
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
  }

  Future<Cookbook> getCookbook(String itemId) async {
    final response = await _dio.get('api/households/cookbooks/$itemId');
    return Cookbook.fromJson(response.data);
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
  }

  Future<void> deleteCookbook(String itemId) async {
    await _dio.delete('api/households/cookbooks/$itemId');
  }

  Future<EventNotification> createEventNotification({
    required String name,
    required String appriseUrl,
  }) async {
    final response = await _dio.post(
      'api/households/events/notifications',
      data: {
        'name': name,
        'appriseUrl': appriseUrl,
      },
    );
    return EventNotification.fromJson(response.data);
  }

  Future<EventNotification> getEventNotification(String itemId) async {
    final response = await _dio.get('api/households/events/notifications/$itemId');
    return EventNotification.fromJson(response.data);
  }

  Future<EventNotification> updateEventNotification(String itemId, EventNotification notification, String appriseUrl) async {
    final response = await _dio.put(
      'api/households/events/notifications/$itemId',
      data: notification.toJson(appriseUrl: appriseUrl),
    );
    return EventNotification.fromJson(response.data);
  }

  Future<void> deleteEventNotification(String itemId) async {
    await _dio.delete('api/households/events/notifications/$itemId');
  }

  Future<void> testEventNotification(String itemId) async {
    await _dio.post('api/households/events/notifications/$itemId/test');
  }

  Future<RecipeActionResponse> getRecipeActions(int page, int perPage) async {
    final response = await _dio.get(
      'api/households/recipe-actions',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    return RecipeActionResponse.fromJson(response.data);
  }

  Future<HouseholdSelf> getSelfHousehold() async {
    final response = await _dio.get('api/households/self');
    return HouseholdSelf.fromJson(response.data);
  }

  Future<RecipeStatus> getRecipeStatus(String recipeSlug) async {
    final response = await _dio.get('api/households/self/recipes/$recipeSlug');
    return RecipeStatus.fromJson(response.data);
  }

  Future<HouseholdMemberResponse> getHouseholdMembers(int page, int perPage) async {
    final response = await _dio.get(
      'api/households/members',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    return HouseholdMemberResponse.fromJson(response.data);
  }

  Future<HouseholdPreferences> getHouseholdPreferences() async {
    final response = await _dio.get('api/households/preferences');
    return HouseholdPreferences.fromJson(response.data);
  }

  Future<HouseholdPreferences> updateHouseholdPreferences(HouseholdPreferences preferences) async {
    final response = await _dio.put(
      'api/households/preferences',
      data: preferences.toJson(),
    );
    return HouseholdPreferences.fromJson(response.data);
  }

  Future<HouseholdMember> updateHouseholdPermissions(HouseholdPermissions permissions) async {
    final response = await _dio.put(
      'api/households/permissions',
      data: permissions.toJson(),
    );
    return HouseholdMember.fromJson(response.data);
  }

  Future<HouseholdStatistics> getHouseholdStatistics() async {
    final response = await _dio.get('api/households/statistics');
    return HouseholdStatistics.fromJson(response.data);
  }

  Future<List<HouseholdInvitation>> getHouseholdInvitations() async {
    final response = await _dio.get('api/households/invitations');
    final List<dynamic> data = response.data;
    return data.map((json) => HouseholdInvitation.fromJson(json)).toList();
  }

  Future<HouseholdInvitation> createHouseholdInvitation({
    required int uses,
    required String groupId,
    required String householdId,
  }) async {
    final response = await _dio.post(
      'api/households/invitations',
      data: {
        'uses': uses,
        'groupId': groupId,
        'householdId': householdId,
      },
    );
    return HouseholdInvitation.fromJson(response.data);
  }

  Future<EmailInvitationResponse> sendInvitationEmail({
    required String email,
    required String token,
  }) async {
    final response = await _dio.post(
      'api/households/invitations/email',
      data: {
        'email': email,
        'token': token,
      },
    );
    return EmailInvitationResponse.fromJson(response.data);
  }

  Future<ShoppingListResponse> getShoppingLists(int page, int perPage) async {
    final response = await _dio.get(
      'api/households/shopping/lists',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    return ShoppingListResponse.fromJson(response.data);
  }

  Future<ShoppingList> createShoppingList({
    required String name,
    Map<String, dynamic>? extras,
  }) async {
    final response = await _dio.post(
      'api/households/shopping/lists',
      data: {
        'name': name,
        'extras': extras ?? {},
      },
    );
    return ShoppingList.fromJson(response.data);
  }

  Future<ShoppingList> getShoppingList(String itemId) async {
    final response = await _dio.get('api/households/shopping/lists/$itemId');
    return ShoppingList.fromJson(response.data);
  }

  Future<ShoppingList> updateShoppingList(String itemId, ShoppingList shoppingList) async {
    final response = await _dio.put(
      'api/households/shopping/lists/$itemId',
      data: shoppingList.toJson(),
    );
    return ShoppingList.fromJson(response.data);
  }

  Future<ShoppingList> deleteShoppingList(String itemId) async {
    final response = await _dio.delete('api/households/shopping/lists/$itemId');
    return ShoppingList.fromJson(response.data);
  }

  Future<ShoppingList> updateShoppingListLabelSettings(
      String itemId, List<ShoppingListLabelSetting> labelSettings) async {
    final response = await _dio.put(
      'api/households/shopping/lists/$itemId/label-settings',
      data: labelSettings.map((s) => s.toJson()).toList(),
    );
    return ShoppingList.fromJson(response.data);
  }

  Future<ShoppingList> addRecipeToShoppingList(
      String itemId, List<AddRecipeToListPayload> payload) async {
    final response = await _dio.post(
      'api/households/shopping/lists/$itemId/recipe',
      data: payload.map((p) => p.toJson()).toList(),
    );
    return ShoppingList.fromJson(response.data);
  }

  Future<ShoppingList> removeRecipeFromShoppingList({
    required String itemId,
    required String recipeId,
    required int recipeDecrementQuantity,
  }) async {
    final response = await _dio.post(
      'api/households/shopping/lists/$itemId/recipe/$recipeId/delete',
      data: {'recipeDecrementQuantity': recipeDecrementQuantity},
    );
    return ShoppingList.fromJson(response.data);
  }

  Future<ShoppingItemResponse> getShoppingItems(int page, int perPage) async {
    final response = await _dio.get(
      'api/households/shopping/items',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    return ShoppingItemResponse.fromJson(response.data);
  }

  Future<CreateShoppingItemResponse> createShoppingItem(ShoppingItem shoppingItem) async {
    final response = await _dio.post(
      'api/households/shopping/items',
      data: shoppingItem.toJson(),
    );
    return CreateShoppingItemResponse.fromJson(response.data);
  }

  Future<CreateShoppingItemResponse> updateShoppingItems(List<ShoppingItem> shoppingItems) async {
    final response = await _dio.put(
      'api/households/shopping/items',
      data: shoppingItems.map((item) => item.toJson()).toList(),
    );
    return CreateShoppingItemResponse.fromJson(response.data);
  }

  Future<DeleteResponse> deleteShoppingItems(List<String> itemIds) async {
    final response = await _dio.delete(
      'api/households/shopping/items',
      data: itemIds,
    );
    return DeleteResponse.fromJson(response.data);
  }

  Future<CreateShoppingItemResponse> createShoppingItemsBulk(List<ShoppingItem> shoppingItems) async {
    final response = await _dio.post(
      'api/households/shopping/items/create-bulk',
      data: shoppingItems.map((item) => item.toJson()).toList(),
    );
    return CreateShoppingItemResponse.fromJson(response.data);
  }

  Future<ShoppingItem> getShoppingItem(String itemId) async {
    final response = await _dio.get('api/households/shopping/items/$itemId');
    return ShoppingItem.fromJson(response.data);
  }

  Future<CreateShoppingItemResponse> updateShoppingItem(String itemId, ShoppingItem shoppingItem) async {
    final response = await _dio.put(
      'api/households/shopping/items/$itemId',
      data: shoppingItem.toJson(),
    );
    return CreateShoppingItemResponse.fromJson(response.data);
  }

  Future<DeleteResponse> deleteShoppingItem(String itemId) async {
    final response = await _dio.delete('api/households/shopping/items/$itemId');
    return DeleteResponse.fromJson(response.data);
  }

  Future<HouseholdWebhookResponse> getHouseholdWebhooks(int page, int perPage) async {
    final response = await _dio.get(
      'api/households/webhooks',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    return HouseholdWebhookResponse.fromJson(response.data);
  }

  Future<HouseholdWebhook> createHouseholdWebhook({
    required bool enabled,
    required String name,
    required String url,
    required String webhookType,
    String? scheduledTime,
  }) async {
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
  }

  Future<HouseholdWebhook> updateHouseholdWebhook(String itemId, HouseholdWebhook webhook) async {
    final response = await _dio.put(
      'api/households/webhooks/$itemId',
      data: webhook.toJson(),
    );
    return HouseholdWebhook.fromJson(response.data);
  }

  Future<HouseholdWebhook> deleteHouseholdWebhook(String itemId) async {
    final response = await _dio.delete('api/households/webhooks/$itemId');
    return HouseholdWebhook.fromJson(response.data);
  }

  Future<void> rerunWebhooks() async {
    await _dio.post('api/households/webhooks/rerun');
  }

  Future<void> testHouseholdWebhook(String itemId) async {
    await _dio.post('api/households/webhooks/$itemId/test');
  }

  Future<MealplanRuleResponse> getMealplanRules(int page, int perPage) async {
    final response = await _dio.get(
      'api/households/mealplans/rules',
      queryParameters: {'page': page, 'per_page': perPage},
    );
    return MealplanRuleResponse.fromJson(response.data);
  }

  Future<MealplanRule> createMealplanRule({
    required String day,
    required String entryType,
    String? queryFilterString,
  }) async {
    final response = await _dio.post(
      'api/households/mealplans/rules',
      data: {
        'day': day,
        'entryType': entryType,
        'queryFilterString': queryFilterString ?? '',
      },
    );
    return MealplanRule.fromJson(response.data);
  }

  Future<MealplanRule> getMealplanRule(String itemId) async {
    final response = await _dio.get('api/households/mealplans/rules/$itemId');
    return MealplanRule.fromJson(response.data);
  }

  Future<MealplanRule> updateMealplanRule(String itemId, MealplanRule rule) async {
    final response = await _dio.put(
      'api/households/mealplans/rules/$itemId',
      data: rule.toJson(),
    );
    return MealplanRule.fromJson(response.data);
  }

  Future<MealplanRule> deleteMealplanRule(String itemId) async {
    final response = await _dio.delete('api/households/mealplans/rules/$itemId');
    return MealplanRule.fromJson(response.data);
  }

  Future<MealplanResponse> getMealplans(
    int page, int perPage, {DateTime? startDate, DateTime? endDate}) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (startDate != null) {
      queryParameters['start_date'] = DateFormat('yyyy-MM-dd').format(startDate);
    }
    if (endDate != null) {
      queryParameters['end_date'] = DateFormat('yyyy-MM-dd').format(endDate);
    }

    final response = await _dio.get(
      'api/households/mealplans',
      queryParameters: queryParameters,
    );
    return MealplanResponse.fromJson(response.data);
  }

  Future<MealplanEntry> createMealplan(MealplanEntry entry) async {
    final response = await _dio.post(
      'api/households/mealplans',
      data: entry.toJson(),
    );
    return MealplanEntry.fromJson(response.data);
  }

  Future<MealplanEntry> getRandomMealplanEntry({
    required String date,
    required String entryType,
  }) async {
    final response = await _dio.post(
      'api/households/mealplans/random',
      data: {
        'date': date,
        'entryType': entryType,
      },
    );
    return MealplanEntry.fromJson(response.data);
  }

  Future<MealplanEntry> getMealplan(String itemId) async {
    final response = await _dio.get('api/households/mealplans/$itemId');
    return MealplanEntry.fromJson(response.data);
  }

  Future<MealplanEntry> updateMealplan(String itemId, MealplanEntry entry) async {
    final response = await _dio.put(
      'api/households/mealplans/$itemId',
      data: entry.toJson(),
    );
    return MealplanEntry.fromJson(response.data);
  }
}
