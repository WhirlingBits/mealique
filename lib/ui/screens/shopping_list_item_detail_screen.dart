import 'package:flutter/material.dart';
import 'package:mealique/data/sync/household_repository.dart';
import 'package:mealique/models/shopping_item_model.dart';
import 'package:mealique/ui/widgets/shopping_list_item_detail_actions_menu.dart';
import '../../l10n/app_localizations.dart';

class ShoppingListItemDetailScreen extends StatefulWidget {
  final ShoppingItem item;

  const ShoppingListItemDetailScreen({super.key, required this.item});

  @override
  State<ShoppingListItemDetailScreen> createState() => _ShoppingListItemDetailScreenState();
}

class _ShoppingListItemDetailScreenState extends State<ShoppingListItemDetailScreen> {
  final _repository = HouseholdRepository();

  void _handleEdit() {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: widget.item.display);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.editItem),
        content: TextField(
          controller: controller,
          autofocus: true,
          onSubmitted: (_) {
            if (controller.text.isNotEmpty) {
              Navigator.pop(ctx, controller.text);
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
              if (controller.text.isNotEmpty) {
                Navigator.pop(ctx, controller.text);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    ).then((newName) async {
      if (newName != null && newName is String && mounted) {
        try {
          final updatedItem = widget.item.copyWith(display: newName);
          await _repository.updateItem(updatedItem);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.changesSaved),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.errorEditing(e.toString())),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    });
  }

  Future<void> _handleDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteItem),
        content: Text(l10n.confirmDeleteItem),
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
        await _repository.deleteItem(widget.item.id);
        if (mounted) {
          Navigator.pop(context); // Go back
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.itemDeletedSuccess(widget.item.display)),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.errorDeleting(e.toString())),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE58325),
        foregroundColor: Colors.white,
        title: Text(widget.item.display),
        actions: [
          ShoppingListItemDetailActionsMenu(
            onEdit: _handleEdit,
            onDelete: _handleDelete,
          ),
        ],
      ),
      body: Center(
        child: Text(l10n.itemDetailsPlaceholder),
      ),
    );
  }
}
