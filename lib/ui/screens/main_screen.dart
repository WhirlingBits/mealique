import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mealique/l10n/app_localizations.dart';
import 'package:mealique/ui/widgets/dashboard_actions_menu.dart';
import 'package:mealique/ui/widgets/recipe_actions_menu.dart';
import 'package:mealique/ui/widgets/shopping_list_detail_actions_menu.dart';
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

  String _getAppBarTitle(AppLocalizations l10n) {
    switch (_selectedIndex) {
      case 0:
        return l10n.home;
      case 1:
        return l10n.recipes;
      case 2:
        return l10n.planner;
      case 3:
        return l10n.shoppingList;
      case 4:
        return l10n.settings;
      default:
        return l10n.home;
    }
  }

  List<Widget> _buildAppBarActions() {
    final actions = <Widget>[];

    if (_isOffline) {
      actions.add(
        const Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: Icon(Icons.cloud_off, color: Colors.white),
        ),
      );
    }

    // Do not show a menu on the settings screen
    if (_selectedIndex == 4) {
      return actions;
    }

    Widget menu;
    switch (_selectedIndex) {
      case 1: // Recipes
        menu = const RecipeActionsMenu();
        break;
      case 3: // Shopping Lists
        menu = const ShoppingListDetailActionsMenu();
        break;
      default: // Dashboard, Planner
        menu = const DashboardActionsMenu();
    }

    actions.add(menu);
    return actions;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE58325),
        foregroundColor: Colors.white,
        title: Text(_getAppBarTitle(l10n)),
        actions: _buildAppBarActions(),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: AppNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
      ),
    );
  }
}
