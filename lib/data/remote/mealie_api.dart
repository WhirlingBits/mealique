import 'package:dio/dio.dart';
import '../../models/recipe.dart';
import '../local/token_storage.dart';

class MealieApi {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  MealieApi({required String baseUrl})
      : _tokenStorage = TokenStorage(),
        _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          headers: {'Content-Type': 'application/json'},
        )) {
    // Interceptor: Fügt bei jedem Request den Token hinzu, falls vorhanden
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

  // Login: Holt Token und speichert ihn
  Future<void> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/token',
        data: {'username': username, 'password': password},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final token = response.data['access_token'];
      if (token != null) {
        await _tokenStorage.saveToken(token);
      } else {
        throw Exception('Kein Token erhalten');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? e.message);
    }
  }

  // Rezepte abrufen
  Future<List<Recipe>> getRecipes({int page = 1, int perPage = 50}) async {
    try {
      final response = await _dio.get(
        '/api/recipes',
        queryParameters: {
          'page': page,
          'perPage': perPage,
        },
      );

      final data = response.data;
      // Mealie gibt oft ein Objekt mit 'items' zurück oder direkt eine Liste,
      // je nach Version und Endpoint-Konfiguration.
      final List<dynamic> items = (data is Map && data.containsKey('items'))
          ? data['items']
          : data;

      return items.map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}