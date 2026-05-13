import 'package:flutter/material.dart';
import 'package:mealique/data/remote/labels_api.dart';
import 'package:mealique/models/shopping_item_model.dart';
import '../../l10n/app_localizations.dart';

/// Screen zur Verwaltung von Shopping-Kategorien/Labels
class ShoppingLabelsScreen extends StatefulWidget {
  const ShoppingLabelsScreen({super.key});

  @override
  State<ShoppingLabelsScreen> createState() => _ShoppingLabelsScreenState();
}

class _ShoppingLabelsScreenState extends State<ShoppingLabelsScreen> {
  final LabelsApi _labelsApi = LabelsApi();

  List<ShoppingItemLabel>? _labels;
  bool _loading = true;
  String? _error;

  static const Color _accent = Color(0xFFE58325);

  // Vordefinierte Farben zur Auswahl
  static const List<String> _colorOptions = [
    '#E58325', // Orange (Accent)
    '#4CAF50', // Grün
    '#2196F3', // Blau
    '#9C27B0', // Lila
    '#F44336', // Rot
    '#FF9800', // Orange
    '#795548', // Braun
    '#607D8B', // Grau-Blau
    '#E91E63', // Pink
    '#00BCD4', // Türkis
    '#FFEB3B', // Gelb
    '#8BC34A', // Hellgrün
  ];

  @override
  void initState() {
    super.initState();
    _loadLabels();
  }

  Future<void> _loadLabels() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final labels = await _labelsApi.getLabels();
      if (mounted) {
        setState(() {
          _labels = labels;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _createDefaultLabels() async {
    final l10n = AppLocalizations.of(context)!;

    // Standard-Kategorien mit deutschen und englischen Namen
    final locale = Localizations.localeOf(context).languageCode;
    final defaultLabels = locale == 'de' ? [
      {'name': 'Obst & Gemüse', 'color': '#4CAF50'},
      {'name': 'Milch & Käse', 'color': '#2196F3'},
      {'name': 'Fleisch & Fisch', 'color': '#F44336'},
      {'name': 'Brot & Backwaren', 'color': '#795548'},
      {'name': 'Getränke', 'color': '#00BCD4'},
      {'name': 'Tiefkühl', 'color': '#607D8B'},
      {'name': 'Süßwaren', 'color': '#E91E63'},
      {'name': 'Haushalt', 'color': '#9C27B0'},
    ] : [
      {'name': 'Fruits & Vegetables', 'color': '#4CAF50'},
      {'name': 'Dairy & Cheese', 'color': '#2196F3'},
      {'name': 'Meat & Fish', 'color': '#F44336'},
      {'name': 'Bread & Bakery', 'color': '#795548'},
      {'name': 'Beverages', 'color': '#00BCD4'},
      {'name': 'Frozen', 'color': '#607D8B'},
      {'name': 'Sweets', 'color': '#E91E63'},
      {'name': 'Household', 'color': '#9C27B0'},
    ];

    setState(() => _loading = true);

    try {
      for (final label in defaultLabels) {
        await _labelsApi.createLabel(
          name: label['name']!,
          color: label['color']!,
        );
      }
      await _loadLabels();
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
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showAddEditDialog({ShoppingItemLabel? label}) async {
    final l10n = AppLocalizations.of(context)!;
    final isEdit = label != null;

    final nameController = TextEditingController(text: label?.name ?? '');
    String selectedColor = label?.color ?? _colorOptions.first;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? l10n.editLabel : l10n.addLabel),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.labelName,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.labelColor, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _colorOptions.map((color) {
                  final isSelected = selectedColor == color;
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedColor = color),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _parseColor(color),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.black, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [BoxShadow(color: Colors.black26, blurRadius: 4)]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                Navigator.of(ctx).pop({
                  'name': nameController.text.trim(),
                  'color': selectedColor,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      try {
        if (isEdit) {
          final updatedLabel = await _labelsApi.updateLabel(
            label.id,
            name: result['name']!,
            color: result['color']!,
          );
          if (mounted) {
            setState(() {
              final index = _labels!.indexWhere((l) => l.id == label.id);
              if (index != -1) _labels![index] = updatedLabel;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.labelUpdated(result['name']!)),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          final newLabel = await _labelsApi.createLabel(
            name: result['name']!,
            color: result['color']!,
          );
          if (mounted) {
            setState(() {
              _labels = [...(_labels ?? []), newLabel];
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.labelCreated(result['name']!)),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.error}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteLabel(ShoppingItemLabel label) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteLabel),
        content: Text(l10n.confirmDeleteLabel(label.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _labelsApi.deleteLabel(label.id);
        if (mounted) {
          setState(() {
            _labels = _labels?.where((l) => l.id != label.id).toList();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.labelDeleted(label.name)),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.error}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Color _parseColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty) return Colors.grey;
    try {
      final hex = colorStr.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        title: Text(l10n.shoppingLabels),
      ),
      body: _buildBody(l10n),
      floatingActionButton: FloatingActionButton(
        heroTag: 'shopping_labels_fab',
        onPressed: () => _showAddEditDialog(),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLabels,
              child: Text(l10n.tryAgain),
            ),
          ],
        ),
      );
    }

    if (_labels == null || _labels!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.category_outlined, size: 64, color: _accent.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text(
                l10n.noLabelsFound,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _createDefaultLabels,
                icon: const Icon(Icons.auto_fix_high),
                label: Text(l10n.defaultLabels),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLabels,
      child: ReorderableListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: _labels!.length,
        onReorder: (oldIndex, newIndex) {
          // TODO: Implement reordering via API if supported
          setState(() {
            if (newIndex > oldIndex) newIndex--;
            final item = _labels!.removeAt(oldIndex);
            _labels!.insert(newIndex, item);
          });
        },
        itemBuilder: (context, index) {
          final label = _labels![index];
          return Card(
            key: ValueKey(label.id),
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _parseColor(label.color),
                  shape: BoxShape.circle,
                ),
              ),
              title: Text(
                label.name,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    color: _accent,
                    onPressed: () => _showAddEditDialog(label: label),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red,
                    onPressed: () => _deleteLabel(label),
                  ),
                  ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

