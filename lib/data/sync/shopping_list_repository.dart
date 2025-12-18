import '../../models/shopping_item.dart';
import '../../models/shopping_list.dart';
import '../../data/remote/shopping_list_api.dart';
import '../../data/local/token_storage.dart';

class ShoppingListRepository {
  final TokenStorage _tokenStorage = TokenStorage();

  // Helpmethod to get the API instance with the correct base URL
  Future<ShoppingListApi> _getApi() async {
    final url = await _tokenStorage.getServerUrl();
    if (url == null) {
      throw Exception('Server URL not set');
    }
    return ShoppingListApi(baseUrl: url);
  }


  Future<List<ShoppingList>> getAllLists() async {
    final api = await _getApi();
    return await api.getShoppingLists();
  }

  Future<List<ShoppingItem>> getItemsForList(String listId) async {
    final api = await _getApi();
    final shoppingList = await api.getShoppingList(listId);
    return shoppingList.items;
  }

  // Method to create a new shopping list
  Future<void> createList(String name) async {
    final api = await _getApi();
    await api.createList(name);
  }

  // Method to update an existing shopping list
  Future<void> updateList(String listId, String name) async {
    final api = await _getApi();
    await api.updateList(listId, name);
  }

  // Method to delete a shopping list
  Future<void> deleteList(String listId) async {
    final api = await _getApi();
    await api.deleteList(listId);
  }

  Future<void> addItem(String listId, String name) async {
    final api = await _getApi();
    await api.addItem(listId, name);
  }

  Future<void> updateItem(ShoppingItem item) async {
    final api = await _getApi();
    await api.updateItem(item);
  }

  Future<void> deleteItem(String itemId) async {
    final api = await _getApi();
    await api.deleteItem(itemId);
  }
}