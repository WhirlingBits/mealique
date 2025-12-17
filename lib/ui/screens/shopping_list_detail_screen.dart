import 'package:flutter/material.dart';
import '../../data/sync/shopping_list_repository.dart';
import '../../models/shopping_item.dart';
import '../../l10n/app_localizations.dart';

class ShoppingListDetailScreen extends StatefulWidget {
  final String listId;
  final String listName;

  const ShoppingListDetailScreen({
    super.key,
    required this.listId,
    required this.listName,
  });

  @override
  State<ShoppingListDetailScreen> createState() => _ShoppingListDetailScreenState();
}

class _ShoppingListDetailScreenState extends State<ShoppingListDetailScreen> {
  final _repository = ShoppingListRepository();
  late Future<List<ShoppingItem>> _itemsFuture;

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
      final newItem = item.copyWith(isChecked: !item.isChecked);
      await _repository.updateItem(newItem);
      _loadItems(); // Liste neu laden
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    }
  }

  Future<void> _addItem(String name) async {
    try {
      await _repository.addItem(widget.listId, name);
      _loadItems();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Hinzufügen: $e')),
        );
      }
    }
  }

  void _showAddItemDialog() {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Neues Item'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'z.B. Milch'),
          onSubmitted: (_) {
            if (controller.text.isNotEmpty) {
              _addItem(controller.text);
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
                _addItem(controller.text);
                Navigator.pop(context);
              }
            },
            child: Text(l10n.addRecipe), // "Hinzufügen"
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listName),
      ),
      body: FutureBuilder<List<ShoppingItem>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(l10n.noResultsFound));
          }

          final items = snapshot.data!;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: Checkbox(
                  value: item.isChecked,
                  onChanged: (_) => _toggleItem(item),
                ),
                title: Text(
                  item.name,
                  style: TextStyle(
                    decoration: item.isChecked
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: item.isChecked ? Colors.grey : null,
                  ),
                ),
              );
            },
          );
        },
      ),
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        tooltip: 'Item hinzufügen',
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}