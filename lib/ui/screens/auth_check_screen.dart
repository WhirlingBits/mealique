import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mealique/config/app_constants.dart';
import '../../data/local/token_storage.dart';
import '../../data/remote/recipes_api.dart'; 
import 'main_screen.dart';
import 'login_screen.dart';

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  final _tokenStorage = TokenStorage();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 1)); // For splash effect

    final serverUrl = await _tokenStorage.getServerUrl();
    final token = await _tokenStorage.getToken();

    // If no credentials, go to login
    if (serverUrl == null || token == null) {
      if (mounted) _navigateToLogin();
      return;
    }

    // --- DEMO MODE CHECK ---
    // If it's the demo account, skip network validation and go straight home
    if (token == AppConstants.demoToken) {
      if (mounted) _navigateToHome();
      return;
    }
    // --- END DEMO MODE CHECK ---

    // For real users, validate the token with a network call
    try {
      final api = RecipesApi();
      await api.getRecipes(page: 1, perPage: 1); // Lightweight validation call
      if (mounted) _navigateToHome();
    } on DioException catch (e) {
      if (!mounted) return;
      if (e.response?.statusCode == 401) {
        _navigateToLogin(); // Token expired or invalid
      } else {
        _navigateToHome(); // Other network error, let the app handle it
      }
    } catch (e) {
      if (mounted) _navigateToLogin(); // Any other unexpected error
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MainScreen(),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
