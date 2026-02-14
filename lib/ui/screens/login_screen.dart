import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mealique/data/local/token_storage.dart';
import 'package:mealique/data/remote/api_exceptions.dart';
import 'package:mealique/data/remote/auth_api.dart';
import 'package:mealique/l10n/app_localizations.dart';
import 'package:mealique/ui/screens/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _serverController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tokenStorage = TokenStorage();
  final _authApi = AuthApi();
  bool _isLoading = false;

  // --- DEMO ACCOUNT CONSTANTS ---
  static const String demoEmail = 'demo@mealique.app';
  static const String demoServerUrl = 'http://demo.mode';
  static const String demoToken = 'DEMO_TOKEN';

  Future<void> _login() async {
    final l10n = AppLocalizations.of(context)!;

    final rawServer = _serverController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // --- DEMO ACCOUNT LOGIC ---
    if (email == demoEmail) {
      setState(() => _isLoading = true);

      await _tokenStorage.saveToken(demoToken);
      await _tokenStorage.saveServerUrl(demoServerUrl);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
      setState(() => _isLoading = false);
      return; // Stop the regular login flow
    }
    // --- END DEMO ACCOUNT LOGIC ---

    if (rawServer.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage(l10n.fillAllFields, isError: true);
      return;
    }

    String server = rawServer;
    if (!server.startsWith('http://') && !server.startsWith('https://')) {
      server = 'https://$server';
    }
    if (server.endsWith('/')) server = server.substring(0, server.length - 1);

    setState(() => _isLoading = true);

    try {
      final token = await _authApi.login(server, email, password);

      if (token != null) {
        await _tokenStorage.saveToken(token);
        await _tokenStorage.saveServerUrl(server);

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      } else {
        _showMessage(l10n.loginError('No token received'), isError: true);
      }
    } on DioException catch (e) {
      String errorMessage;
      if (e.error is ApiException) {
        errorMessage = (e.error as ApiException).message;
      } else {
        errorMessage = 'An unknown error occurred.';
      }
      _showMessage(l10n.loginError(errorMessage), isError: true);
    } catch (e) {
      _showMessage(l10n.loginError(e.toString()), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  void dispose() {
    _serverController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE58325),
        foregroundColor: Colors.white,
        title: Text(l10n.welcome),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/mealique.png',
                  height: 120,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _serverController,
                  decoration: InputDecoration(
                    labelText: l10n.serverAddress,
                    hintText: l10n.serverHint,
                  ),
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  enableSuggestions: false,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: l10n.email),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: l10n.password),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE58325),
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(l10n.login),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
