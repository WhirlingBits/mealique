import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mealique/core/utils/responsive_utils.dart';
import 'package:mealique/data/remote/api_exceptions.dart';
import 'package:mealique/ui/widgets/shopping_list_actions_menu.dart';
import 'package:mealique/ui/widgets/sort_dialog.dart';
import 'package:provider/provider.dart';
import '../../data/sync/household_repository.dart';
import '../../models/shopping_list_model.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/settings_provider.dart';
import '../widgets/add_shopping_list_form.dart';
import 'edit_shopping_list_screen.dart';
import 'shopping_list_detail_screen.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final HouseholdRepository _repository = HouseholdRepository();
  final ScrollController _scrollController = ScrollController();

  late Future<List<ShoppingList>> _listsFuture;
  String? _sortField;
  String _sortDirection = 'asc';
  bool _isFabVisible = true;

  // For tablet master-detail view
  ShoppingList? _selectedList;

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _sortField = settings.shoppingListSortField;
    _sortDirection = settings.shoppingListSortDirection;
    _scrollController.addListener(_onScroll);
    _loadLists();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse && _isFabVisible) {
      setState(() => _isFabVisible = false);
    } else if (direction == ScrollDirection.forward && !_isFabVisible) {
      setState(() => _isFabVisible = true);
    }
  }

  void _loadLists() {
    setState(() {
      _listsFuture = _repository.getShoppingListsWithItemCount(
        orderBy: _sortField,
        orderDirection: _sortDirection,
      );
    });
  }

  Future<void> _handleRefresh() async {
    _loadLists();
  }

  void _showSortDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showSortDialog(
      context: context,
      options: [
        SortOption(field: 'name', label: l10n.sortByName),
        SortOption(field: 'created_at', label: l10n.sortByDateCreated),
        SortOption(field: 'update_at', label: l10n.sortByDateUpdated),
      ],
      currentField: _sortField,
      currentDirection: _sortDirection,
    );

    if (result != null) {
      _sortField = result.field;
      _sortDirection = result.direction;
      Provider.of<SettingsProvider>(context, listen: false)
          .setShoppingListSort(result.field, result.direction);
      _loadLists();
    }
  }

  void _showAddListSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding:
        EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddShoppingListForm(
          onAddList: (name) async {
            final l10n = AppLocalizations.of(this.context)!;
            try {
              await _repository.createShoppingList(name);
              _loadLists();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(this.context)
                  ..clearSnackBars()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(l10n.listCreatedSuccess(name)),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );
              }
            } catch (e) {
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(this.context)
                  ..clearSnackBars()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(l10n.errorCreating(e.toString())),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      duration: const Duration(seconds: 4),
                    ),
                  );
              }
            }
          },
        ),
      ),
    );
  }

  void _deleteList(String listId) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await _repository.deleteShoppingList(listId);
      _loadLists();
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(l10n.shoppingListDeleted),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(l10n.errorDeleting(e.toString())),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              duration: const Duration(seconds: 4),
            ),
          );
      }
    }
  }

  void _editList(ShoppingList list) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditShoppingListScreen(shoppingList: list),
      ),
    );
    if (result == true) {
      _loadLists();
    }
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLargeTablet = ResponsiveUtils.isLargeTablet(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE58325),
        foregroundColor: Colors.white,
        title: Text(l10n.shoppingLists),
        actions: [
          ShoppingListActionsMenu(
            onAddList: _showAddListSheet,
            onSort: _showSortDialog,
            onRefresh: _handleRefresh,
          ),
        ],
      ),
      body: FutureBuilder<List<ShoppingList>>(
        future: _listsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error!, _loadLists);
          }

          final lists = snapshot.data ?? [];

          if (lists.isEmpty) {
            return _buildEmptyState(l10n, theme);
          }

          if (isLargeTablet) {
            return _buildMasterDetailLayout(lists, l10n, theme);
          }
          return _buildPhoneLayout(lists, l10n, theme);
        },
      ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 200),
        offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _isFabVisible ? 1.0 : 0.0,
          child: FloatingActionButton(
            onPressed: _isFabVisible ? _showAddListSheet : null,
            tooltip: l10n.createList,
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            l10n.noListsFound,
            style: theme.textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.createFirstListHint,
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            onPressed: _showAddListSheet,
            label: Text(l10n.createFirstList),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          )
        ],
      ),
    );
  }

  /// Phone Layout: Full-screen list
  Widget _buildPhoneLayout(List<ShoppingList> lists, AppLocalizations l10n, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SlidableAutoCloseBehavior(
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: lists.length,
          itemBuilder: (context, index) {
            final list = lists[index];
            return _buildListCard(list, l10n, theme, onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShoppingListDetailScreen(
                    listId: list.id,
                    listName: list.name,
                  ),
                ),
              ).then((_) => _loadLists());
            });
          },
        ),
      ),
    );
  }

  /// Tablet Layout: Master-Detail view
  Widget _buildMasterDetailLayout(List<ShoppingList> lists, AppLocalizations l10n, ThemeData theme) {
    // Auto-select first list if none selected
    if (_selectedList == null && lists.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedList = lists.first;
          });
        }
      });
    }

    return Row(
      children: [
        // Master: List of shopping lists
        SizedBox(
          width: 320,
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            child: SlidableAutoCloseBehavior(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: lists.length,
                itemBuilder: (context, index) {
                  final list = lists[index];
                  final isSelected = _selectedList?.id == list.id;
                  return _buildListCard(
                    list,
                    l10n,
                    theme,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedList = list;
                      });
                    },
                  );
                },
              ),
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        // Detail: Selected list items with embedded mode
        Expanded(
          child: _selectedList != null
              ? ShoppingListDetailScreen(
            key: ValueKey(_selectedList!.id),
            listId: _selectedList!.id,
            listName: _selectedList!.name,
            embedded: true,
          )
              : _buildDetailPlaceholder(l10n),
        ),
      ],
    );
  }

  Widget _buildDetailPlaceholder(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.selectList,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard(
    ShoppingList list,
    AppLocalizations l10n,
    ThemeData theme, {
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    final String subtitle;
    if (list.itemCount == 0) {
      subtitle = l10n.allDone;
    } else if (list.itemCount == 1) {
      subtitle = l10n.openItemsSingular;
    } else {
      subtitle = l10n.openItemsPlural(list.itemCount);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: const Color(0xFFE58325), width: 2)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      color: isSelected ? const Color(0xFFE58325).withValues(alpha: 0.08) : null,
      child: Slidable(
        key: ValueKey(list.id),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.5,
          children: [
            SlidableAction(
              flex: 1,
              onPressed: (context) => _editList(list),
              backgroundColor: const Color(0xFFE58325),
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: l10n.edit,
            ),
            SlidableAction(
              flex: 1,
              onPressed: (context) => _deleteList(list.id),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: l10n.delete,
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Icon(
              Icons.list_alt_rounded,
              color: theme.colorScheme.primary,
            ),
          ),
          title: Text(
            list.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(subtitle),
          onTap: onTap,
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        ),
      ),
    );
  }
}
