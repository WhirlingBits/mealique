import 'package:dio/dio.dart';
import '../../models/shopping_item.dart';
import '../../models/shopping_list.dart';
import '../local/token_storage.dart';

class ShoppingListApi {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  ShoppingListApi({required String baseUrl})
      : _tokenStorage = TokenStorage(),
        _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          headers: {'Content-Type': 'application/json'},
        )) {
    // Interceptor für Auth-Token hinzufügen
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  // Retrieve all shopping lists
  Future<List<ShoppingList>> getShoppingLists() async {
    try {
      final response = await _dio.get('/api/households/shopping/lists');
      final List<dynamic> data = response.data['items'] ?? [];
      return data.map((json) => ShoppingList.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get items from a specific list
  Future<ShoppingList> getShoppingList(String listId) async {
    try {
      final response = await _dio.get('/api/households/shopping/lists/$listId');
      return ShoppingList.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Add new item
  Future<ShoppingItem> addItem(String listId, String name) async {
    final response = await _dio.post('/api/households/shopping/items', data: {
      'shoppingListId': listId,
      'note': name,
      'checked': false,
    });
    return ShoppingItem.fromJson(response.data);
  }

  // Item updaten
  Future<ShoppingItem> updateItem(ShoppingItem item) async {
    final response = await _dio.put('/api/households/shopping/items/${item.id}', data: {
      'note': item.name,
      'checked': item.isChecked,
    });
    return ShoppingItem.fromJson(response.data);
  }

  // Item löschen
  Future<void> deleteItem(String id) async {
    await _dio.delete('/api/households/shopping/items/$id');
  }

  // Neue Liste erstellen
  Future<void> createList(String name) async {
    await _dio.post('/api/households/shopping/lists', data: {
      'name': name,
    });
  }

  // Liste aktualisieren (Name ändern)
  Future<void> updateList(String listId, String name) async {
    await _dio.put('/api/households/shopping/lists/$listId', data: {
      'name': name,
    });
  }

  // Liste löschen
  Future<void> deleteList(String listId) async {
    await _dio.delete('/api/households/shopping/lists/$listId');
  }
}
