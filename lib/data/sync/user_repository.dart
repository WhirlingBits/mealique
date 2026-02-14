import 'package:mealique/config/app_constants.dart';
import 'package:mealique/data/local/token_storage.dart';
import 'package:mealique/models/user_self_model.dart';
import '../remote/users_api.dart';

class UserRepository {
  final UsersApi _api;
  final TokenStorage _tokenStorage;

  UserRepository() 
      : _api = UsersApi(),
        _tokenStorage = TokenStorage();

  Future<UserSelf> getSelfUser() async {
    final token = await _tokenStorage.getToken();

    // --- DEMO DATA LOGIC ---
    if (token == AppConstants.demoToken) {
      // Return hard-coded demo user data
      return UserSelf(
        admin: false,
        email: AppConstants.demoEmail,
        fullName: 'Demo User',
        group: 'Home',
        household: 'Family',
        username: 'demouser',
      );
    }
    // --- END DEMO DATA LOGIC ---

    return _api.getSelfUser();
  }
}
