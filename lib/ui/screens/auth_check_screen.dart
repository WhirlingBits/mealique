import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
    await Future.delayed(const Duration(seconds: 1));

    final serverUrl = await _tokenStorage.getServerUrl();
    final token = await _tokenStorage.getToken();

    if (serverUrl == null || token == null) {
      if (!mounted) return;
      _navigateToLogin();
      return;
    }

    try {
      final api = RecipesApi();
      // Make a lightweight test call to validate the token
      await api.getRecipes(page: 1, perPage: 1);

      if (!mounted) return;
      _navigateToHome();

    } on DioException catch (e) {
      if (!mounted) return;

      // If token is expired or invalid, force login
      if (e.response?.statusCode == 401) {
        _navigateToLogin();
      } else {
        // For other errors (e.g., network issues), we can still open the app
        // The user will see error messages within the app itself.
        _navigateToHome();
      }
    } catch (e) {
      if (!mounted) return;
      _navigateToLogin();
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
