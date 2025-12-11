import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'home_screen.dart';
import '../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _serverController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storage = FlutterSecureStorage();
  bool _isLoading = false;

  Future<void> _login() async {
    // Holen Sie sich die Übersetzungen hier, da der Kontext benötigt wird
    final l10n = AppLocalizations.of(context)!;

    final rawServer = _serverController.text.trim();
    final email = _emailController.text.trim();
    final password = _password_controller_text();

    if (rawServer.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage(l10n.fillAllFields);
      return;
    }

    String server = rawServer;
    if (!server.startsWith('http://') && !server.startsWith('https://')) {
      server = 'https://$server';
    }
    // Normalisiere: entferne abschließenden Schrägstrich, dann anhängen
    if (server.endsWith('/')) server = server.substring(0, server.length - 1);
    final uri = Uri.parse('$server/api/auth/token');

    setState(() => _isLoading = true);

    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': email, 'password': password},
      );

      if (res.statusCode != 200) {
        String msg = 'Login fehlgeschlagen (${res.statusCode})';
        try {
          final body = jsonDecode(res.body);
          if (body is Map && body['detail'] != null) msg = body['detail'].toString();
        } catch (_) {}
        _showMessage(msg);
        return;
      }

      final body = jsonDecode(res.body);
      final access = body['access_token'] ?? body['accessToken'] ?? body['token'];
      if (access == null) {
        _showMessage('Kein access token erhalten.');
        return;
      }

      await _storage.write(key: 'mealie_server', value: server);
      await _storage.write(key: 'access_token', value: access.toString());

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      _showMessage('Fehler beim Login: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _password_controller_text() => _passwordController.text;

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
        title: Text(l10n.welcome),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
    );
  }
}
