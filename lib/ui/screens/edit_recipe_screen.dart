import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/sync/recipe_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/food_model.dart';
import '../../models/recipes_model.dart';
import '../../models/shopping_item_model.dart';

/// A single ingredient entry in the edit form.
class _IngredientEntry {
  double quantity;
  String? unitId;
  String? unitName;
  String? foodId;
  String foodName;
  String note;

  _IngredientEntry({
    this.quantity = 1,
    this.unitId,
    this.unitName,
    this.foodId,
    this.foodName = '',
    this.note = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      if (unitId != null) 'unitId': unitId,
      if (unitName != null) 'unitName': unitName,
      if (foodId != null) 'foodId': foodId,
      'foodName': foodName,
      'note': note,
    };
  }
}

class EditRecipeScreen extends StatefulWidget {
  final Recipe recipe;

  const EditRecipeScreen({super.key, required this.recipe});

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  // -- Name & Rating --
  late final TextEditingController _nameController;
  late int _rating;

  // -- Details --
  late final TextEditingController _descController;
  late final TextEditingController _servingsController;
  late final TextEditingController _yieldController;
  late final TextEditingController _totalTimeController;
  late final TextEditingController _prepTimeController;
  late final TextEditingController _cookTimeController;

  // -- Ingredients --
  final _ingredientQtyController = TextEditingController(text: '1');
  final _ingredientNoteController = TextEditingController();
  final _ingredientFoodController = TextEditingController();
  final _ingredientFoodFocusNode = FocusNode();
  String? _selectedUnitId;
  String? _selectedFoodId;
  final List<_IngredientEntry> _ingredients = [];

  // -- Extras --
  final _categoryInputController = TextEditingController();
  final _tagInputController = TextEditingController();
  final _toolInputController = TextEditingController();
  final _instructionInputController = TextEditingController();
  late final TextEditingController _recipeNoteController;
  final List<String> _categories = [];
  final List<String> _tags = [];
  final List<String> _tools = [];
  final List<String> _instructionSteps = [];

  // -- API data --
  final _recipeRepo = RecipeRepository();
  List<Food>? _foods;
  List<ShoppingItemUnit>? _units;
  bool _dataLoading = false;
  bool _saving = false;

  static const Color _accent = Color(0xFFE58325);

  @override
  void initState() {
    super.initState();
    final r = widget.recipe;

    _nameController = TextEditingController(text: r.name);
    _rating = r.rating;
    _descController = TextEditingController(text: r.description ?? '');
    _servingsController = TextEditingController(
        text: r.servings > 0 ? r.servings.toString() : '');
    _yieldController = TextEditingController(text: r.recipeYield ?? '');
    _totalTimeController = TextEditingController(text: r.totalTime ?? '');
    _prepTimeController = TextEditingController(text: r.prepTime ?? '');
    _cookTimeController = TextEditingController(text: r.performTime ?? '');

    _recipeNoteController = TextEditingController(
      text: r.notes.map((n) => n.text).join('\n'),
    );

    _categories.addAll(r.recipeCategory);
    _tags.addAll(r.tags);
    _tools.addAll(r.tools);
    _instructionSteps.addAll(r.instructions.map((i) => i.text));

    for (final ing in r.ingredients) {
      _ingredients.add(_IngredientEntry(
        quantity: ing.quantity,
        unitId: ing.unitId,
        unitName: ing.unit,
        foodId: ing.foodId,
        foodName: ing.food ?? '',
        note: ing.note,
      ));
    }

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
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);

    final details = {
      'name': name,
      'rating': _rating,
      'description': _descController.text.trim(),
      'servings': _servingsController.text.trim(),
      'recipeYield': _yieldController.text.trim(),
      'totalTime': _totalTimeController.text.trim(),
      'prepTime': _prepTimeController.text.trim(),
      'cookTime': _cookTimeController.text.trim(),
      'recipeIngredient': _ingredients.map((e) => e.toJson()).toList(),
      'recipeCategory': _categories,
      'tags': _tags,
      'tools': _tools,
      'recipeInstructions': _instructionSteps,
      'notes': _recipeNoteController.text.trim(),
    };

    final l10n = AppLocalizations.of(context)!;

    try {
      await _recipeRepo.updateExistingRecipe(widget.recipe.slug, details);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.recipeUpdated), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      debugPrint('Error updating recipe: $e');
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorUpdating(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _addInstructionStep() {
    final text = _instructionInputController.text.trim();
    if (text.isEmpty) return;
    setState(() => _instructionSteps.add(text));
    _instructionInputController.clear();
  }

  void _addIngredient() {
    final foodName = _ingredientFoodController.text.trim();
    if (foodName.isEmpty) return;
    final qty = double.tryParse(_ingredientQtyController.text.trim()) ?? 1;
    String? unitName;
    if (_selectedUnitId != null && _units != null) {
      unitName = _units!.where((u) => u.id == _selectedUnitId).firstOrNull?.name;
    }
    setState(() {
      _ingredients.add(_IngredientEntry(
        quantity: qty,
        unitId: _selectedUnitId,
        unitName: unitName,
        foodId: _selectedFoodId,
        foodName: foodName,
        note: _ingredientNoteController.text.trim(),
      ));
    });
    _ingredientQtyController.text = '1';
    _ingredientNoteController.clear();
    _ingredientFoodController.clear();
    _selectedUnitId = null;
    _selectedFoodId = null;
  }

  void _addChipItem(TextEditingController controller, List<String> items) {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    if (!items.contains(text)) {
      setState(() => items.add(text));
    }
    controller.clear();
  }

  Future<bool> _onWillPop() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.discardChanges),
        content: Text(l10n.discardChangesMessage),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.cancel)),
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
          title: Text(l10n.editRecipe),
          actions: [
            if (_saving)
              const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
              )
            else
              IconButton(icon: const Icon(Icons.check), tooltip: l10n.save, onPressed: _submitAll),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Name ──
              _buildSectionHeader(l10n.name, Icons.restaurant_menu),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.newRecipeNameHint, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 24),

              // ── Rating ──
              _buildSectionHeader(l10n.rating, Icons.star_rounded),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (i) {
                  final s = i + 1;
                  return GestureDetector(
                    onTap: () => setState(() => _rating = _rating == s ? 0 : s),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(s <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: s <= _rating ? Colors.amber : Colors.grey[400], size: 36),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // ── Description ──
              _buildSectionHeader(l10n.descriptionOptional, Icons.notes),
              const SizedBox(height: 8),
              TextField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(labelText: l10n.descriptionOptional, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 24),

              // ── Servings & Yield ──
              _buildSectionHeader(l10n.servings, Icons.people_outline),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: TextField(controller: _servingsController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l10n.servings, border: const OutlineInputBorder()))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _yieldController, decoration: InputDecoration(labelText: l10n.recipeYield, border: const OutlineInputBorder()))),
              ]),
              const SizedBox(height: 24),

              // ── Time ──
              _buildSectionHeader(l10n.totalTime, Icons.access_time),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: TextField(controller: _totalTimeController, decoration: InputDecoration(labelText: l10n.totalTime, border: const OutlineInputBorder()))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _prepTimeController, decoration: InputDecoration(labelText: l10n.prepTimeMinutes, border: const OutlineInputBorder()))),
              ]),
              const SizedBox(height: 12),
              TextField(controller: _cookTimeController, decoration: InputDecoration(labelText: l10n.cookTime, border: const OutlineInputBorder())),
              const SizedBox(height: 24),

              // ── Ingredients ──
              _buildSectionHeader(l10n.ingredientsList, Icons.egg_outlined),
              const SizedBox(height: 8),
              if (_ingredients.isNotEmpty) ...[
                ..._ingredients.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final ing = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 4),
                    child: ListTile(
                      dense: true,
                      title: Text(_formatIngredient(ing), style: const TextStyle(fontSize: 14)),
                      subtitle: ing.note.isNotEmpty ? Text(ing.note, style: TextStyle(fontSize: 12, color: Colors.grey[600])) : null,
                      trailing: IconButton(icon: const Icon(Icons.close, size: 18), tooltip: l10n.removeIngredient, onPressed: () => setState(() => _ingredients.removeAt(idx))),
                    ),
                  );
                }),
                const Divider(height: 16),
              ] else
                Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(l10n.noIngredientsAdded, style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic))),
              const SizedBox(height: 8),
              Row(children: [
                SizedBox(
                  width: 70,
                  child: TextField(
                    controller: _ingredientQtyController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
                    decoration: InputDecoration(labelText: l10n.quantity, border: const OutlineInputBorder(), contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: _buildUnitDropdown(l10n)),
              ]),
              const SizedBox(height: 8),
              _buildFoodAutocomplete(l10n),
              const SizedBox(height: 8),
              TextField(controller: _ingredientNoteController, decoration: InputDecoration(labelText: l10n.notesOptional, border: const OutlineInputBorder(), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12))),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _addIngredient,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.addIngredient),
                  style: OutlinedButton.styleFrom(foregroundColor: _accent, side: BorderSide(color: _accent)),
                ),
              ),
              const SizedBox(height: 24),

              // ── Instructions ──
              _buildSectionHeader(l10n.instructionsPerStep, Icons.format_list_numbered),
              const SizedBox(height: 8),
              if (_instructionSteps.isNotEmpty) ...[
                ...List.generate(_instructionSteps.length, (idx) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 4),
                    child: ListTile(
                      dense: true,
                      leading: CircleAvatar(radius: 14, backgroundColor: _accent, child: Text('${idx + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                      title: Text(_instructionSteps[idx], style: const TextStyle(fontSize: 14)),
                      trailing: IconButton(icon: const Icon(Icons.close, size: 18), tooltip: l10n.removeTag, onPressed: () => setState(() => _instructionSteps.removeAt(idx))),
                    ),
                  );
                }),
                const Divider(height: 16),
              ] else
                Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(l10n.noInstructionsAdded, style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic))),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _instructionInputController,
                    decoration: InputDecoration(hintText: l10n.addInstructionHint, prefixIcon: const Icon(Icons.format_list_numbered, size: 20), border: const OutlineInputBorder(), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
                    onSubmitted: (_) => _addInstructionStep(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(onPressed: _addInstructionStep, icon: Icon(Icons.add_circle, color: _accent), tooltip: l10n.addInstruction),
              ]),
              const SizedBox(height: 24),

              // ── Categories ──
              _buildSectionHeader(l10n.recipeCategories, Icons.category_outlined),
              const SizedBox(height: 8),
              _buildChipInput(controller: _categoryInputController, items: _categories, hint: l10n.categoriesHint, icon: Icons.category_outlined),
              const SizedBox(height: 24),

              // ── Tags ──
              _buildSectionHeader(l10n.tags, Icons.label_outline),
              const SizedBox(height: 8),
              _buildChipInput(controller: _tagInputController, items: _tags, hint: l10n.tagsHint, icon: Icons.label_outline),
              const SizedBox(height: 24),

              // ── Tools ──
              _buildSectionHeader(l10n.tools, Icons.handyman_outlined),
              const SizedBox(height: 8),
              _buildChipInput(controller: _toolInputController, items: _tools, hint: l10n.toolsHint, icon: Icons.handyman_outlined),
              const SizedBox(height: 24),

              // ── Notes ──
              _buildSectionHeader(l10n.recipeNote, Icons.sticky_note_2_outlined),
              const SizedBox(height: 8),
              TextField(controller: _recipeNoteController, maxLines: 3, decoration: InputDecoration(hintText: l10n.recipeNoteHint, border: const OutlineInputBorder(), alignLabelWithHint: true)),
              const SizedBox(height: 32),

              // ── Save Button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _submitAll,
                  style: ElevatedButton.styleFrom(backgroundColor: _accent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check, size: 20),
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

  Widget _buildChipInput({
    required TextEditingController controller,
    required List<String> items,
    required String hint,
    required IconData icon,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (items.isNotEmpty) ...[
          Wrap(
            spacing: 6, runSpacing: 4,
            children: items.asMap().entries.map((entry) {
              return Chip(
                label: Text(entry.value, style: const TextStyle(fontSize: 13)),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => setState(() => items.removeAt(entry.key)),
                backgroundColor: _accent.withAlpha(30),
                side: BorderSide(color: _accent.withAlpha(80)),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
        Row(children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, size: 20), border: const OutlineInputBorder(), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
              onSubmitted: (_) => _addChipItem(controller, items),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(onPressed: () => _addChipItem(controller, items), icon: Icon(Icons.add_circle, color: _accent), tooltip: l10n.addTag),
        ]),
      ],
    );
  }

  // ===================================================================
  // HELPERS
  // ===================================================================

  String _formatIngredient(_IngredientEntry ing) {
    final parts = <String>[];
    if (ing.quantity != 0) {
      parts.add(ing.quantity == ing.quantity.roundToDouble() ? ing.quantity.round().toString() : ing.quantity.toString());
    }
    if (ing.unitName != null && ing.unitName!.isNotEmpty) parts.add(ing.unitName!);
    parts.add(ing.foodName);
    return parts.join(' ');
  }

  Widget _buildUnitDropdown(AppLocalizations l10n) {
    if (_dataLoading || _units == null) {
      return const SizedBox(height: 48, child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))));
    }
    return DropdownButtonFormField<String?>(
      initialValue: _selectedUnitId,
      isExpanded: true,
      decoration: InputDecoration(labelText: l10n.unit, border: const OutlineInputBorder(), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
      items: [
        DropdownMenuItem<String?>(value: null, child: Text('— ${l10n.noUnit}', style: TextStyle(color: Colors.grey[600]))),
        ..._units!.map((u) => DropdownMenuItem(value: u.id, child: Text(u.name))),
      ],
      onChanged: (val) => setState(() => _selectedUnitId = val),
    );
  }

  Widget _buildFoodAutocomplete(AppLocalizations l10n) {
    final foodOptions = _foods ?? <Food>[];
    return RawAutocomplete<Food>(
      textEditingController: _ingredientFoodController,
      focusNode: _ingredientFoodFocusNode,
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
          decoration: InputDecoration(labelText: l10n.food, border: const OutlineInputBorder(), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
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
                  return ListTile(dense: true, title: Text(food.name), onTap: () => onSelected(food));
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _servingsController.dispose();
    _yieldController.dispose();
    _totalTimeController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _ingredientQtyController.dispose();
    _ingredientNoteController.dispose();
    _ingredientFoodController.dispose();
    _ingredientFoodFocusNode.dispose();
    _categoryInputController.dispose();
    _tagInputController.dispose();
    _toolInputController.dispose();
    _instructionInputController.dispose();
    _recipeNoteController.dispose();
    super.dispose();
  }
}
