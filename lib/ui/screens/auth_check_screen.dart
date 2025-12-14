import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../data/local/token_storage.dart';
import '../../data/remote/mealie_api.dart';
import 'home_screen.dart';
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
      final api = MealieApi(baseUrl: serverUrl);
      await api.getRecipes(page: 1, perPage: 1);

      if (!mounted) return;
      // Online: Wir übergeben false
      _navigateToHome(isOffline: false);

    } on DioException catch (e) {
      if (!mounted) return;

      if (e.response?.statusCode == 401) {
        _navigateToLogin();
      } else {
        // Offline/Fehler: Wir übergeben true
        _navigateToHome(isOffline: true);
      }
    } catch (e) {
      if (!mounted) return;
      _navigateToLogin();
    }
  }

  void _navigateToHome({required bool isOffline}) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        // Hier findet das State Passing statt:
        builder: (context) => HomeScreen(isOffline: isOffline),
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
