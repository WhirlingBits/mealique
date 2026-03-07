import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mealique/config/app_constants.dart';
import 'package:mealique/data/local/household_storage.dart';
import 'package:mealique/data/local/token_storage.dart';
import 'package:mealique/data/remote/api_exceptions.dart';
import 'package:mealique/data/remote/household_api.dart';
import 'package:mealique/models/shopping_item_model.dart';
import 'package:mealique/models/shopping_list_model.dart';

class HouseholdRepository {
  final HouseholdApi _api;
  final HouseholdStorage _storage;
  final TokenStorage _tokenStorage;

  final Map<String, List<ShoppingItem>> _demoShoppingItems = {
    '1': [
      ShoppingItem(id: '101', shoppingListId: '1', display: 'Milk', note: 'Fresh whole milk', quantity: 1, checked: false, position: 0),
      ShoppingItem(id: '102', shoppingListId: '1', display: 'Bread', note: '', quantity: 1, checked: false, position: 1),
      ShoppingItem(id: '103', shoppingListId: '1', display: 'Eggs', note: 'Organic, 10-pack', quantity: 10, checked: true, position: 2),
    ],
    '2': [
      ShoppingItem(id: '201', shoppingListId: '2', display: 'Sausages', note: 'German style', quantity: 8, checked: false, position: 0),
      ShoppingItem(id: '202', shoppingListId: '2', display: 'Ketchup', note: '', quantity: 1, checked: true, position: 1),
    ],
  };

  static final HouseholdRepository _instance = HouseholdRepository._internal();

  factory HouseholdRepository() {
    return _instance;
  }

  HouseholdRepository._internal()
      : _api = HouseholdApi(),
        _storage = HouseholdStorage(),
        _tokenStorage = TokenStorage();

  Future<List<ShoppingList>> getShoppingLists({String? orderBy, String? orderDirection}) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return _getDemoShoppingLists();
    }

    try {
      final response = await _api.getShoppingLists(1, 100, orderBy: orderBy, orderDirection: orderDirection);
      return response.items;
    } on DioException catch (e) {
      if (e.error is NetworkException) {
        final localLists = await _storage.getShoppingLists();
        if (localLists != null && localLists.isNotEmpty) return localLists;
      }
      rethrow;
    }
  }
   Future<List<ShoppingList>> getShoppingListsWithItemCount({String? orderBy, String? orderDirection}) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return _getDemoShoppingLists();
    }

    final response = await _api.getShoppingLists(1, 100, orderBy: orderBy, orderDirection: orderDirection);
    final lists = response.items;
    final listsWithCount = <ShoppingList>[];

    for (var list in lists) {
      try {
        final items = await getItemsForList(list.id);
        final uncheckedItemsCount = items.where((item) => !item.checked).length;
        listsWithCount.add(list.copyWith(itemCount: uncheckedItemsCount));
      } catch (e) {
        listsWithCount.add(list.copyWith(itemCount: 0));
      }
    }
    return listsWithCount;
  }


  Future<void> createShoppingList(String name) async {
     final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) return;
    await _api.createShoppingList(name: name);
  }

  Future<void> deleteShoppingList(String id) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) return;
    await _api.deleteShoppingList(id);
  }

  Future<void> updateShoppingListName(String listId, String newName) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) return;
    final list = await _api.getShoppingList(listId);
    final updatedList = list.copyWith(name: newName);
    await _api.updateShoppingList(list.id, updatedList);
    // Sync label-settings via dedicated endpoint
    if (list.labelSettings.isNotEmpty) {
      await _api.updateShoppingListLabelSettings(list.id, list.labelSettings);
    }
  }

  /// Update label settings for a shopping list using the dedicated
  /// /api/households/shopping/lists/{item_id}/label-settings endpoint.
  Future<ShoppingList> updateShoppingListLabelSettings(
      String listId, List<ShoppingListLabelSetting> labelSettings) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return _getDemoShoppingLists().firstWhere((l) => l.id == listId);
    }
    return await _api.updateShoppingListLabelSettings(listId, labelSettings);
  }

  Future<List<ShoppingItem>> getItemsForList(String listId) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return _demoShoppingItems[listId] ?? [];
    }

    final list = await _api.getShoppingList(listId);
    return list.listItems;
  }

  Future<void> createShoppingItem({
    required String listId,
    required String foodId,
    required String foodName,
    required double quantity,
    String? note,
    String? unitId,
    String? categoryId,
  }) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      final newItem = ShoppingItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        shoppingListId: listId,
        foodId: foodId,
        display: foodName,
        quantity: quantity,
        note: note ?? '',
        unitId: unitId,
        labelId: categoryId,
        checked: false,
        position: (_demoShoppingItems[listId]?.length ?? 0),
      );
      final currentItems = _demoShoppingItems[listId] ?? [];
      _demoShoppingItems[listId] = [...currentItems, newItem];
      return;
    }

    final item = ShoppingItem(
      id: '',
      shoppingListId: listId,
      foodId: foodId,
      food: ShoppingItemFood(id: foodId, name: foodName),
      unit: unitId != null && unitId.isNotEmpty ? ShoppingItemUnit(id: unitId, name: '') : null,
      unitId: unitId,
      labelId: categoryId,
      quantity: quantity,
      note: note ?? '',
      display: '',
      checked: false,
      position: 0,
    );
    debugPrint('Creating shopping item JSON: ${item.toJson()}');
    try {
      final result = await _api.createShoppingItem(item);
      debugPrint('Shopping item created successfully: ${result.id}');
    } on DioException catch (e) {
      debugPrint('DioException creating item: type=${e.type}, statusCode=${e.response?.statusCode}, data=${e.response?.data}, error=${e.error}');
      rethrow;
    }
  }

  Future<void> updateItem(ShoppingItem item) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      final listId = item.shoppingListId;
      final items = _demoShoppingItems[listId];
      if (items == null) return;

      final index = items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        final newItems = List<ShoppingItem>.from(items);
        newItems[index] = item;
        _demoShoppingItems[listId] = newItems;
      }
      return;
    }
    await _api.updateShoppingItem(item.id, item);
  }

  Future<void> deleteItem(String itemId) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
       for (var list in _demoShoppingItems.values) {
        list.removeWhere((item) => item.id == itemId);
      } 
      return;
    }
    await _api.deleteShoppingItem(itemId);
  }

  List<ShoppingList> _getDemoShoppingLists() {
    return [
      ShoppingList(id: '1', name: 'Weekly Groceries', itemCount: _demoShoppingItems['1']?.where((i) => !i.checked).length ?? 0, extras: {}, createdAt: DateTime.now().toIso8601String(), updatedAt: DateTime.now().toIso8601String(), recipeReferences: [], labelSettings: [], listItems: []),
      ShoppingList(id: '2', name: 'BBQ Party', itemCount: _demoShoppingItems['2']?.where((i) => !i.checked).length ?? 0, extras: {}, createdAt: DateTime.now().toIso8601String(), updatedAt: DateTime.now().toIso8601String(), recipeReferences: [], labelSettings: [], listItems: []),
    ];
  }
}
