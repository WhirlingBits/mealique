import '../../models/user_self_model.dart';
import '../remote/users_api.dart';

class UserRepository {
  final UsersApi _api;

  UserRepository() : _api = UsersApi();

  Future<UserSelf> getSelfUser() {
    return _api.getSelfUser();
  }
}
