import 'dart:async';
import 'dart:io';
import 'package:app_version_update/app_version_update.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mealique/config/app_constants.dart';
import 'package:mealique/core/utils/responsive_utils.dart';
import 'package:mealique/data/local/token_storage.dart';
import 'package:mealique/data/remote/auth_api.dart';
import 'package:mealique/data/remote/recipes_api.dart';
import 'package:mealique/l10n/app_localizations.dart';
import 'package:mealique/services/background_service.dart';
import 'package:mealique/services/quick_actions_service.dart';
import 'package:mealique/services/sync_service.dart';
import 'package:mealique/ui/widgets/recipe_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/add_recipe_form.dart';
import '../widgets/add_shopping_list_form.dart';
import '../widgets/add_shopping_list_item_form.dart';
import '../widgets/navigation_bar.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
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

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  late bool _isOffline;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final SyncService _syncService = SyncService();

  // Zeitpunkt, zu dem die App zuletzt im Vordergrund war
  DateTime? _lastResumeTime;

  // Zeitpunkt der letzten Update-Prüfung (max. 1× pro Stunde Dialog zeigen)
  DateTime? _lastUpdateCheck;

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
    _lastResumeTime = DateTime.now();

    // Lifecycle-Observer registrieren (Standby-Erkennung)
    WidgetsBinding.instance.addObserver(this);

    // Initialise the sync service (starts its own connectivity listener)
    _syncService.init();

    // Check for app update in Play Store
    _checkForUpdate();

    // Initialize quick actions (Android app-icon long-press shortcuts)
    _initQuickActions();

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

  /// Initialises Android quick actions (app icon long-press shortcuts).
  void _initQuickActions() {
    if (!Platform.isAndroid) return;

    final quickActions = QuickActionsService.instance;

    // Register callback for warm-start (app already running)
    quickActions.onShortcutTapped = _handleShortcut;

    // Process any cold-start shortcut (app was not running)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pending = quickActions.consumePendingShortcut();
      if (pending != null) {
        _handleShortcut(pending);
      }

      // Register the shortcut items (needs l10n context)
      final l10n = AppLocalizations.of(context)!;
      quickActions.initialize(
        createRecipeLabel: l10n.addRecipe,
        createShoppingListLabel: l10n.createList,
        createShoppingListItemLabel: l10n.addItem,
      );
    });
  }

  /// Handles a quick-action shortcut tap by navigating to the right tab and
  /// opening the corresponding bottom-sheet form.
  void _handleShortcut(String shortcutType) {
    if (!mounted) return;
    switch (shortcutType) {
      case ShortcutTypes.createRecipe:
        // Navigate to recipes tab, then show create form
        setState(() {
          _visitedTabs.add(1);
          _selectedIndex = 1;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showAddRecipeSheet();
        });
        break;
      case ShortcutTypes.createShoppingList:
        // Navigate to shopping tab, then show create form
        setState(() {
          _visitedTabs.add(3);
          _selectedIndex = 3;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showAddShoppingListSheet();
        });
        break;
      case ShortcutTypes.createShoppingListItem:
        // Navigate to shopping tab, then show add-item form
        setState(() {
          _visitedTabs.add(3);
          _selectedIndex = 3;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showAddShoppingListItemSheet();
        });
        break;
    }
  }

  void _showAddRecipeSheet() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: AddRecipeForm(
          onAddRecipe: (recipeJson) async {
            Navigator.pop(ctx);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.recipeCreated)),
              );
            }
          },
        ),
      ),
    );
  }

  void _showAddShoppingListSheet() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddShoppingListForm(
        onAddList: (name) {
          Navigator.pop(ctx);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.listCreatedSuccess(name))),
            );
          }
        },
      ),
    );
  }

  void _showAddShoppingListItemSheet() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddShoppingListItemForm(
        onAddItem: (item) async {
          Navigator.pop(ctx);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.itemAddedSuccess(item.foodName)),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
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
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  /// Wird aufgerufen, wenn die App in den Vorder-/Hintergrund wechselt.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // App goes to background – schedule background sync if there are pending ops
      BackgroundService.instance.scheduleSyncNow();
    } else if (state == AppLifecycleState.resumed) {
      final now = DateTime.now();
      final last = _lastResumeTime;
      _lastResumeTime = now;

      // Refresh image cache when app resumes - this ensures images load after standby
      // Wichtig: await damit der Cache aktualisiert wird bevor Widgets rendern
      _refreshImageCacheOnResume();

      // Bei jedem Öffnen der App auf Updates prüfen
      _checkForUpdate();

      // Nach mehr als 15 Minuten Standby Token still im Hintergrund prüfen
      final longStandby = last == null ||
          now.difference(last) > const Duration(minutes: 15);
      if (longStandby) {
        _silentTokenCheck();
      }

      // Process any pending sync operations when app comes back
      _processSyncQueue();
    }
  }

  /// Aktualisiert den Image-Cache nach App-Resume
  Future<void> _refreshImageCacheOnResume() async {
    debugPrint('MainScreen: Refreshing image cache on resume...');
    await RecipeImage.refreshCache();
    debugPrint('MainScreen: Image cache refreshed');
  }

  /// Prüft ob im Play Store ein Update verfügbar ist.
  /// Dialog wird maximal einmal pro Stunde angezeigt.
  Future<void> _checkForUpdate() async {
    final now = DateTime.now();
    if (_lastUpdateCheck != null &&
        now.difference(_lastUpdateCheck!) < const Duration(hours: 1)) {
      return; // Innerhalb der letzten Stunde bereits geprüft
    }

    try {
      final result = await AppVersionUpdate.checkForUpdates(
        playStoreId: 'de.mealique.app',
      );
      _lastUpdateCheck = DateTime.now();
      if (result.canUpdate == true && mounted) {
        _showUpdateDialog(result.storeVersion ?? '', result.storeUrl ?? '');
      }
    } catch (e) {
      // App noch nicht öffentlich im Play Store → still überspringen
      _lastUpdateCheck = DateTime.now();
      debugPrint('Update check skipped: $e');
    }
  }

  /// Zeigt einen Dialog an, wenn ein Update verfügbar ist.
  void _showUpdateDialog(String storeVersion, String storeUrl) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.updateAvailable),
        content: Text(l10n.updateAvailableMessage(storeVersion)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.later),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE58325),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              final uri = Uri.parse(storeUrl);
              launchUrl(uri, mode: LaunchMode.externalApplication);
            },
            child: Text(l10n.updateNow),
          ),
        ],
      ),
    );
  }

  /// Prüft das Token im Hintergrund. Navigiert nur bei echtem 401 zum Login.
  Future<void> _silentTokenCheck() async {
    // Check if we're in demo mode - no token check needed
    final token = await TokenStorage().getToken();
    if (token == AppConstants.demoToken) {
      debugPrint('Silent token check: Demo mode, skipping');
      return;
    }
    
    try {
      final api = RecipesApi();
      await api.getRecipes(page: 1, perPage: 1);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Token abgelaufen → versuche still zu erneuern
        final newToken = await AuthApi().refreshToken();
        if (newToken == null && mounted) {
          // Erneuerung gescheitert → zum Login
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      }
      // Bei anderen Fehlern (Netz weg etc.) nichts tun – Offline-Banner reicht
    } catch (_) {
      // Nicht-kritisch – App läuft weiter
    }
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

  Widget _buildNavigationRail(AppLocalizations l10n) {
    const accentColor = Color(0xFFE58325);
    return NavigationRail(
      backgroundColor: accentColor,
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      labelType: NavigationRailLabelType.all,
      selectedIconTheme: const IconThemeData(color: Colors.white),
      unselectedIconTheme: IconThemeData(color: Colors.white.withOpacity(0.7)),
      selectedLabelTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: Colors.white.withOpacity(0.7),
        fontSize: 11,
      ),
      indicatorColor: Colors.white.withOpacity(0.2),
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: ClipOval(
          child: Image.asset(
            'assets/mealique.png',
            width: 40,
            height: 40,
            fit: BoxFit.contain,
          ),
        ),
      ),
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: Text(l10n.home),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.menu_book_outlined),
          selectedIcon: const Icon(Icons.menu_book),
          label: Text(l10n.recipes),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.calendar_month_outlined),
          selectedIcon: const Icon(Icons.calendar_month),
          label: Text(l10n.planner),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.shopping_cart_outlined),
          selectedIcon: const Icon(Icons.shopping_cart),
          label: Text(l10n.shopping),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: Text(l10n.settings),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isTablet = ResponsiveUtils.isTablet(context);

    final content = IndexedStack(
      index: _selectedIndex,
      children: List.generate(5, (index) {
        if (_visitedTabs.contains(index)) {
          return _buildScreen(index);
        }
        // Return a lightweight placeholder for tabs not yet visited
        return const SizedBox.shrink();
      }),
    );

    if (isTablet) {
      // Tablet Layout: NavigationRail on the left
      return Scaffold(
        body: Row(
          children: [
            _buildNavigationRail(l10n),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(child: content),
          ],
        ),
      );
    }

    // Phone Layout: Bottom Navigation Bar
    return Scaffold(
      body: content,
      bottomNavigationBar: AppNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
      ),
    );
  }
}
