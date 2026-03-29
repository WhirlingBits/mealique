import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mealique/config/app_constants.dart';
import 'package:mealique/data/remote/auth_api.dart';
import '../../data/local/token_storage.dart';
import '../../data/remote/recipes_api.dart';
import '../../data/remote/users_api.dart';
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
    String? serverUrl;
    String? token;

    // flutter_secure_storage / Android Keystore kann direkt nach dem
    // Aufwachen aus dem Standby eine PlatformException werfen, wenn das
    // Gerät noch nicht vollständig entsperrt ist. Kurz warten & retry.
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final results = await Future.wait([
          _tokenStorage.getServerUrl(),
          _tokenStorage.getToken(),
        ]);
        serverUrl = results[0];
        token = results[1];
        break; // Erfolgreich gelesen
      } on PlatformException catch (e) {
        debugPrint('AuthCheck: Keystore nicht bereit (Versuch ${attempt + 1}): $e');
        if (attempt < 2) {
          // Kurze Pause geben, damit der Keystore sich initialisiert
          await Future.delayed(Duration(milliseconds: 400 * (attempt + 1)));
        } else {
          // Nach 3 Versuchen: sicher zur Login-Seite
          if (mounted) _navigateToLogin();
          return;
        }
      }
    }

    // Kein Token / keine Server-URL → Login
    if (serverUrl == null || token == null) {
      if (mounted) _navigateToLogin();
      return;
    }

    // Demo-Modus: keine Netzwerkprüfung nötig
    if (token == AppConstants.demoToken) {
      if (mounted) _navigateToHome();
      return;
    }

    // Token-Validierung mit Netzwerk-Aufruf.
    // Beim Aufwachen aus dem Standby ist das Netz manchmal kurz nicht
    // verfügbar → erst einmal kurz warten, dann validieren.
    await _validateTokenAndNavigate(serverUrl, token);
  }

  Future<void> _validateTokenAndNavigate(
      String serverUrl, String token, {bool isRetry = false}) async {
    try {
      final api = RecipesApi();
      // Kurzes Timeout beim Start, damit die App nicht ewig hängt
      await api.getRecipes(page: 1, perPage: 1);
      // User-ID im Hintergrund cachen – nicht auf Ergebnis warten
      _fetchAndSaveUserId();
      if (mounted) _navigateToHome();
    } on DioException catch (e) {
      if (!mounted) return;

      final statusCode = e.response?.statusCode;

      if (statusCode == 401) {
        // Token abgelaufen → mit gespeicherten Credentials erneuern
        final authApi = AuthApi();
        final newToken = await authApi.refreshToken();
        if (mounted) {
          newToken != null ? _navigateToHome() : _navigateToLogin();
        }
      } else if (_isNetworkError(e) && !isRetry) {
        // Netzwerk direkt nach Standby noch nicht bereit → 1,5 s warten, retry
        debugPrint('AuthCheck: Netzwerk nicht bereit, retry nach 1.5 s...');
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          await _validateTokenAndNavigate(serverUrl, token, isRetry: true);
        }
      } else {
        // Anderer Netzwerkfehler (Server nicht erreichbar etc.)
        // → Home im Offline-Modus starten, nicht zum Login
        if (mounted) _navigateToHome(isOffline: true);
      }
    } catch (e) {
      debugPrint('AuthCheck unerwarteter Fehler: $e');
      // Sicherheitsnetz: wenn Token vorhanden, lieber offline starten als Login
      if (mounted) _navigateToHome(isOffline: true);
    }
  }

  bool _isNetworkError(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.unknown ||
        e.type == DioExceptionType.connectionError;
  }

  /// User-Profil holen und userId cachen (nicht-blockierend).
  Future<void> _fetchAndSaveUserId() async {
    try {
      final user = await UsersApi().getSelfUser();
      if (user.id.isNotEmpty) {
        await _tokenStorage.saveUserId(user.id);
      }
    } catch (_) {
      // Nicht-kritisch – Rating fällt graceful zurück
    }
  }

  void _navigateToHome({bool isOffline = false}) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MainScreen(isOffline: isOffline),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // App-Logo als Splash
            Icon(Icons.restaurant_menu, size: 72, color: Color(0xFFE58325)),
            SizedBox(height: 24),
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xFFE58325),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
