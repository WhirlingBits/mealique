import 'package:dio/dio.dart';
import 'package:mealique/data/local/household_storage.dart';
import 'package:mealique/data/remote/household_api.dart';
import 'package:mealique/models/cookbook_model.dart';
import 'package:mealique/models/mealplan_model.dart';
import 'package:mealique/models/mealplan_rule_model.dart';
import 'package:mealique/models/shopping_item_model.dart';
import 'package:mealique/models/shopping_list_model.dart';

class HouseholdRepository {
  final HouseholdApi _api;
  final HouseholdStorage _storage;

  HouseholdRepository({HouseholdApi? api, HouseholdStorage? storage})
      : _api = api ?? HouseholdApi(),
        _storage = storage ?? HouseholdStorage();

  // --- UI Helper Methods (Shopping Lists) ---

  Future<List<ShoppingList>?> getShoppingLists() async {
    // Try loading locally first
    final localLists = await _storage.getShoppingLists();

    // Sync in the background
    syncShoppingLists();

    if (localLists != null && localLists.isNotEmpty) {
      return localLists;
    }

    // If locally empty, explicitly wait for network
    try {
      final response = await _api.getShoppingLists(1, 100);
      final remoteLists = response.items;
      await _storage.saveShoppingLists(remoteLists);
      return remoteLists;
    } catch (e) {
      return null;
    }
  }

  Future<void> createShoppingList(String name) async {
    try {
      final newList = await _api.createShoppingList(name: name);
      await _storage.saveShoppingLists([newList]);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteShoppingList(String id) async {
    try {
      await _api.deleteShoppingList(id);
      syncShoppingLists();
    } catch (e) {
      rethrow;
    }
  }

  // --- UI Helper Methods (Shopping Items) ---

  /// Loads all items belonging to a specific list.
  Future<List<ShoppingItem>> getItemsForList(String listId) async {
    // 1. First, try to retrieve the specific list directly from the API to obtain the latest data.
    // This ensures that we see current items when opening the detail screen (e.g. if someone else has added something).
    try {
      final list = await _api.getShoppingList(listId);

      // Save update in cache (important!)
      // We retrieve the complete lists, but only update this one in memory.
      await _storage.saveShoppingLists([list]);

      return list.listItems;
    } catch (e) {
      // If the network fails (offline), we fall back on local storage.
      print('Network fetch failed, trying local storage: $e');
    }

    // 2. Fallback: Lokal suchen
    final lists = await _storage.getShoppingLists();
    if (lists != null) {
      try {
        final list = lists.firstWhere((l) => l.id == listId);
        return list.listItems;
      } catch (_) {
        // List not found locally either
      }
    }

    return [];
  }

  Future<void> addItem(String listId, String name) async {
    final item = ShoppingItem(
      id: '',
      shoppingListId: listId,
      display: name,
      note: '',
      quantity: 1.0,
      unit: null,
      checked: false,
      position: 0,
    );

    try {
      // API call
      await _api.createShoppingItem(item);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateItem(ShoppingItem item) async {
    try {
      if (item.id != null && item.id!.isNotEmpty) {
        await _api.updateShoppingItem(item.id!, item);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await _api.deleteShoppingItem(itemId);
    } catch (e) {
      rethrow;
    }
  }


  // --- Sync Logic ---

  Future<void> syncAll() async {
    await Future.wait([
      syncCookbooks(),
      syncShoppingLists(),
      syncMealplanRules(),
      syncMealplans(),
    ]);
  }

  // --- Cookbooks ---

  Future<void> syncCookbooks() async {
    try {
      final response = await _api.getCookbooks(1, 100);
      final remoteCookbooks = response.items;
      await _storage.saveCookbooks(remoteCookbooks);
    } catch (e) {
      print('Sync error cookbooks: $e');
    }
  }

  // --- Shopping Lists ---

  Future<void> syncShoppingLists() async {
    try {
      final listResponse = await _api.getShoppingLists(1, 100);
      final remoteListsRaw = listResponse.items;
      await _storage.saveShoppingLists(remoteListsRaw);
    } catch (e) {
      print('Sync error shopping lists: $e');
    }
  }

  // --- Mealplan Rules ---

  Future<void> syncMealplanRules() async {
    try {
      final response = await _api.getMealplanRules(1, 100);
      final remoteRules = response.items;
      await _storage.saveMealplanRules(remoteRules);
    } catch (e) {
      print('Sync error mealplan rules: $e');
    }
  }

  // --- Mealplans ---

  Future<void> syncMealplans() async {
    try {
      final response = await _api.getMealplans(1, 100);
      final remotePlans = response.items;
      await _storage.saveMealplans(remotePlans);
    } catch (e) {
      print('Sync error mealplans: $e');
    }
  }
}
