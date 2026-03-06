import 'package:flutter/material.dart';
import 'package:mealique/data/sync/household_repository.dart';
import 'package:mealique/models/shopping_item_model.dart';
import 'package:mealique/ui/widgets/shopping_list_item_detail_actions_menu.dart';
import '../../l10n/app_localizations.dart';

class ShoppingListItemDetailScreen extends StatefulWidget {
  final ShoppingItem item;

  const ShoppingListItemDetailScreen({super.key, required this.item});

  @override
  State<ShoppingListItemDetailScreen> createState() =>
      _ShoppingListItemDetailScreenState();
}

class _ShoppingListItemDetailScreenState
    extends State<ShoppingListItemDetailScreen> {
  final _repository = HouseholdRepository();
  late ShoppingItem _item;
  bool _isSaving = false;
  bool _hasChanged = false;

  static const Color _accentColor = Color(0xFFE58325);

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  // ── Persistence ──────────────────────────────────────────────────────

  Future<void> _updateItem(ShoppingItem updatedItem) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSaving = true);
    try {
      await _repository.updateItem(updatedItem);
      if (mounted) {
        setState(() {
          _item = updatedItem;
          _isSaving = false;
          _hasChanged = true;
        });
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(l10n.itemUpdatedSuccess(_item.display)),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(l10n.errorUpdating(e.toString())),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
      }
    }
  }

  // ── Edit helpers ─────────────────────────────────────────────────────

  void _editDisplay() {
    final l10n = AppLocalizations.of(context)!;
    _showEditDialog(
      title: l10n.editDisplay,
      initialValue: _item.display,
      hint: l10n.newDisplayName,
      onSave: (value) => _updateItem(_item.copyWith(display: value)),
    );
  }

  void _editQuantity() {
    final l10n = AppLocalizations.of(context)!;
    _showEditDialog(
      title: l10n.editQuantity,
      initialValue: _item.quantity.toString(),
      hint: l10n.newQuantity,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onSave: (value) {
        final qty = double.tryParse(value);
        if (qty != null) {
          _updateItem(_item.copyWith(quantity: qty));
        }
      },
    );
  }

  void _editNotes() {
    final l10n = AppLocalizations.of(context)!;
    _showEditDialog(
      title: l10n.editNotes,
      initialValue: _item.note,
      hint: l10n.newNotes,
      maxLines: 3,
      onSave: (value) => _updateItem(_item.copyWith(note: value)),
    );
  }

  void _toggleChecked() {
    _updateItem(_item.copyWith(checked: !_item.checked));
  }

  // ── Generic edit dialog ──────────────────────────────────────────────

  void _showEditDialog({
    required String title,
    required String initialValue,
    required String hint,
    required void Function(String value) onSave,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    final controller = TextEditingController(text: initialValue);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: maxLines == 1
              ? (_) {
                  if (controller.text.isNotEmpty) {
                    Navigator.pop(ctx);
                    onSave(controller.text.trim());
                  }
                }
              : null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              onSave(controller.text.trim());
            },
            style: FilledButton.styleFrom(backgroundColor: _accentColor),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  // ── Actions-menu delegates ───────────────────────────────────────────

  void _handleMenuEdit() => _editDisplay();

  Future<void> _handleMenuDelete() async {
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
        await _repository.deleteItem(_item.id);
        if (mounted) {
          Navigator.pop(context, true); // Signal that data changed
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                content: Text(l10n.itemDeletedSuccess(_item.display)),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            );
        }
      }
    }
  }

  // ── UI ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(_hasChanged);
        }
      },
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(_hasChanged),
        ),
        title: Text(_item.display, overflow: TextOverflow.ellipsis),
        actions: [
          ShoppingListItemDetailActionsMenu(
            onEdit: _handleMenuEdit,
            onDelete: _handleMenuDelete,
          ),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Status card
                  _buildStatusCard(l10n, theme),
                  const SizedBox(height: 16),

                  // ── Details card
                  _buildDetailsCard(l10n, theme),
                  const SizedBox(height: 16),

                  // ── Notes card
                  _buildNotesCard(l10n, theme),
                ],
              ),
            ),
      ),
    );
  }

  // ── Status card ────────────────────────────────────────────────────

  Widget _buildStatusCard(AppLocalizations l10n, ThemeData theme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _toggleChecked,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                _item.checked
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: _item.checked ? Colors.green : Colors.grey,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _item.checked
                          ? l10n.checkedStatus
                          : l10n.uncheckedStatus,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _item.checked ? Colors.green : null,
                      ),
                    ),
                    Text(
                      l10n.toggleChecked,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // ── Details card ───────────────────────────────────────────────────

  Widget _buildDetailsCard(AppLocalizations l10n, ThemeData theme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Display name
          _buildEditableRow(
            icon: Icons.label_outline,
            label: l10n.itemDetails,
            value: _item.display.isNotEmpty ? _item.display : '–',
            onTap: _editDisplay,
          ),
          const Divider(height: 1, indent: 56),

          // Quantity
          _buildEditableRow(
            icon: Icons.numbers,
            label: l10n.quantity,
            value: _formatQuantity(_item.quantity),
            onTap: _editQuantity,
          ),
          const Divider(height: 1, indent: 56),

          // Food
          _buildInfoRow(
            icon: Icons.restaurant,
            label: l10n.food,
            value: _item.food?.name ?? l10n.noFood,
          ),
          const Divider(height: 1, indent: 56),

          // Unit
          _buildInfoRow(
            icon: Icons.straighten,
            label: l10n.unit,
            value: _item.unit?.name ?? l10n.noUnit,
          ),
          const Divider(height: 1, indent: 56),

          // Category / Label
          _buildInfoRow(
            icon: Icons.category_outlined,
            label: l10n.category,
            value: _item.food?.label?.name ??
                _item.label?.name ??
                l10n.noCategory,
            valueColor: _getLabelColor(),
          ),
        ],
      ),
    );
  }

  // ── Notes card ────────────────────────────────────────────────────

  Widget _buildNotesCard(AppLocalizations l10n, ThemeData theme) {
    final hasNotes = _item.note.isNotEmpty;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _editNotes,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.notes,
                  color: hasNotes ? _accentColor : Colors.grey, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.notes,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasNotes ? _item.note : l10n.noNotes,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: hasNotes ? null : Colors.grey,
                        fontStyle:
                            hasNotes ? FontStyle.normal : FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.edit_outlined, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ── Row helpers ──────────────────────────────────────────────────

  Widget _buildEditableRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: _accentColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const Icon(Icons.edit_outlined, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: _accentColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (valueColor != null) ...[
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: valueColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child:
                          Text(value, style: const TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Utilities ────────────────────────────────────────────────────

  String _formatQuantity(double qty) {
    if (qty == qty.roundToDouble()) {
      return qty.toInt().toString();
    }
    return qty.toStringAsFixed(2);
  }

  Color? _getLabelColor() {
    final colorStr = _item.food?.label?.color ?? _item.label?.color;
    if (colorStr == null || colorStr.isEmpty) return null;
    try {
      final hex = colorStr.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return null;
    }
  }
}
