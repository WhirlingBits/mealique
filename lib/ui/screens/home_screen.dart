import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mealique/l10n/app_localizations.dart';
import '../widgets/app_drawer.dart';
import '../widgets/navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  final bool isOffline;

  const HomeScreen({
    super.key,
    this.isOffline = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  // Lokaler State, der sich ändern kann
  late bool _isOffline;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  static const List<Widget> _widgetOptions = <Widget>[
    Center(child: Text('Home Page')),
    Center(child: Text('Recipes Page')),
    Center(child: Text('Add Recipe Page')),
    Center(child: Text('Shopping List Page')),
  ];

  @override
  void initState() {
    super.initState();
    // Initialen Wert vom Widget übernehmen
    _isOffline = widget.isOffline;

    // 1. Initiale Snackbar zeigen, falls wir schon offline gestartet sind
    if (_isOffline) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showOfflineSnackBar();
      });
    }

    // 2. Stream abonnieren für Live-Updates
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // Wenn 'none' im Ergebnis ist, haben wir keine Verbindung
      final bool isNowOffline = results.contains(ConnectivityResult.none);

      // Nur reagieren, wenn sich der Status wirklich geändert hat
      if (isNowOffline != _isOffline) {
        setState(() {
          _isOffline = isNowOffline;
        });

        if (_isOffline) {
          _showOfflineSnackBar();
        } else {
          // Optional: Snackbar ausblenden oder "Wieder online" anzeigen
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _showOfflineSnackBar() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n.networkError} (Offline-Modus)'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.home),
        actions: [
          // Wir nutzen hier die lokale Variable _isOffline statt widget.isOffline
          if (_isOffline)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.cloud_off, color: Colors.orange),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Logout Logik
            },
          )
        ],
      ),
      drawer: const AppDrawer(),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: AppNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
      ),
    );
  }
}
