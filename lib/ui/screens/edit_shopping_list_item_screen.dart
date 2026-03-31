import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/sync/household_repository.dart';
import '../../data/sync/recipe_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/food_model.dart';
import '../../models/shopping_item_model.dart';

class EditShoppingListItemScreen extends StatefulWidget {
  final ShoppingItem item;

  const EditShoppingListItemScreen({super.key, required this.item});

  @override
  State<EditShoppingListItemScreen> createState() =>
      _EditShoppingListItemScreenState();
}

class _EditShoppingListItemScreenState
    extends State<EditShoppingListItemScreen> {
  final _repository = HouseholdRepository();
  final _recipeRepo = RecipeRepository();

  late final TextEditingController _displayController;
  late final TextEditingController _quantityController;
  late final TextEditingController _noteController;
  late final TextEditingController _foodController;
  final _foodFocusNode = FocusNode();

  late bool _checked;
  String? _selectedUnitId;
  String? _selectedFoodId;

  List<Food>? _foods;
  List<ShoppingItemUnit>? _units;
  bool _dataLoading = false;
  bool _saving = false;

  static const Color _accent = Color(0xFFE58325);

  @override
  void initState() {
    super.initState();
    final item = widget.item;

    _displayController = TextEditingController(text: item.display);
    _quantityController = TextEditingController(
      text: item.quantity == item.quantity.roundToDouble()
          ? item.quantity.round().toString()
          : item.quantity.toString(),
    );
    _noteController = TextEditingController(text: item.note);
    _foodController = TextEditingController(text: item.food?.name ?? '');
    _checked = item.checked;
    _selectedUnitId = item.unit?.id ?? item.unitId;
    _selectedFoodId = item.food?.id ?? item.foodId;

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _dataLoading = true);
    try {
      final results = await Future.wait([
        _recipeRepo.getFoods(),
        _recipeRepo.getUnits(),
      ]);
      if (mounted) {
        setState(() {
          _foods = results[0] as List<Food>;
          _units = results[1] as List<ShoppingItemUnit>;
          _dataLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _dataLoading = false);
    }
  }

  Future<void> _submitAll() async {
    setState(() => _saving = true);
    final l10n = AppLocalizations.of(context)!;

    final qty = double.tryParse(_quantityController.text.trim()) ?? widget.item.quantity;

    // Build updated food object
    ShoppingItemFood? updatedFood;
    if (_selectedFoodId != null && _foods != null) {
      final matchedFood = _foods!.where((f) => f.id == _selectedFoodId).firstOrNull;
      if (matchedFood != null) {
        updatedFood = ShoppingItemFood(id: matchedFood.id, name: matchedFood.name);
      }
    }
    // If no food selected but text was typed, keep original food
    updatedFood ??= widget.item.food;

    // Build updated unit object
    ShoppingItemUnit? updatedUnit;
    if (_selectedUnitId != null && _units != null) {
      updatedUnit = _units!.where((u) => u.id == _selectedUnitId).firstOrNull;
    }

    final updatedItem = widget.item.copyWith(
      display: _displayController.text.trim(),
      quantity: qty,
      note: _noteController.text.trim(),
      checked: _checked,
      food: updatedFood,
      foodId: _selectedFoodId ?? widget.item.foodId,
      unit: updatedUnit,
      unitId: _selectedUnitId,
    );

    try {
      await _repository.updateItem(updatedItem);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.itemSaved),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      debugPrint('Error updating shopping item: $e');
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

  // ===================================================================
  // BUILD
  // ===================================================================

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
          title: Text(l10n.editShoppingItem),
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
                onPressed: _submitAll,
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Display Name ──
              _buildSectionHeader(l10n.displayName, Icons.label_outline),
              const SizedBox(height: 8),
              TextField(
                controller: _displayController,
                decoration: InputDecoration(
                  labelText: l10n.displayName,
                  hintText: l10n.displayNameHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // ── Quantity & Unit ──
              _buildSectionHeader(l10n.quantity, Icons.numbers),
              const SizedBox(height: 8),
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _quantityController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                      ],
                      decoration: InputDecoration(
                        labelText: l10n.quantity,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _buildUnitDropdown(l10n)),
                ],
              ),
              const SizedBox(height: 24),

              // ── Food ──
              _buildSectionHeader(l10n.food, Icons.restaurant),
              const SizedBox(height: 8),
              _buildFoodAutocomplete(l10n),
              const SizedBox(height: 24),

              // ── Notes ──
              _buildSectionHeader(l10n.notes, Icons.notes),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.notesOptional,
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              // ── Status ──
              _buildSectionHeader(l10n.checkedStatus_label, Icons.check_circle_outline),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: SwitchListTile(
                  title: Text(_checked ? l10n.checkedStatus : l10n.uncheckedStatus),
                  subtitle: Text(l10n.toggleChecked),
                  secondary: Icon(
                    _checked ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: _checked ? Colors.green : Colors.grey,
                  ),
                  value: _checked,
                  activeThumbColor: _accent,
                  onChanged: (val) => setState(() => _checked = val),
                ),
              ),
              const SizedBox(height: 24),

              // ── Category ──
              if (widget.item.food?.label != null || widget.item.label != null) ...[
                _buildSectionHeader(l10n.category, Icons.category_outlined),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: _buildLabelColorDot(),
                    title: Text(
                      widget.item.food?.label?.name ??
                          widget.item.label?.name ??
                          l10n.noCategory,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ── Save Button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _submitAll,
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
    );
  }

  // ===================================================================
  // SHARED WIDGETS
  // ===================================================================

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: _accent),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildUnitDropdown(AppLocalizations l10n) {
    if (_dataLoading || _units == null) {
      return const SizedBox(
        height: 48,
        child: Center(
          child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }
    return DropdownButtonFormField<String?>(
      initialValue: _selectedUnitId,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.unit,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: [
        DropdownMenuItem<String?>(
          value: null,
          child: Text('— ${l10n.noUnit}', style: TextStyle(color: Colors.grey[600])),
        ),
        ..._units!.map((u) => DropdownMenuItem(value: u.id, child: Text(u.name))),
      ],
      onChanged: (val) => setState(() => _selectedUnitId = val),
    );
  }

  Widget _buildFoodAutocomplete(AppLocalizations l10n) {
    final foodOptions = _foods ?? <Food>[];
    return RawAutocomplete<Food>(
      textEditingController: _foodController,
      focusNode: _foodFocusNode,
      displayStringForOption: (food) => food.name,
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.toLowerCase();
        if (query.isEmpty) return const Iterable.empty();
        return foodOptions.where((food) => food.name.toLowerCase().contains(query));
      },
      onSelected: (food) => setState(() => _selectedFoodId = food.id),
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: l10n.food,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          onChanged: (_) {
            if (_selectedFoodId != null) setState(() => _selectedFoodId = null);
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final food = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(food.name),
                    onTap: () => onSelected(food),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabelColorDot() {
    final colorStr = widget.item.food?.label?.color ?? widget.item.label?.color;
    if (colorStr == null || colorStr.isEmpty) {
      return Icon(Icons.category_outlined, color: Colors.grey[400]);
    }
    try {
      final hex = colorStr.replaceFirst('#', '');
      final color = Color(int.parse('FF$hex', radix: 16));
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
    } catch (_) {
      return Icon(Icons.category_outlined, color: Colors.grey[400]);
    }
  }

  @override
  void dispose() {
    _displayController.dispose();
    _quantityController.dispose();
    _noteController.dispose();
    _foodController.dispose();
    _foodFocusNode.dispose();
    super.dispose();
  }
}

