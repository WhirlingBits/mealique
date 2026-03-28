import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/sync/recipe_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/food_model.dart';
import '../../models/shopping_item_model.dart';

/// A single ingredient entry added by the user.
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

class AddRecipeForm extends StatefulWidget {
  final Function(String) onAddRecipe;

  const AddRecipeForm({super.key, required this.onAddRecipe});

  @override
  State<AddRecipeForm> createState() => _AddRecipeFormState();
}

class _AddRecipeFormState extends State<AddRecipeForm> {
  // -- Controllers for step 1 (name) --
  final _nameController = TextEditingController();
  int _rating = 0; // 0-5 stars

  // -- Controllers for step 2 (details) --
  final _descController = TextEditingController();
  final _servingsController = TextEditingController();
  final _yieldController = TextEditingController();
  final _totalTimeController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _cookTimeController = TextEditingController();

  // -- Step 3 (ingredients) --
  final _ingredientQtyController = TextEditingController(text: '1');
  final _ingredientNoteController = TextEditingController();
  final _ingredientFoodController = TextEditingController();
  final _ingredientFoodFocusNode = FocusNode();

  String? _selectedUnitId;
  String? _selectedFoodId;
  final List<_IngredientEntry> _ingredients = [];

  // -- Step 4 (categories, tags, tools, instructions, notes) --
  final _categoryInputController = TextEditingController();
  final _tagInputController = TextEditingController();
  final _toolInputController = TextEditingController();
  final _instructionInputController = TextEditingController();
  final _recipeNoteController = TextEditingController();
  final List<String> _categories = [];
  final List<String> _tags = [];
  final List<String> _tools = [];
  final List<String> _instructionSteps = [];

  // -- Data loaded from API --
  final _recipeRepo = RecipeRepository();
  List<Food>? _foods;
  List<ShoppingItemUnit>? _units;
  bool _dataLoading = false;

  // -- Current step: 0 = name, 1 = details, 2 = ingredients, 3 = extras --
  int _currentStep = 0;
  final Color _accent = const Color(0xFFE58325);

  @override
  void initState() {
    super.initState();
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

  // ----- Navigation -----

  void _goToStep(int step) {
    if (step == 1 && _nameController.text.trim().isEmpty) return;
    setState(() => _currentStep = step);
    FocusScope.of(context).unfocus();
  }

  // ----- Submit -----

  void _submitAll() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
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
    widget.onAddRecipe(jsonEncode(details));
    _clearAll();
  }

  void _clearAll() {
    _nameController.clear();
    _rating = 0;
    _descController.clear();
    _servingsController.clear();
    _yieldController.clear();
    _totalTimeController.clear();
    _prepTimeController.clear();
    _cookTimeController.clear();
    _ingredientQtyController.text = '1';
    _ingredientNoteController.clear();
    _ingredientFoodController.clear();
    _selectedUnitId = null;
    _selectedFoodId = null;
    _ingredients.clear();
    _categoryInputController.clear();
    _tagInputController.clear();
    _toolInputController.clear();
    _instructionInputController.clear();
    _recipeNoteController.clear();
    _categories.clear();
    _tags.clear();
    _tools.clear();
    _instructionSteps.clear();
    setState(() => _currentStep = 0);
  }

  // ----- Add instruction step -----

  void _addInstructionStep() {
    final text = _instructionInputController.text.trim();
    if (text.isEmpty) return;
    setState(() => _instructionSteps.add(text));
    _instructionInputController.clear();
  }

  // ----- Add ingredient to list -----

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

    // Reset input fields
    _ingredientQtyController.text = '1';
    _ingredientNoteController.clear();
    _ingredientFoodController.clear();
    _selectedUnitId = null;
    _selectedFoodId = null;
  }

  // ===================================================================
  // BUILD
  // ===================================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(primary: _accent),
      ),
      child: Material(
        elevation: 20.0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: _buildCurrentStep(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildNameStep();
      case 1:
        return _buildDetailStep();
      case 2:
        return _buildIngredientsStep();
      case 3:
        return _buildExtrasStep();
      default:
        return _buildNameStep();
    }
  }

  // ===================================================================
  // STEP INDICATOR
  // ===================================================================

  Widget _buildStepIndicator(int step) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.stepOf(step + 1, 4),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              ...List.generate(4, (i) {
                return Container(
                  width: i == step ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i == step
                        ? _accent
                        : (i < step ? _accent.withAlpha(160) : Colors.grey[300]),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  // ===================================================================
  // STEP 1: NAME
  // ===================================================================

  Widget _buildNameStep() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      key: const ValueKey('step0'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStepIndicator(0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.newRecipeNameHint,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => _goToStep(1),
              ),
            ),
            const SizedBox(width: 16),
            Tooltip(
              message: l10n.continueToDetails,
              child: ElevatedButton(
                onPressed: () => _goToStep(1),
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                ),
                child: const Icon(Icons.arrow_forward),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===================================================================
  // STEP 2: DETAILS
  // ===================================================================

  Widget _buildDetailStep() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      key: const ValueKey('step1'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStepIndicator(1),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.name,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.descriptionOptional,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _servingsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.servings,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _yieldController,
                  decoration: InputDecoration(
                    labelText: l10n.recipeYield,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _totalTimeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.totalTime,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _prepTimeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.prepTimeMinutes,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cookTimeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.cookTime,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(l10n.rating, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
              const SizedBox(width: 8),
              ...List.generate(5, (i) {
                final starIndex = i + 1;
                return GestureDetector(
                  onTap: () => setState(() {
                    _rating = _rating == starIndex ? 0 : starIndex;
                  }),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(
                      starIndex <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: starIndex <= _rating ? Colors.amber : Colors.grey[400],
                      size: 32,
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _goToStep(0),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.grey[400]!),
                  ),
                  child: Text(l10n.back),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _goToStep(2),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: Text(l10n.ingredientsList),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================================================================
  // STEP 3: INGREDIENTS
  // ===================================================================

  Widget _buildIngredientsStep() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      key: const ValueKey('step2'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator(2),

          // -- Already added ingredients list --
          if (_ingredients.isNotEmpty) ...[
            Text(
              l10n.ingredientsList,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ..._ingredients.asMap().entries.map((entry) {
              final idx = entry.key;
              final ing = entry.value;
              final display = _formatIngredient(ing);
              return Card(
                margin: const EdgeInsets.only(bottom: 4),
                child: ListTile(
                  dense: true,
                  title: Text(display, style: const TextStyle(fontSize: 14)),
                  subtitle: ing.note.isNotEmpty
                      ? Text(ing.note,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]))
                      : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    tooltip: l10n.removeIngredient,
                    onPressed: () => setState(() => _ingredients.removeAt(idx)),
                  ),
                ),
              );
            }),
            const Divider(height: 24),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  l10n.noIngredientsAdded,
                  style: TextStyle(
                      color: Colors.grey[500], fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ],

          // -- Input row: Quantity + Unit --
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 70,
                child: TextField(
                  controller: _ingredientQtyController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))
                  ],
                  decoration: InputDecoration(
                    labelText: l10n.quantity,
                    border: const OutlineInputBorder(),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildUnitDropdown(l10n),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // -- Food autocomplete --
          _buildFoodAutocomplete(l10n),

          const SizedBox(height: 8),

          // -- Note --
          TextField(
            controller: _ingredientNoteController,
            decoration: InputDecoration(
              labelText: l10n.notesOptional,
              border: const OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),

          const SizedBox(height: 8),

          // -- Add ingredient button --
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addIngredient,
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.addIngredient),
              style: OutlinedButton.styleFrom(
                foregroundColor: _accent,
                side: BorderSide(color: _accent),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // -- Back / Next buttons --
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _goToStep(1),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.grey[400]!),
                  ),
                  child: Text(l10n.back),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _goToStep(3),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: Text(l10n.continueToDetails),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================================================================
  // STEP 4: CATEGORIES, TAGS, TOOLS, INSTRUCTIONS, NOTES
  // ===================================================================

  Widget _buildExtrasStep() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      key: const ValueKey('step3'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator(3),

          // -- Categories --
          _buildChipSection(
            label: l10n.recipeCategories,
            hint: l10n.categoriesHint,
            controller: _categoryInputController,
            items: _categories,
            icon: Icons.category_outlined,
          ),
          const SizedBox(height: 16),

          // -- Tags --
          _buildChipSection(
            label: l10n.tags,
            hint: l10n.tagsHint,
            controller: _tagInputController,
            items: _tags,
            icon: Icons.label_outline,
          ),
          const SizedBox(height: 16),

          // -- Tools --
          _buildChipSection(
            label: l10n.tools,
            hint: l10n.toolsHint,
            controller: _toolInputController,
            items: _tools,
            icon: Icons.handyman_outlined,
          ),
          const SizedBox(height: 16),

          // -- Instructions (step-by-step like ingredients) --
          Text(
            l10n.instructionsPerStep,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          if (_instructionSteps.isNotEmpty) ...[
            ...List.generate(_instructionSteps.length, (idx) {
              return Card(
                margin: const EdgeInsets.only(bottom: 4),
                child: ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: _accent,
                    child: Text(
                      '${idx + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(_instructionSteps[idx], style: const TextStyle(fontSize: 14)),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    tooltip: l10n.removeTag,
                    onPressed: () => setState(() => _instructionSteps.removeAt(idx)),
                  ),
                ),
              );
            }),
            const Divider(height: 16),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  l10n.noInstructionsAdded,
                  style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ],
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _instructionInputController,
                  decoration: InputDecoration(
                    hintText: l10n.addInstructionHint,
                    prefixIcon: const Icon(Icons.format_list_numbered, size: 20),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onSubmitted: (_) => _addInstructionStep(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _addInstructionStep,
                icon: Icon(Icons.add_circle, color: _accent),
                tooltip: l10n.addInstruction,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // -- Recipe Note --
          TextField(
            controller: _recipeNoteController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.recipeNote,
              hintText: l10n.recipeNoteHint,
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),

          // -- Back / Done buttons --
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _goToStep(2),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.grey[400]!),
                  ),
                  child: Text(l10n.back),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _submitAll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
                icon: const Icon(Icons.check, size: 18),
                label: Text(l10n.done),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================================================================
  // CHIP SECTION BUILDER (for categories, tags, tools)
  // ===================================================================

  Widget _buildChipSection({
    required String label,
    required String hint,
    required TextEditingController controller,
    required List<String> items,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        if (items.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 4,
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
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  prefixIcon: Icon(icon, size: 20),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                onSubmitted: (_) => _addChipItem(controller, items),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _addChipItem(controller, items),
              icon: Icon(Icons.add_circle, color: _accent),
              tooltip: AppLocalizations.of(context)!.addTag,
            ),
          ],
        ),
      ],
    );
  }

  void _addChipItem(TextEditingController controller, List<String> items) {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    if (!items.contains(text)) {
      setState(() => items.add(text));
    }
    controller.clear();
  }

  // ===================================================================
  // HELPERS
  // ===================================================================

  String _formatIngredient(_IngredientEntry ing) {
    final parts = <String>[];
    if (ing.quantity != 0) {
      parts.add(ing.quantity == ing.quantity.roundToDouble()
          ? ing.quantity.round().toString()
          : ing.quantity.toString());
    }
    if (ing.unitName != null && ing.unitName!.isNotEmpty) {
      parts.add(ing.unitName!);
    }
    parts.add(ing.foodName);
    return parts.join(' ');
  }

  Widget _buildUnitDropdown(AppLocalizations l10n) {
    if (_dataLoading || _units == null) {
      return const SizedBox(
        height: 48,
        child: Center(
            child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }
    return DropdownButtonFormField<String?>(
      initialValue: _selectedUnitId,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.unit,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: [
        DropdownMenuItem<String?>(
            value: null,
            child: Text('— ${l10n.noUnit}',
                style: TextStyle(color: Colors.grey[600]))),
        ..._units!
            .map((u) => DropdownMenuItem(value: u.id, child: Text(u.name))),
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
        return foodOptions
            .where((food) => food.name.toLowerCase().contains(query));
      },
      onSelected: (food) {
        setState(() => _selectedFoodId = food.id);
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: l10n.food,
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          onChanged: (_) {
            if (_selectedFoodId != null) {
              setState(() => _selectedFoodId = null);
            }
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
