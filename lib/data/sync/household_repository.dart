import 'package:dio/dio.dart';
import 'package:mealique/data/local/household_storage.dart';
import 'package:mealique/data/remote/api_exceptions.dart';
import 'package:mealique/data/remote/household_api.dart';
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

  Future<List<ShoppingList>> getShoppingListsWithItemCount() async {
    final response = await _api.getShoppingLists(1, 100);
    final lists = response.items;
    final listsWithCount = <ShoppingList>[];

    for (var list in lists) {
      final items = await getItemsForList(list.id);
      final uncheckedItemsCount = items.where((item) => !item.checked).length;
      listsWithCount.add(list.copyWith(itemCount: uncheckedItemsCount));
    }

    return listsWithCount;
  }

  Future<void> createShoppingList(String name) async {
    await _api.createShoppingList(name: name);
    await syncShoppingLists(); // Sync after creation
  }

  Future<void> deleteShoppingList(String id) async {
    await _api.deleteShoppingList(id);
    await syncShoppingLists(); // Sync after deletion
  }

  // --- UI Helper Methods (Shopping Items) ---

  Future<List<ShoppingItem>> getItemsForList(String listId) async {
    try {
      final list = await _api.getShoppingList(listId);
      await _storage.saveShoppingLists([list]); // Update cache
      return list.listItems;
    } on DioException catch (e) {
      // Only fall back to cache on specific network errors
      if (e.error is NetworkException) {
        final lists = await _storage.getShoppingLists();
        if (lists != null) {
          final list = lists.firstWhere((l) => l.id == listId, orElse: () => throw Exception('List not found in cache'));
          return list.listItems;
        }
      } 
      // Re-throw other errors to be displayed in the UI
      rethrow;
    }
  }

  Future<void> addItem(String listId, String name) async {
    final item = ShoppingItem(
      id: '', // ID is set by the server
      shoppingListId: listId,
      display: name,
      note: '',
      quantity: 1.0,
      checked: false,
      position: 0,
    );
    await _api.createShoppingItem(item);
  }

  Future<void> updateItem(ShoppingItem item) async {
    if (item.id.isNotEmpty) {
      await _api.updateShoppingItem(item.id, item);
    }
  }

  Future<void> deleteItem(String itemId) async {
    await _api.deleteShoppingItem(itemId);
  }

  // --- Sync Logic ---

  Future<void> syncAll() async {
    await Future.wait([
      syncShoppingLists(),
      // Add other sync methods here if needed
    ]);
  }

  Future<void> syncShoppingLists() async {
    try {
      final listResponse = await _api.getShoppingLists(1, 100);
      final remoteListsRaw = listResponse.items;
      await _storage.saveShoppingLists(remoteListsRaw);
    } catch (e) {
      // Silently fail sync, as UI might be showing cached data
    }
  }
}
