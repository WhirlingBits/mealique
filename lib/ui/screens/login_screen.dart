import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../data/remote/mealie_api.dart';
import '../../data/local/token_storage.dart';

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
    // Normalise: remove trailing slash
    if (server.endsWith('/')) server = server.substring(0, server.length - 1);

    setState(() => _isLoading = true);

    try {
      // 1. Create API instance
      final api = MealieApi(baseUrl: server);

      // 2. Log in (token is stored internally by MealieApi)
      await api.login(email, password);

      // 3. Save server URL separately for later API calls when restarting
      await _tokenStorage.saveServerUrl(server);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      // Error handling simplified, as MealieApi throws readable exceptions
      final msg = e.toString().replaceAll('Exception: ', '');
      _showMessage(l10n.loginError(msg));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
                    child: _isLoading
                        ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
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
