import 'package:dio/dio.dart';
import 'package:mealique/data/remote/dio_client.dart';
import '../../models/user_self_model.dart';
import '../local/token_storage.dart';

class UsersApi {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  UsersApi({String? baseUrl})
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

  Future<UserSelf> getSelfUser() async {
    final response = await _dio.get('api/users/self');
    return UserSelf.fromJson(response.data);
  }
}
