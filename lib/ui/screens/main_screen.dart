import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mealique/l10n/app_localizations.dart';
import '../widgets/navigation_bar.dart';
import 'dashboard_screen.dart';
import 'recipes_screen.dart';
import 'shopping_list_screen.dart';
import 'settings_screen.dart';
import 'planner_screen.dart';

class MainScreen extends StatefulWidget {
  final bool isOffline;

  const MainScreen({
    super.key,
    this.isOffline = false,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late bool _isOffline;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // This list remains, but the screens themselves will now have Scaffolds.
  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    RecipesScreen(),
    PlannerScreen(),
    ShoppingListScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _isOffline = widget.isOffline;

    if (_isOffline) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showOfflineSnackBar();
      });
    }

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final bool isNowOffline = results.contains(ConnectivityResult.none);

      if (isNowOffline != _isOffline) {
        setState(() {
          _isOffline = isNowOffline;
        });

        if (_isOffline) {
          _showOfflineSnackBar();
        } else {
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
    return Scaffold(
      // The body now uses an IndexedStack to preserve the state of each screen,
      // including scroll position and user input, when switching tabs.
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: AppNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
      ),
    );
  }
}
