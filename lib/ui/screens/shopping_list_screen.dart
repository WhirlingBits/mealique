import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mealique/data/remote/api_exceptions.dart';
import '../../data/sync/household_repository.dart';
import '../../models/shopping_list_model.dart';
import '../../l10n/app_localizations.dart';
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

  @override
  void initState() {
    super.initState();
    _loadLists();
  }

  void _loadLists() {
    setState(() {
      _listsFuture = _repository.getShoppingListsWithItemCount();
    });
  }

  Future<void> _handleRefresh() async {
    // Re-trigger the future to rebuild the UI with fresh data
    _loadLists();
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
            await _repository.createShoppingList(name);
            _loadLists();
            if (mounted) Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _deleteList(String listId) async {
    await _repository.deleteShoppingList(listId);
    _loadLists();
  }

  Widget _buildErrorWidget(Object error, VoidCallback onRetry) {
    //final l10n = AppLocalizations.of(context)!;
    String errorMessage;

    if (error is DioException && error.error is ApiException) {
      final apiError = error.error as ApiException;
      if (apiError is NetworkException) {
        errorMessage = 'Bitte prüfe deine Internetverbindung.'; // TODO: l10n
      } else if (apiError is ServerException) {
        errorMessage = 'Ein Serverfehler ist aufgetreten. Bitte versuche es später erneut.'; // TODO: l10n
      } else {
        errorMessage = apiError.message;
      }
    } else {
      errorMessage = 'Ein unerwarteter Fehler ist aufgetreten.'; // TODO: l10n
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Erneut versuchen'), // TODO: l10n
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
        title: Text(l10n.shoppingLists), // TODO: Add to l10n
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
                        'Keine Einkaufslisten',
                        style: theme.textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Lege deine erste Liste an, um loszulegen.',
                        style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        onPressed: _showAddListSheet,
                        label: const Text('Erste Liste erstellen'),
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
                    subtitle = 'Alle erledigt'; // TODO: l10n
                  } else if (list.itemCount == 1) {
                    subtitle = '1 offenes Element'; // TODO: l10n
                  } else {
                    subtitle = '${list.itemCount} offene Elemente'; // TODO: l10n
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
                            onPressed: (context) {
                              // TODO: Liste bearbeiten Logik implementieren
                            },
                            backgroundColor: const Color(0xFFE58325),
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: 'Bearbeiten',
                          ),
                          SlidableAction(
                            flex: 1,
                            onPressed: (context) => _deleteList(list.id),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Löschen',
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
                          final screenHeight = MediaQuery.of(context).size.height;
                          final topPadding = MediaQuery.of(context).padding.top;
                          const appBarHeight = kToolbarHeight;

                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            constraints: BoxConstraints(
                              maxHeight: screenHeight - (topPadding + appBarHeight),
                            ),
                            builder: (context) => ShoppingListDetailScreen(
                              listId: list.id,
                              listName: list.name,
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
        tooltip: 'Liste erstellen',
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
