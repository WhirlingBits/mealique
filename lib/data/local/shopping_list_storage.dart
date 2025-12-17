import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/shopping_item.dart';

class ShoppingListStorage {
  // A prefix for the storage key
  static const _storageKeyPrefix = 'shopping_list_';

  /// Stores a list of items locally.
  /// Optionally, a [listId] can be specified to separate different lists.
  Future<void> saveItems(List<ShoppingItem> items, {String listId = 'default'}) async {
    final prefs = await SharedPreferences.getInstance();

    // We convert the list of objects into a list of maps (JSON)
    final jsonList = items.map((item) => item.toJson()).toList();

    // Then we encode it as a string
    final jsonString = jsonEncode(jsonList);

    await prefs.setString('$_storageKeyPrefix$listId', jsonString);
  }

  /// Loads the locally stored items.
  /// Returns an empty list if nothing is stored.
  Future<List<ShoppingItem>> getItems({String listId = 'default'}) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString('$_storageKeyPrefix$listId');

    if (jsonString == null) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => ShoppingItem.fromJson(json)).toList();
    } catch (e) {
      // If something goes wrong during parsing (e.g. old data format), we return an empty list.
      return [];
    }
  }

  /// Deletes the local data for a specific list
  Future<void> clearList({String listId = 'default'}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_storageKeyPrefix$listId');
  }
}
