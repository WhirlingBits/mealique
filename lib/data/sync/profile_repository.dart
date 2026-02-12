import 'package:mealique/data/local/token_storage.dart';
import 'package:mealique/data/remote/mealie_api.dart';
import 'package:mealique/models/user_profile_model.dart';

class ProfileRepository {
  final TokenStorage _tokenStorage = TokenStorage();

  Future<UserProfile?> getProfile() async {
    try {
      final serverUrl = await _tokenStorage.getServerUrl();
      if (serverUrl == null) {
        throw Exception('Server URL not found. Please log in again.');
      }

      // Initialize API with the fetched URL
      final api = MealieApi(baseUrl: serverUrl);

      // Use the newly created getSelf method
      final response = await api.getSelf();

      if (response != null) {
        return UserProfile.fromJson(response);
      }
      return null;
    } catch (e) {
      // In a real app, you would handle errors more gracefully
      print('Error fetching profile: $e');
      // Return null or re-throw a custom exception
      return null;
    }
  }
}
