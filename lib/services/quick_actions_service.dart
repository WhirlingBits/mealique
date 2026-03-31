import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:quick_actions_android/quick_actions_android.dart';

/// Shortcut types used as identifiers for quick actions.
class ShortcutTypes {
  static const String createRecipe = 'create_recipe';
  static const String createShoppingList = 'create_shopping_list';
  static const String createShoppingListItem = 'create_shopping_list_item';
}

/// Service that manages Android app icon shortcuts (long-press quick actions).
class QuickActionsService {
  QuickActionsService._();
  static final QuickActionsService instance = QuickActionsService._();

  final QuickActionsAndroid _quickActions = QuickActionsAndroid();

  /// Callback that will be invoked with the shortcut type when a user taps a
  /// quick action.  Must be set before calling [initialize].
  void Function(String shortcutType)? onShortcutTapped;

  /// Pending shortcut type that was received before a listener was attached.
  String? _pendingShortcut;

  /// Returns and clears any shortcut that was triggered before the listener
  /// was ready (cold-start scenario).
  String? consumePendingShortcut() {
    final s = _pendingShortcut;
    _pendingShortcut = null;
    return s;
  }

  /// Initializes the quick actions.  Call this once after the app is ready.
  Future<void> initialize({
    required String createRecipeLabel,
    required String createShoppingListLabel,
    required String createShoppingListItemLabel,
  }) async {
    if (!Platform.isAndroid) return;

    // Register a handler that is called whenever a shortcut is tapped
    // (both cold-start and warm-start).
    await _quickActions.initialize((String shortcutType) {
      debugPrint('Quick action tapped: $shortcutType');
      if (onShortcutTapped != null) {
        onShortcutTapped!(shortcutType);
      } else {
        // Store for later consumption (cold-start before listener is ready)
        _pendingShortcut = shortcutType;
      }
    });

    // Define the shortcuts shown when the user long-presses the app icon.
    await _quickActions.setShortcutItems([
      ShortcutItem(
        type: ShortcutTypes.createRecipe,
        localizedTitle: createRecipeLabel,
        icon: 'ic_shortcut_recipe',
      ),
      ShortcutItem(
        type: ShortcutTypes.createShoppingList,
        localizedTitle: createShoppingListLabel,
        icon: 'ic_shortcut_shopping_list',
      ),
      ShortcutItem(
        type: ShortcutTypes.createShoppingListItem,
        localizedTitle: createShoppingListItemLabel,
        icon: 'ic_shortcut_shopping_item',
      ),
    ]);
  }
}

