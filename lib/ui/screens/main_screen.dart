import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mealique/l10n/app_localizations.dart';
import 'package:mealique/services/sync_service.dart';
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
  final SyncService _syncService = SyncService();

  // Track which tabs have been visited to enable lazy loading
  final Set<int> _visitedTabs = {0};

  // Build screens on demand instead of all at once
  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const RecipesScreen();
      case 2:
        return const PlannerScreen();
      case 3:
        return const ShoppingListScreen();
      case 4:
        return const SettingsScreen();
      default:
        return const DashboardScreen();
    }
  }

  @override
  void initState() {
    super.initState();
    _isOffline = widget.isOffline;

    // Initialise the sync service (starts its own connectivity listener)
    _syncService.init();

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
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          }
          _processSyncQueue();
        }
      }
    });
  }

  /// Processes the offline queue and shows status snackbars.
  Future<void> _processSyncQueue() async {
    final pendingBefore = _syncService.pendingCount.value;
    if (pendingBefore == 0) return;

    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.syncStarted),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );

    final synced = await _syncService.processQueue();

    if (!mounted) return;
    final remaining = _syncService.pendingCount.value;

    if (remaining == 0 && synced > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.sync} ✓ – $synced'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } else if (remaining > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.sync}: $remaining ${l10n.offlineMode}'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
    }
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
        content: Text('${l10n.networkError} (${l10n.offlineMode})'),
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
      _visitedTabs.add(index);
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Lazy IndexedStack: only build screens that have been visited.
      // This preserves state of visited tabs while avoiding the cost of
      // building all tabs (and their API calls) on first startup.
      body: IndexedStack(
        index: _selectedIndex,
        children: List.generate(5, (index) {
          if (_visitedTabs.contains(index)) {
            return _buildScreen(index);
          }
          // Return a lightweight placeholder for tabs not yet visited
          return const SizedBox.shrink();
        }),
      ),
      bottomNavigationBar: AppNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
      ),
    );
  }
}
