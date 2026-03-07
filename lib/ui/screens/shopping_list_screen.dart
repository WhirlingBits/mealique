import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mealique/data/remote/api_exceptions.dart';
import 'package:mealique/ui/widgets/shopping_list_actions_menu.dart';
import 'package:mealique/ui/widgets/sort_dialog.dart';
import 'package:provider/provider.dart';
import '../../data/sync/household_repository.dart';
import '../../models/shopping_list_model.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/settings_provider.dart';
import '../widgets/add_shopping_list_form.dart';
import 'shopping_list_detail_screen.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final HouseholdRepository _repository = HouseholdRepository();

  late Future<List<ShoppingList>> _listsFuture;
  String? _sortField;
  String _sortDirection = 'asc';

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _sortField = settings.shoppingListSortField;
    _sortDirection = settings.shoppingListSortDirection;
    _loadLists();
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

  void _editList(ShoppingList list) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddShoppingListForm(
          initialName: list.name,
          onAddList: (newName) async {
            final l10n = AppLocalizations.of(this.context)!;
            try {
              await _repository.updateShoppingListName(list.id, newName);
              _loadLists();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(this.context)
                  ..clearSnackBars()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(l10n.listCreatedSuccess(newName)),
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
                      content: Text(l10n.errorUpdating(e.toString())),
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
                    ]));
          }

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: SlidableAutoCloseBehavior(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: lists.length,
                itemBuilder: (context, index) {
                  final list = lists[index];
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
                    ),
                    clipBehavior: Clip.antiAlias,
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
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShoppingListDetailScreen(
                                listId: list.id,
                                listName: list.name,
                              ),
                            ),
                          ).then((_) => _loadLists());
                        },
                        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddListSheet,
        tooltip: l10n.createList,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
