import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mealique/l10n/app_localizations.dart';
import '../widgets/app_drawer.dart';
import '../widgets/navigation_bar.dart';
import 'dashboard_screen.dart';
import 'recipes_screen.dart';
import 'shopping_list_screen.dart';
import 'settings_screen.dart';

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
  late bool _isOffline;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    RecipesScreen(),
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

  // Determines the title based on the current index
  String _getAppBarTitle(AppLocalizations l10n) {
    switch (_selectedIndex) {
      case 0:
        return l10n.home;
      case 1:
        return l10n.recipes;
      case 2:
        return l10n.shoppingList;
      case 3:
        return l10n.settings;
      default:
        return l10n.home;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE58325),
        foregroundColor: Colors.white,
        // dynamic titel
        title: Text(_getAppBarTitle(l10n)),
        actions: [
          if (_isOffline)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.cloud_off, color: Colors.white),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Logout Logik hier
            },
          )
        ],
      ),
      drawer: AppDrawer(
        onDestinationSelected: _onItemTapped,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      // Hide navigation bar when Settings (index 3) is selected
      bottomNavigationBar: _selectedIndex == 3
          ? null
          : AppNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
      ),
    );
  }
}
