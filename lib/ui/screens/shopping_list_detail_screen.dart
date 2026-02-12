import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mealique/ui/screens/shopping_list_item_detail_screen.dart';
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
  }

  void _loadItems() {
    setState(() {
      _itemsFuture = _repository.getItemsForList(widget.listId);
    });
  }

  Future<void> _toggleItem(ShoppingItem item) async {
    try {
      final newItem = item.copyWith(checked: !item.checked);
      await _repository.updateItem(newItem);
      _loadItems();
    } catch (e) {
      _showError('Fehler beim Aktualisieren: $e');
    }
  }

  // Diese Signatur wurde angepasst, um das neue komplexe Objekt zu verarbeiten
  Future<void> _addComplexItem(NewShoppingItem newItemData) async {
    try {
      // Hier müssten die zusätzlichen Felder (foodId, quantity, unit, etc.)
      // in deiner echten App-Logik verarbeitet werden.
      // Fürs Erste fügen wir den Namen des Foods als Display-Text hinzu.
      // Hinweis: Ggf. musst du addItem im Repository anpassen, um alle Felder zu speichern.
      await _repository.addItem(newItemData.listId, 'Item (ID: ${newItemData.foodId}, Menge: ${newItemData.quantity})');
      _loadItems();
    } catch (e) {
      _showError('Fehler beim Hinzufügen: $e');
    }
  }

  Future<void> _deleteItem(ShoppingItem item) async {
    try {
      await _repository.deleteItem(item.id);
      _loadItems();
    } catch (e) {
      _showError('Fehler beim Löschen: $e');
      _loadItems();
    }
  }

  Future<void> _editItem(ShoppingItem item, String newName) async {
    try {
      final newItem = item.copyWith(display: newName);
      await _repository.updateItem(newItem);
      _loadItems();
    } catch (e) {
      _showError('Fehler beim Bearbeiten: $e');
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
      isScrollControlled: true, // Wichtig für Tastatur-Handling
      backgroundColor: Colors.transparent,
      builder: (context) => AddShoppingListItemForm(
        shoppingListId: widget.listId,
        onAddItem: (NewShoppingItem newItem) {
          Navigator.pop(context); // Sheet schließen
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
        title: const Text('Item bearbeiten'),
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
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  Map<String, List<ShoppingItem>> _groupItemsByCategory(
      List<ShoppingItem> items) {
    final Map<String, List<ShoppingItem>> grouped = {};
    for (var item in items) {
      const category = 'Allgemein';
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(item);
    }
    return grouped;
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
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

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              widget.listName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),

          // Content
          Expanded(
            child: Stack(
              children: [
                FutureBuilder<List<ShoppingItem>>(
                  future: _itemsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Fehler: ${snapshot.error}'),
                      );
                    }
                    final items = snapshot.data ?? [];
                    final groupedItems = _groupItemsByCategory(items);

                    return SlidableAutoCloseBehavior(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          _loadItems();
                          await Future.delayed(
                              const Duration(milliseconds: 500));
                        },
                        child: CustomScrollView(
                          slivers: [
                            if (items.isEmpty)
                              const SliverFillRemaining(
                                child: Center(
                                  child: Text('Diese Liste ist leer.'),
                                ),
                              )
                            else
                              SliverPadding(
                                padding:
                                const EdgeInsets.fromLTRB(16, 16, 16, 80),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                      final category =
                                      groupedItems.keys.elementAt(index);
                                      final categoryItems =
                                      groupedItems[category]!;

                                      return Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          _buildSectionTitle(category),
                                          ...categoryItems.map((item) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8.0),
                                            child: ClipRRect(
                                              borderRadius:
                                              BorderRadius.circular(12),
                                              child: Slidable(
                                                key: ValueKey(item.id),
                                                startActionPane: ActionPane(
                                                  motion:
                                                  const ScrollMotion(),
                                                  extentRatio: 0.5,
                                                  children: [
                                                    SlidableAction(
                                                      flex: 1,
                                                      onPressed: (_) =>
                                                          _showEditItemDialog(
                                                              item),
                                                      backgroundColor:
                                                      const Color(
                                                          0xFFE58325),
                                                      foregroundColor:
                                                      Colors.white,
                                                      icon: Icons.edit,
                                                    ),
                                                    SlidableAction(
                                                      flex: 1,
                                                      onPressed: (_) =>
                                                          _deleteItem(item),
                                                      backgroundColor:
                                                      const Color(
                                                          0xFFFE4A49),
                                                      foregroundColor:
                                                      Colors.white,
                                                      icon: Icons.delete,
                                                    ),
                                                  ],
                                                ),
                                                child: CheckboxListTile(
                                                  value: item.checked,
                                                  onChanged: (val) =>
                                                      _toggleItem(item),
                                                  title: GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ShoppingListItemDetailScreen(
                                                                  item: item),
                                                        ),
                                                      );
                                                    },
                                                    child: Text(item.display,
                                                        style: TextStyle(
                                                          decoration: item.checked
                                                              ? TextDecoration
                                                              .lineThrough
                                                              : TextDecoration
                                                              .none,
                                                          color: item.checked
                                                              ? Colors.grey
                                                              : null,
                                                        )),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ))
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
                  },
                ),
                Positioned(
                  bottom: 16 + bottomPadding,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: _showAddItemSheet, // Hier wird jetzt das Sheet aufgerufen
                    tooltip: 'Item hinzufügen',
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
