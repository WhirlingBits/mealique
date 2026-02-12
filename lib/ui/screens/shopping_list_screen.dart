import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: FutureBuilder<List<ShoppingList>>(
        future: _listsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          }

          final lists = snapshot.data ?? [];

          if (lists.isEmpty) {
            return Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Keine Listen vorhanden'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _showAddListSheet,
                        child: const Text('Liste erstellen'),
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

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
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
                            ),
                            SlidableAction(
                              flex: 1,
                              onPressed: (context) => _deleteList(list.id),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                            ),
                          ],
                        ),
                        child: Card(
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            title: Text(
                              list.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('${list.itemCount} Elemente'),
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
