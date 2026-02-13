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

  Future<void> _login() async {
    final l10n = AppLocalizations.of(context)!;

    final rawServer = _serverController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (rawServer.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage(l10n.fillAllFields);
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
        _showMessage(l10n.loginError('No token received')); // TODO: l10n
      }
    } on DioException catch (e) {
      String errorMessage;
      if (e.error is ApiException) {
        errorMessage = (e.error as ApiException).message;
      } else {
        errorMessage = 'An unknown error occurred.'; // TODO: l10n
      }
      _showMessage(l10n.loginError(errorMessage));
    } catch (e) {
      _showMessage(l10n.loginError(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
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
