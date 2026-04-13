import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mealique/data/remote/api_exceptions.dart';
import 'package:mealique/providers/settings_provider.dart';
import 'package:mealique/ui/screens/shopping_list_item_detail_screen.dart';
import 'package:mealique/ui/screens/edit_shopping_list_item_screen.dart';
import 'package:mealique/ui/widgets/shopping_list_detail_actions_menu.dart';
import 'package:mealique/ui/widgets/sort_dialog.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../data/sync/household_repository.dart';
import '../../models/shopping_item_model.dart';
import '../../models/shopping_list_model.dart';
import '../widgets/add_shopping_list_item_form.dart';
import 'edit_shopping_list_screen.dart';

class ShoppingListDetailScreen extends StatefulWidget {
  final String listId;
  final String listName;
  /// If true, the screen is embedded in a master-detail layout (tablet)
  /// and should not show its own AppBar.
  final bool embedded;

  const ShoppingListDetailScreen({
    super.key,
    required this.listId,
    required this.listName,
    this.embedded = false,
  });

  @override
  State<ShoppingListDetailScreen> createState() =>
      _ShoppingListDetailScreenState();
}

class _ShoppingListDetailScreenState extends State<ShoppingListDetailScreen>
    with WidgetsBindingObserver {
  final _repository = HouseholdRepository();
  late Future<List<ShoppingItem>> _itemsFuture;
  Timer? _refreshTimer;

  // Scroll controller for hiding FAB on scroll
  final ScrollController _scrollController = ScrollController();
  bool _isFabVisible = true;

  final Color _accentColor = const Color(0xFFE58325);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
    _loadItems();
    _startAutoRefresh();
    // Load per-list settings
    Provider.of<SettingsProvider>(context, listen: false)
        .loadListSettings(widget.listId);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onScroll() {
    // Hide FAB when scrolling down, show when scrolling up or at top
    final isScrollingDown = _scrollController.position.userScrollDirection == ScrollDirection.reverse;
    final isAtTop = _scrollController.offset <= 0;

    if (isAtTop && !_isFabVisible) {
      setState(() => _isFabVisible = true);
    } else if (isScrollingDown && _isFabVisible) {
      setState(() => _isFabVisible = false);
    } else if (!isScrollingDown && !_isFabVisible) {
      setState(() => _isFabVisible = true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadItems();
      _startAutoRefresh();
    } else if (state == AppLifecycleState.paused) {
      _refreshTimer?.cancel();
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      _loadItems();
    });
  }

  void _loadItems() {
    setState(() {
      _itemsFuture = _repository.getItemsForList(widget.listId);
    });
  }

  void _handleToggleShowCompleted() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    settings.setShowCompleted(widget.listId, !settings.showCompletedForList(widget.listId));
  }

  void _handleToggleShowCategories() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    settings.setShowCategories(widget.listId, !settings.showCategoriesForList(widget.listId));
  }

  void _handleEditList() async {
    // Build a minimal ShoppingList object for the edit screen
    final shoppingList = ShoppingList(
      id: widget.listId,
      name: widget.listName,
      extras: {},
      createdAt: '',
      updatedAt: '',
      recipeReferences: [],
      labelSettings: [],
      listItems: await _itemsFuture,
    );
    if (!mounted) return;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditShoppingListScreen(shoppingList: shoppingList),
      ),
    );
    if (result == true) {
      _loadItems();
    }
  }

  Future<void> _handleUncheckAll() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final items = await _itemsFuture;
      final checkedItems = items.where((i) => i.checked).toList();
      for (final item in checkedItems) {
        await _repository.updateItem(item.copyWith(checked: false));
      }
      _loadItems();
    } catch (e) {
      _showError(l10n.errorUpdating(e.toString()));
    }
  }

  Future<void> _handleDeleteCompleted() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final items = await _itemsFuture;
      final checkedItems = items.where((i) => i.checked).toList();
      for (final item in checkedItems) {
        await _repository.deleteItem(item.id);
      }
      _loadItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.deleteCompletedItems),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError(l10n.errorDeleting(e.toString()));
    }
  }

  Future<void> _handleDeleteList() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteList),
        content: Text(l10n.confirmDeleteList),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _repository.deleteShoppingList(widget.listId);
        if (mounted) {
          Navigator.pop(context); // Go back to list overview
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.shoppingListDeleted),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          _showError(l10n.errorDeleting(e.toString()));
        }
      }
    }
  }

  void _handleSortItems() async {
    final l10n = AppLocalizations.of(context)!;
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final result = await showSortDialog(
      context: context,
      options: [
        SortOption(field: 'position', label: l10n.sortByPosition),
        SortOption(field: 'name', label: l10n.sortByName),
        SortOption(field: 'checked', label: l10n.sortByChecked),
        SortOption(field: 'category', label: l10n.sortByCategory),
      ],
      currentField: settings.shoppingItemSortFieldForList(widget.listId) ?? 'position',
      currentDirection: settings.shoppingItemSortDirectionForList(widget.listId),
    );

    if (result != null) {
      await settings.setShoppingItemSort(widget.listId, result.field, result.direction);
      setState(() {}); // Trigger rebuild to apply new sort
    }
  }

  List<ShoppingItem> _sortItems(List<ShoppingItem> items) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final field = settings.shoppingItemSortFieldForList(widget.listId);
    final direction = settings.shoppingItemSortDirectionForList(widget.listId);

    final sorted = List<ShoppingItem>.from(items);
    sorted.sort((a, b) {
      // Always show unchecked (open) items first, checked items at the bottom
      if (a.checked != b.checked) {
        return a.checked ? 1 : -1;
      }

      // If both have same checked status, apply secondary sort
      if (field == null) {
        return a.position.compareTo(b.position);
      }

      int result;
      switch (field) {
        case 'name':
          result = a.display.toLowerCase().compareTo(b.display.toLowerCase());
          break;
        case 'checked':
          // Already sorted by checked above, use position as fallback
          result = a.position.compareTo(b.position);
          break;
        case 'category':
          final catA = a.food?.label?.name ?? '';
          final catB = b.food?.label?.name ?? '';
          result = catA.toLowerCase().compareTo(catB.toLowerCase());
          break;
        case 'position':
        default:
          result = a.position.compareTo(b.position);
          break;
      }
      return direction == 'desc' ? -result : result;
    });
    return sorted;
  }

  Future<void> _toggleItem(ShoppingItem item) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final newItem = item.copyWith(checked: !item.checked);
      await _repository.updateItem(newItem);
      _loadItems();
    } catch (e) {
      _showError(l10n.errorUpdating(e.toString()));
    }
  }

  Future<void> _addComplexItem(NewShoppingItem newItemData) async {
    final l10n = AppLocalizations.of(context)!;
    try {
       await _repository.createShoppingItem(
        listId: newItemData.listId,
        foodId: newItemData.foodId,
        foodName: newItemData.foodName,
        quantity: newItemData.quantity.toDouble(),
        note: newItemData.notes,
        unitId: newItemData.unitId,
        categoryId: newItemData.categoryId,
      );
      _loadItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.itemAddedSuccess(newItemData.foodName)),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final apiError = e.error;
      debugPrint('API Error creating shopping item: statusCode=${e.response?.statusCode}, responseData=$responseData, error=$apiError, message=${e.message}');
      _showError(l10n.errorAdding('${responseData?['detail'] ?? apiError ?? e.message}'));
    } catch (e) {
      debugPrint('Error creating shopping item: $e');
      _showError(l10n.errorAdding(e.toString()));
    }
  }

  Future<void> _deleteItem(ShoppingItem item) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await _repository.deleteItem(item.id);
      _loadItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.itemDeletedSuccess(item.display)),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError(l10n.errorDeleting(e.toString()));
      _loadItems();
    }
  }


  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddItemSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddShoppingListItemForm(
        shoppingListId: widget.listId,
        onAddItem: (NewShoppingItem newItem) {
          Navigator.pop(context);
          _addComplexItem(newItem);
        },
      ),
    );
  }

  void _showEditItemDialog(ShoppingItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditShoppingListItemScreen(item: item),
      ),
    ).then((hasChanged) {
      if (hasChanged == true) {
        _loadItems();
      }
    });
  }

  Map<String, List<ShoppingItem>> _groupItemsByCategory(
      List<ShoppingItem> items) {
    final l10n = AppLocalizations.of(context)!;
    final Map<String, List<ShoppingItem>> grouped = {};
    for (var item in items) {
      final category = item.food?.label?.name ?? l10n.general;
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(item);
    }
    return grouped;
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: _accentColor,
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt_rounded, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            l10n.listEmpty,
            style: theme.textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.addFirstItemHint,
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(Object error, VoidCallback onRetry) {
    final l10n = AppLocalizations.of(context)!;
    String errorMessage;

    if (error is DioException && error.error is ApiException) {
      final apiError = error.error as ApiException;
      if (apiError is NetworkException) {
        errorMessage = l10n.checkInternetConnection;
      } else if (apiError is ServerException) {
        errorMessage = l10n.serverError;
      } else {
        errorMessage = apiError.message;
      }
    } else {
      errorMessage = l10n.unexpectedError;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemTile(ShoppingItem item) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Slidable(
        key: ValueKey(item.id),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.5,
          children: [
            SlidableAction(
              onPressed: (_) => _showEditItemDialog(item),
              backgroundColor: const Color(0xFFE58325),
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: l10n.edit,
            ),
            SlidableAction(
              onPressed: (_) => _deleteItem(item),
              backgroundColor: const Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: l10n.delete,
            ),
          ],
        ),
        child: CheckboxListTile(
          value: item.checked,
          onChanged: (val) => _toggleItem(item),
          title: GestureDetector(
            onTap: () async {
              final hasChanged = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => ShoppingListItemDetailScreen(item: item),
                ),
              );
              if (hasChanged == true) {
                _loadItems();
              }
            },
            // Make the whole tile tappable for navigation, not just the text
            child: Container(
              color: Colors.transparent, // Makes the GestureDetector hit-testable
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(item.display,
                  style: TextStyle(
                    decoration: item.checked
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: item.checked ? Colors.grey[500] : null,
                  )),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = Provider.of<SettingsProvider>(context);

    // Build the main content
    Widget content = FutureBuilder<List<ShoppingItem>>(
      future: _itemsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error!, _loadItems);
        }
        final items = snapshot.data ?? [];
        var displayItems = items.toList();

        // Filter out completed items if toggle is off
        if (!settings.showCompletedForList(widget.listId)) {
          displayItems = displayItems.where((i) => !i.checked).toList();
        }

        // Apply sort
        displayItems = _sortItems(displayItems);

        if (displayItems.isEmpty && items.isNotEmpty) {
          // All items are completed and hidden
          return _buildEmptyState();
        }
        if (displayItems.isEmpty) {
          return _buildEmptyState();
        }

        // Group by category or show flat list
        if (settings.showCategoriesForList(widget.listId)) {
          final groupedItems = _groupItemsByCategory(displayItems);
          return SlidableAutoCloseBehavior(
            child: RefreshIndicator(
              onRefresh: () async {
                _loadItems();
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final category = groupedItems.keys.elementAt(index);
                          final categoryItems = groupedItems[category]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle(category),
                              ...categoryItems.map((item) => _buildItemTile(item))
                            ],
                          );
                        },
                        childCount: groupedItems.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          // Flat list without categories
          return SlidableAutoCloseBehavior(
            child: RefreshIndicator(
              onRefresh: () async {
                _loadItems();
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: displayItems.length,
                itemBuilder: (context, index) => _buildItemTile(displayItems[index]),
              ),
            ),
          );
        }
      },
    );

    // In embedded mode (tablet), show header row with title and actions
    if (widget.embedded) {
      return Scaffold(
        body: Column(
          children: [
            // Header with list name and actions menu
            Container(
              color: _accentColor.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.listName,
                      style: TextStyle(
                        color: _accentColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ShoppingListDetailActionsMenu(
                    onRefresh: _loadItems,
                    onEditList: _handleEditList,
                    onUncheckAll: _handleUncheckAll,
                    onDeleteCompleted: _handleDeleteCompleted,
                    onDeleteList: _handleDeleteList,
                    onSortItems: _handleSortItems,
                    showCompleted: settings.showCompletedForList(widget.listId),
                    onToggleShowCompleted: _handleToggleShowCompleted,
                    showCategories: settings.showCategoriesForList(widget.listId),
                    onToggleShowCategories: _handleToggleShowCategories,
                  ),
                ],
              ),
            ),
            Expanded(child: content),
          ],
        ),
        floatingActionButton: AnimatedSlide(
          duration: const Duration(milliseconds: 200),
          offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isFabVisible ? 1.0 : 0.0,
            child: FloatingActionButton(
              onPressed: _isFabVisible ? _showAddItemSheet : null,
              tooltip: l10n.addItem,
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );
    }

    // Normal mode (phone) with full AppBar
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE58325),
        foregroundColor: Colors.white,
        title: Text(widget.listName),
        actions: [
          ShoppingListDetailActionsMenu(
            onRefresh: _loadItems,
            onEditList: _handleEditList,
            onUncheckAll: _handleUncheckAll,
            onDeleteCompleted: _handleDeleteCompleted,
            onDeleteList: _handleDeleteList,
            onSortItems: _handleSortItems,
            showCompleted: settings.showCompletedForList(widget.listId),
            onToggleShowCompleted: _handleToggleShowCompleted,
            showCategories: settings.showCategoriesForList(widget.listId),
            onToggleShowCategories: _handleToggleShowCategories,
          ),
        ],
      ),
      body: content,
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 200),
        offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _isFabVisible ? 1.0 : 0.0,
          child: FloatingActionButton(
            onPressed: _isFabVisible ? _showAddItemSheet : null,
            tooltip: l10n.addItem,
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
