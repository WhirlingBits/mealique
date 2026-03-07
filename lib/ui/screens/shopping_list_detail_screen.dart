import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mealique/data/remote/api_exceptions.dart';
import 'package:mealique/providers/settings_provider.dart';
import 'package:mealique/ui/screens/shopping_list_item_detail_screen.dart';
import 'package:mealique/ui/widgets/shopping_list_detail_actions_menu.dart';
import 'package:mealique/ui/widgets/sort_dialog.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../data/sync/household_repository.dart';
import '../../models/shopping_item_model.dart';
import '../widgets/add_shopping_list_item_form.dart';

class ShoppingListDetailScreen extends StatefulWidget {
  final String listId;
  final String listName;

  const ShoppingListDetailScreen({
    super.key,
    required this.listId,
    required this.listName,
  });

  @override
  State<ShoppingListDetailScreen> createState() =>
      _ShoppingListDetailScreenState();
}

class _ShoppingListDetailScreenState extends State<ShoppingListDetailScreen> {
  final _repository = HouseholdRepository();
  late Future<List<ShoppingItem>> _itemsFuture;

  final Color _accentColor = const Color(0xFFE58325);

  @override
  void initState() {
    super.initState();
    _loadItems();
    // Load per-list settings
    Provider.of<SettingsProvider>(context, listen: false)
        .loadListSettings(widget.listId);
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

  void _handleEditList() {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: widget.listName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.renameList),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.enterNewName),
          onSubmitted: (_) {
            if (controller.text.trim().isNotEmpty) {
              Navigator.pop(ctx, controller.text.trim());
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(ctx, controller.text.trim());
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    ).then((newName) async {
      if (newName != null && newName is String && mounted) {
        try {
          await _repository.updateShoppingListName(widget.listId, newName);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.listCreatedSuccess(newName)),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            _showError(l10n.errorUpdating(e.toString()));
          }
        }
      }
    });
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

    if (field == null) return items;

    final sorted = List<ShoppingItem>.from(items);
    sorted.sort((a, b) {
      int result;
      switch (field) {
        case 'name':
          result = a.display.toLowerCase().compareTo(b.display.toLowerCase());
          break;
        case 'checked':
          result = (a.checked ? 1 : 0).compareTo(b.checked ? 1 : 0);
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

  Future<void> _editItem(ShoppingItem item, String newName) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final newItem = item.copyWith(display: newName);
      await _repository.updateItem(newItem);
      _loadItems();
    } catch (e) {
      _showError(l10n.errorEditing(e.toString()));
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
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
    final controller = TextEditingController(text: item.display);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editItem),
        content: TextField(
          controller: controller,
          autofocus: true,
          onSubmitted: (_) {
            if (controller.text.isNotEmpty) {
              _editItem(item, controller.text);
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _editItem(item, controller.text);
                Navigator.pop(context);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
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
      body: FutureBuilder<List<ShoppingItem>>(
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
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: displayItems.length,
                  itemBuilder: (context, index) => _buildItemTile(displayItems[index]),
                ),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemSheet,
        tooltip: l10n.addItem,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
