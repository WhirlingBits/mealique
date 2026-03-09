import 'package:flutter/foundation.dart';
import 'package:mealique/config/app_constants.dart';
import 'package:mealique/core/utils/offline_helper.dart';
import 'package:mealique/data/local/household_storage.dart';
import 'package:mealique/data/local/sync_queue_storage.dart';
import 'package:mealique/data/local/token_storage.dart';
import 'package:mealique/data/remote/household_api.dart';
import 'package:mealique/models/shopping_item_model.dart';
import 'package:mealique/models/shopping_list_model.dart';

class HouseholdRepository {
  final HouseholdApi _api;
  final HouseholdStorage _storage;
  final TokenStorage _tokenStorage;
  final SyncQueueStorage _syncQueue;

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
        _tokenStorage = TokenStorage(),
        _syncQueue = SyncQueueStorage();

  // ─── Shopping Lists ────────────────────────────────────────────────

  Future<List<ShoppingList>> getShoppingLists({String? orderBy, String? orderDirection}) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return _getDemoShoppingLists();
    }

    return withOfflineFallbackSimple<List<ShoppingList>>(
      apiCall: () async {
        final response = await _api.getShoppingLists(1, 100, orderBy: orderBy, orderDirection: orderDirection);
        return response.items;
      },
      cacheWrite: (lists) async {
        // Merge: preserve any cached items that were previously loaded
        final existing = await _storage.getShoppingLists();
        final existingMap = <String, List<ShoppingItem>>{};
        if (existing != null) {
          for (final l in existing) {
            if (l.listItems.isNotEmpty) {
              existingMap[l.id] = l.listItems;
            }
          }
        }
        final merged = lists.map((l) {
          final cachedItems = existingMap[l.id];
          if (cachedItems != null && l.listItems.isEmpty) {
            return l.copyWith(listItems: cachedItems);
          }
          return l;
        }).toList();
        await _storage.clearShoppingLists();
        await _storage.saveShoppingLists(merged);
      },
      cacheRead: () => _storage.getShoppingLists(),
    );
  }

  Future<List<ShoppingList>> getShoppingListsWithItemCount({String? orderBy, String? orderDirection}) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return _getDemoShoppingLists();
    }

    return withOfflineFallbackSimple<List<ShoppingList>>(
      apiCall: () async {
        final response = await _api.getShoppingLists(1, 100, orderBy: orderBy, orderDirection: orderDirection);
        final lists = response.items;
        final listsWithItems = <ShoppingList>[];

        for (var list in lists) {
          try {
            // Fetch full list with items from the detail endpoint
            final fullList = await _api.getShoppingList(list.id);
            final items = fullList.listItems;
            final uncheckedItemsCount = items.where((item) => !item.checked).length;
            listsWithItems.add(list.copyWith(
              itemCount: uncheckedItemsCount,
              listItems: items,
            ));
          } catch (e) {
            listsWithItems.add(list.copyWith(itemCount: 0));
          }
        }
        return listsWithItems;
      },
      cacheWrite: (lists) async {
        // Save lists WITH their items so they are available offline
        debugPrint('Shopping lists cacheWrite: ${lists.length} lists, items per list: ${lists.map((l) => '${l.name}:${l.listItems.length}').join(', ')}');
        await _storage.clearShoppingLists();
        await _storage.saveShoppingLists(lists);
      },
      cacheRead: () async {
        final cached = await _storage.getShoppingLists();
        if (cached == null || cached.isEmpty) {
          debugPrint('Shopping lists cacheRead: no cached data');
          return null;
        }
        debugPrint('Shopping lists cacheRead: ${cached.length} lists, items per list: ${cached.map((l) => '${l.name}:${l.listItems.length}').join(', ')}');
        return cached.map((list) {
          final unchecked = list.listItems.where((i) => !i.checked).length;
          return list.copyWith(itemCount: unchecked);
        }).toList();
      },
    );
  }

  Future<void> createShoppingList(String name) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) return;
    await withOfflineWriteFallback(
      apiCall: () => _api.createShoppingList(name: name),
      localWrite: () async {
        // Save a local-only list with a temporary ID
        final localList = ShoppingList(
          id: 'local_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          extras: {},
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          recipeReferences: [],
          labelSettings: [],
          listItems: [],
        );
        final cached = await _storage.getShoppingLists();
        final List<ShoppingList> all = [...(cached ?? <ShoppingList>[]), localList];
        await _storage.clearShoppingLists();
        await _storage.saveShoppingLists(all);
      },
      enqueue: () => _syncQueue.enqueue(
        actionType: 'create',
        entityType: 'shopping_list',
        payload: {'name': name},
      ),
    );
  }

  Future<void> deleteShoppingList(String id) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) return;
    await withOfflineWriteFallback(
      apiCall: () => _api.deleteShoppingList(id),
      localWrite: () async {
        final cached = await _storage.getShoppingLists();
        if (cached != null) {
          final updated = cached.where((l) => l.id != id).toList();
          await _storage.clearShoppingLists();
          if (updated.isNotEmpty) await _storage.saveShoppingLists(updated);
        }
      },
      enqueue: () => _syncQueue.enqueue(
        actionType: 'delete',
        entityType: 'shopping_list',
        entityId: id,
        payload: {'id': id},
      ),
    );
  }

  Future<void> updateShoppingListName(String listId, String newName) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) return;
    await withOfflineWriteFallback(
      apiCall: () async {
        final list = await _api.getShoppingList(listId);
        final updatedList = list.copyWith(name: newName);
        await _api.updateShoppingList(list.id, updatedList);
        if (list.labelSettings.isNotEmpty) {
          await _api.updateShoppingListLabelSettings(list.id, list.labelSettings);
        }
      },
      localWrite: () async {
        final cached = await _storage.getShoppingLists();
        if (cached != null) {
          final updatedLists = cached.map((l) {
            if (l.id == listId) return l.copyWith(name: newName);
            return l;
          }).toList();
          await _storage.clearShoppingLists();
          await _storage.saveShoppingLists(updatedLists);
        }
      },
      enqueue: () => _syncQueue.enqueue(
        actionType: 'update',
        entityType: 'shopping_list',
        entityId: listId,
        payload: {'name': newName},
      ),
    );
  }

  Future<ShoppingList> updateShoppingListLabelSettings(
      String listId, List<ShoppingListLabelSetting> labelSettings) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return _getDemoShoppingLists().firstWhere((l) => l.id == listId);
    }
    return await _api.updateShoppingListLabelSettings(listId, labelSettings);
  }

  // ─── Shopping List Items ───────────────────────────────────────────

  Future<List<ShoppingItem>> getItemsForList(String listId) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      return _demoShoppingItems[listId] ?? [];
    }

    return withOfflineFallbackSimple<List<ShoppingItem>>(
      apiCall: () async {
        final list = await _api.getShoppingList(listId);
        return list.listItems;
      },
      cacheWrite: (items) async {
        debugPrint('Items cacheWrite for list $listId: ${items.length} items');
        // Update the specific list in local cache with fresh items
        try {
          final cached = await _storage.getShoppingLists();
          if (cached != null) {
            final updatedLists = cached.map((l) {
              if (l.id == listId) {
                return l.copyWith(listItems: items);
              }
              return l;
            }).toList();
            await _storage.clearShoppingLists();
            await _storage.saveShoppingLists(updatedLists);
          } else {
            // No cached lists yet – create a minimal entry so items are saved
            final listWithItems = ShoppingList(
              id: listId,
              name: '',
              extras: {},
              createdAt: '',
              updatedAt: '',
              recipeReferences: [],
              labelSettings: [],
              listItems: items,
            );
            await _storage.saveShoppingLists([listWithItems]);
          }
        } catch (e) {
          debugPrint('Failed to update cached items for list $listId: $e');
        }
      },
      cacheRead: () async {
        final cached = await _storage.getShoppingLists();
        if (cached == null) {
          debugPrint('Items cacheRead for list $listId: no cached lists');
          return null;
        }
        final list = cached.where((l) => l.id == listId).firstOrNull;
        final items = list?.listItems;
        debugPrint('Items cacheRead for list $listId: found=${list != null}, items=${items?.length ?? 0}');
        // Return null if list not found or has no items cached
        if (items == null || items.isEmpty) return null;
        return items;
      },
    );
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

    final wasOffline = await withOfflineWriteFallback(
      apiCall: () async {
        final result = await _api.createShoppingItem(item);
        debugPrint('Shopping item created successfully: ${result.id}');
      },
      localWrite: () async {
        // Create a local-only item with a temporary ID
        final localItem = item.copyWith(
          id: 'local_${DateTime.now().millisecondsSinceEpoch}',
          display: foodName,
        );
        await _addItemToLocalCache(listId, localItem);
      },
      enqueue: () => _syncQueue.enqueue(
        actionType: 'create',
        entityType: 'shopping_item',
        payload: item.toCacheJson(),
      ),
    );
    if (wasOffline) {
      debugPrint('Shopping item saved locally (offline)');
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
    await withOfflineWriteFallback(
      apiCall: () => _api.updateShoppingItem(item.id, item),
      localWrite: () => _updateItemInLocalCache(item),
      enqueue: () => _syncQueue.enqueue(
        actionType: 'update',
        entityType: 'shopping_item',
        entityId: item.id,
        payload: item.toCacheJson(),
      ),
    );
  }

  Future<void> deleteItem(String itemId) async {
    final token = await _tokenStorage.getToken();
    if (token == AppConstants.demoToken) {
      for (var list in _demoShoppingItems.values) {
        list.removeWhere((item) => item.id == itemId);
      }
      return;
    }
    await withOfflineWriteFallback(
      apiCall: () => _api.deleteShoppingItem(itemId),
      localWrite: () => _removeItemFromLocalCache(itemId),
      enqueue: () => _syncQueue.enqueue(
        actionType: 'delete',
        entityType: 'shopping_item',
        entityId: itemId,
        payload: {'id': itemId},
      ),
    );
  }

  // ─── Local Cache Helpers ──────────────────────────────────────────

  Future<void> _addItemToLocalCache(String listId, ShoppingItem item) async {
    try {
      final cached = await _storage.getShoppingLists();
      if (cached == null) return;
      final updatedLists = cached.map((l) {
        if (l.id == listId) {
          return l.copyWith(listItems: [...l.listItems, item]);
        }
        return l;
      }).toList();
      await _storage.clearShoppingLists();
      await _storage.saveShoppingLists(updatedLists);
    } catch (e) {
      debugPrint('Failed to add item to local cache: $e');
    }
  }

  Future<void> _updateItemInLocalCache(ShoppingItem item) async {
    try {
      final cached = await _storage.getShoppingLists();
      if (cached == null) return;
      final updatedLists = cached.map((l) {
        if (l.id == item.shoppingListId) {
          final updatedItems = l.listItems.map((i) {
            return i.id == item.id ? item : i;
          }).toList();
          return l.copyWith(listItems: updatedItems);
        }
        return l;
      }).toList();
      await _storage.clearShoppingLists();
      await _storage.saveShoppingLists(updatedLists);
    } catch (e) {
      debugPrint('Failed to update item in local cache: $e');
    }
  }

  Future<void> _removeItemFromLocalCache(String itemId) async {
    try {
      final cached = await _storage.getShoppingLists();
      if (cached == null) return;
      final updatedLists = cached.map((l) {
        final filteredItems = l.listItems.where((i) => i.id != itemId).toList();
        return l.copyWith(listItems: filteredItems);
      }).toList();
      await _storage.clearShoppingLists();
      await _storage.saveShoppingLists(updatedLists);
    } catch (e) {
      debugPrint('Failed to remove item from local cache: $e');
    }
  }

  // ─── Demo Data ────────────────────────────────────────────────────

  List<ShoppingList> _getDemoShoppingLists() {
    return [
      ShoppingList(id: '1', name: 'Weekly Groceries', itemCount: _demoShoppingItems['1']?.where((i) => !i.checked).length ?? 0, extras: {}, createdAt: DateTime.now().toIso8601String(), updatedAt: DateTime.now().toIso8601String(), recipeReferences: [], labelSettings: [], listItems: []),
      ShoppingList(id: '2', name: 'BBQ Party', itemCount: _demoShoppingItems['2']?.where((i) => !i.checked).length ?? 0, extras: {}, createdAt: DateTime.now().toIso8601String(), updatedAt: DateTime.now().toIso8601String(), recipeReferences: [], labelSettings: [], listItems: []),
    ];
  }
}
