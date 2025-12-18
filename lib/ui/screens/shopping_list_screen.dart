import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../data/sync/shopping_list_repository.dart';
import '../../models/shopping_list.dart';
import 'shopping_list_detail_screen.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final ShoppingListRepository _repository = ShoppingListRepository();
  late Future<List<ShoppingList>> _listsFuture;

  @override
  void initState() {
    super.initState();
    _loadLists();
  }

  void _loadLists() {
    setState(() {
      _listsFuture = _repository.getAllLists();
    });
  }

  void _showCreateListDialog() {
    _showListDialog(title: 'Neue Einkaufsliste', isEdit: false);
  }

  void _showEditListDialog(ShoppingList list) {
    _showListDialog(
        title: AppLocalizations.of(context)!.editList,
        initialName: list.name,
        isEdit: true,
        listId: list.id);
  }

  void _showListDialog({
    required String title,
    String? initialName,
    required bool isEdit,
    String? listId,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final controller = TextEditingController(text: initialName);
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'z.B. Wocheneinkauf',
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  try {
                    if (isEdit && listId != null) {
                      await _repository.updateList(listId, name);
                    } else {
                      await _repository.createList(name);
                    }
                    if (context.mounted) {
                      Navigator.pop(context);
                      _loadLists();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Fehler: $e')),
                      );
                    }
                  }
                }
              },
              child: Text(isEdit ? 'Speichern' : 'Erstellen'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteList(ShoppingList list) async {
    try {
      await _repository.deleteList(list.id);
      _loadLists();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${list.name} gelöscht')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Löschen: $e')),
        );
      }
    }
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
          } else if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Keine Einkaufslisten gefunden.'));
          }

          final lists = snapshot.data!;

          return SlidableAutoCloseBehavior(
            child: ListView.builder(
              itemCount: lists.length,
              itemBuilder: (context, index) {
                final list = lists[index];
                return Slidable(
                  key: ValueKey(list.id),
                  startActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) => _showEditListDialog(list),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: l10n.edit,
                      ),
                      SlidableAction(
                        onPressed: (context) => _deleteList(list),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: l10n.delete,
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.list_alt),
                    title: Text(list.name),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShoppingListDetailScreen(
                            listId: list.id,
                            listName: list.name,
                          ),
                        ),
                      );
                      _loadLists();
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateListDialog,
        tooltip: l10n.addList,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
