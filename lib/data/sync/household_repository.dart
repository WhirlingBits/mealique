import 'package:dio/dio.dart';
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

  HouseholdRepository({HouseholdApi? api, HouseholdStorage? storage})
      : _api = api ?? HouseholdApi(),
        _storage = storage ?? HouseholdStorage(),
        _tokenStorage = TokenStorage();

  // --- UI Helper Methods (Shopping Lists) ---

  Future<List<ShoppingList>> getShoppingLists() async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return _getDemoShoppingLists();
    }

    try {
      final response = await _api.getShoppingLists(1, 100);
      final remoteLists = response.items;
      await _storage.saveShoppingLists(remoteLists);
      return remoteLists;
    } on DioException catch (e) {
      if (e.error is NetworkException) {
        final localLists = await _storage.getShoppingLists();
        if (localLists != null && localLists.isNotEmpty) {
          return localLists;
        }
      }
      rethrow;
    }
  }

  Future<List<ShoppingList>> getShoppingListsWithItemCount() async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return _getDemoShoppingLists();
    }

    final response = await _api.getShoppingLists(1, 100);
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
    // No-op in demo mode
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) return;

    await _api.createShoppingList(name: name);
    await syncShoppingLists(); // Sync after creation
  }

  Future<void> deleteShoppingList(String id) async {
    // No-op in demo mode
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) return;

    await _api.deleteShoppingList(id);
    await syncShoppingLists(); // Sync after deletion
  }

  // --- UI Helper Methods (Shopping Items) ---

  Future<List<ShoppingItem>> getItemsForList(String listId) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return _getDemoShoppingItemsForList(listId);
    }

    try {
      final list = await _api.getShoppingList(listId);
      await _storage.saveShoppingLists([list]); // Update cache
      return list.listItems;
    } on DioException catch (e) {
      if (e.error is NetworkException) {
        final lists = await _storage.getShoppingLists();
        if (lists != null) {
          final list = lists.firstWhere((l) => l.id == listId, orElse: () => throw Exception('List not found in cache'));
          return list.listItems;
        }
      }
      rethrow;
    }
  }

  Future<void> addItem(String listId, String name) async {
    // No-op in demo mode
  }

  Future<void> updateItem(ShoppingItem item) async {
     // No-op in demo mode
  }

  Future<void> deleteItem(String itemId) async {
     // No-op in demo mode
  }


  // --- Sync Logic ---

  Future<void> syncAll() async {
     // No-op in demo mode
  }

  Future<void> syncShoppingLists() async {
     // No-op in demo mode
  }

  // --- DEMO DATA HELPERS ---

  List<ShoppingList> _getDemoShoppingLists() {
    return [
      ShoppingList(
        id: '1',
        name: 'Weekly Groceries',
        itemCount: 2, 
        extras: {},
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        recipeReferences: [],
        labelSettings: [],
        listItems: [],
      ),
      ShoppingList(
        id: '2',
        name: 'BBQ Party',
        itemCount: 1,
        extras: {},
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        recipeReferences: [],
        labelSettings: [],
        listItems: [],
      ),
    ];
  }

  List<ShoppingItem> _getDemoShoppingItemsForList(String listId) {
    final allItems = {
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
    return allItems[listId] ?? [];
  }
}
