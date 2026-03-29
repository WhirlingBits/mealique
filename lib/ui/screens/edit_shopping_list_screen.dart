import 'package:flutter/material.dart';
import '../../data/sync/household_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/shopping_list_model.dart';

/// Full-screen editor for a shopping list's metadata (name, etc.).
/// Returns `true` via [Navigator.pop] when the list was updated.
class EditShoppingListScreen extends StatefulWidget {
  final ShoppingList shoppingList;

  const EditShoppingListScreen({super.key, required this.shoppingList});

  @override
  State<EditShoppingListScreen> createState() => _EditShoppingListScreenState();
}

class _EditShoppingListScreenState extends State<EditShoppingListScreen> {
  final _repository = HouseholdRepository();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  bool _saving = false;

  static const Color _accent = Color(0xFFE58325);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.shoppingList.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    final newName = _nameController.text.trim();

    // Nothing changed – just go back
    if (newName == widget.shoppingList.name) {
      Navigator.of(context).pop(false);
      return;
    }

    setState(() => _saving = true);

    try {
      await _repository.updateShoppingListName(widget.shoppingList.id, newName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.listUpdatedSuccess(newName)),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      debugPrint('Error updating shopping list: $e');
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorUpdating(e.toString())),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Future<bool> _onWillPop() async {
    final newName = _nameController.text.trim();
    if (newName == widget.shoppingList.name) return true;

    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.discardChanges),
        content: Text(l10n.discardChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.discard, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          title: Text(l10n.editList),
          actions: [
            if (_saving)
              const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.check),
                tooltip: l10n.save,
                onPressed: _save,
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── List Name ──
                _buildSectionHeader(l10n.listName, Icons.list_alt_rounded),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l10n.listName,
                    hintText: l10n.enterNewName,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.fillAllFields;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // ── Info Section ──
                _buildSectionHeader(l10n.details, Icons.info_outline),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.calendar_today, size: 20),
                        title: Text(l10n.createdAt),
                        subtitle: Text(_formatDate(widget.shoppingList.createdAt)),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.update, size: 20),
                        title: Text(l10n.updatedAt),
                        subtitle: Text(_formatDate(widget.shoppingList.updatedAt)),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.shopping_cart, size: 20),
                        title: Text(l10n.items),
                        subtitle: Text('${widget.shoppingList.listItems.length}'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── Save Button ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check, size: 20),
                    label: Text(l10n.save, style: const TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: _accent),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} '
          '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }
}

