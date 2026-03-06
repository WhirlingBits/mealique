import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mealique/data/sync/household_repository.dart';
import 'package:mealique/data/sync/recipe_repository.dart';
import 'package:mealique/l10n/app_localizations.dart';
import 'package:mealique/models/food_model.dart';
import 'package:mealique/models/shopping_list_model.dart';

class Unit {
  final String id;
  final String name;
  Unit({required this.id, required this.name});
}

class Category {
  final String id;
  final String name;
  Category({required this.id, required this.name});
}

class NewShoppingItem {
  final String listId;
  final String foodId;
  final String foodName;
  final int quantity;
  final String? unitId;
  final String? categoryId;
  final String? notes;

  NewShoppingItem({
    required this.listId,
    required this.foodId,
    required this.foodName,
    required this.quantity,
    this.unitId,
    this.categoryId,
    this.notes,
  });
}

class _FormData {
  final List<ShoppingList> lists;
  final List<Food> foods;
  final List<Unit> units;
  final List<Category> categories;

  _FormData({
    required this.lists,
    required this.foods,
    required this.units,
    required this.categories,
  });

  _FormData copyWith({
    List<ShoppingList>? lists,
    List<Food>? foods,
    List<Unit>? units,
    List<Category>? categories,
  }) {
    return _FormData(
      lists: lists ?? this.lists,
      foods: foods ?? this.foods,
      units: units ?? this.units,
      categories: categories ?? this.categories,
    );
  }
}

class AddShoppingListItemForm extends StatefulWidget {
  final Function(NewShoppingItem item) onAddItem;
  final String? shoppingListId;

  const AddShoppingListItemForm({
    super.key,
    required this.onAddItem,
    this.shoppingListId,
  });

  @override
  State<AddShoppingListItemForm> createState() => _AddShoppingListItemFormState();
}

class _AddShoppingListItemFormState extends State<AddShoppingListItemForm> {
  final _householdRepo = HouseholdRepository();
  final _recipeRepo = RecipeRepository();
  late Future<void> _loadFuture;
  _FormData? _formData;

  final _quantityController = TextEditingController(text: '1');
  final _notesController = TextEditingController();
  final _foodController = TextEditingController();
  final _foodFocusNode = FocusNode();

  String? _selectedListId;
  String? _selectedFoodId;
  String? _selectedUnitId;
  String? _selectedCategoryId;

  bool _showAddFoodButton = false;
  bool _showAdvanced = false;

  // Inline toast state
  String? _toastMessage;
  Color? _toastColor;

  @override
  void initState() {
    super.initState();
    _selectedListId = widget.shoppingListId;
    _loadFuture = _loadFormData();
    _foodController.addListener(_onFoodTextChanged);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    _foodController.removeListener(_onFoodTextChanged);
    _foodController.dispose();
    _foodFocusNode.dispose();
    super.dispose();
  }

  void _onFoodTextChanged() {
    if (!mounted || _formData == null) return;
    final text = _foodController.text;
    if (text.isEmpty) {
      if (_showAddFoodButton) setState(() => _showAddFoodButton = false);
      if (_selectedFoodId != null) setState(() => _selectedFoodId = null);
      return;
    }
    final query = text.toLowerCase();
    final hasExactMatch = _formData!.foods.any((food) => food.name.toLowerCase() == query);
    final shouldShow = !hasExactMatch;

    // Reset selected food ID if text no longer matches the previously selected food
    if (_selectedFoodId != null) {
      final selectedFood = _formData!.foods.where((f) => f.id == _selectedFoodId);
      if (selectedFood.isEmpty || selectedFood.first.name.toLowerCase() != query) {
        setState(() => _selectedFoodId = null);
      }
    }

    if (_showAddFoodButton != shouldShow) {
      setState(() => _showAddFoodButton = shouldShow);
    }
  }

  void _showToast(String message, {Color? backgroundColor}) {
    if (!mounted) return;
    setState(() {
      _toastMessage = message;
      _toastColor = backgroundColor ?? Colors.grey[800];
    });
    Future.delayed(
      Duration(seconds: backgroundColor == Colors.red ? 4 : 2),
      () {
        if (mounted) setState(() => _toastMessage = null);
      },
    );
  }

  Future<void> _loadFormData() async {
    try {
      final results = await Future.wait([
        _householdRepo.getShoppingLists(),
        _recipeRepo.getFoods(),
        _recipeRepo.getUnits(),
      ]);
      final lists = (results[0] as List<ShoppingList>?) ?? [];
      final foods = results[1] as List<Food>;
      final apiUnits = results[2] as List;
      final units = apiUnits.map((u) => Unit(id: u.id, name: u.name)).toList();
      final categories = <Category>[];

      if (mounted) {
        setState(() {
          _formData = _FormData(lists: lists, foods: foods, units: units, categories: categories);
        });
      }
    } catch (e) {
      throw Exception('Failed to load form data: $e');
    }
  }

  Future<void> _handleCreateAndSelectFood(String foodName) async {
    if (_formData == null) return;
    final l10n = AppLocalizations.of(context)!;
    try {
      final foodToCreate = Food(id: '', name: foodName, pluralName: foodName, description: '', extras: {}, aliases: [], householdsWithIngredientFood: [], createdAt: '', updatedAt: '', label: null, labelId: null);
      final newFood = await _recipeRepo.createFood(foodToCreate);
      
      final newFoodList = List<Food>.from(_formData!.foods)..add(newFood);

      setState(() {
        _formData = _formData!.copyWith(foods: newFoodList);
        _selectedFoodId = newFood.id;
        _foodController.text = newFood.name;
      });

      _showToast(l10n.foodCreatedSuccess(foodName), backgroundColor: Colors.green);
    } catch (e) {
      _showToast(l10n.errorCreatingFood(e.toString()), backgroundColor: Colors.red);
    }
  }

  Future<void> _handleDeleteFood(Food food) async {
    if (_formData == null) return;
    final l10n = AppLocalizations.of(context)!;
    debugPrint('Delete food requested: ${food.id} - ${food.name}');

    _foodFocusNode.unfocus();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteFood),
        content: Text(l10n.confirmDeleteFood(food.name)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.delete, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );

    debugPrint('Delete confirmed: $confirmed');

    if (confirmed == true) {
      try {
        await _recipeRepo.deleteFood(food.id);
        debugPrint('Food deleted successfully from API: ${food.id}');
        final newFoodList = List<Food>.from(_formData!.foods)..removeWhere((f) => f.id == food.id);
        
        setState(() {
          _formData = _formData!.copyWith(foods: newFoodList);
          if (_selectedFoodId == food.id) {
            _selectedFoodId = null;
            _foodController.clear();
          }
        });
        debugPrint('Food list updated, remaining: ${newFoodList.length}');
        _showToast(l10n.itemDeletedSuccess(food.name), backgroundColor: Colors.green);
      } on DioException catch (e) {
        debugPrint('Error deleting food: $e');
        if (mounted) {
          String message;
          final responseData = e.response?.data;
          if (e.response?.statusCode == 400 &&
              responseData is Map &&
              responseData['exception'] != null &&
              responseData['exception'].toString().contains('ForeignKeyViolation')) {
            message = l10n.foodStillInUse(food.name);
          } else {
            message = l10n.deleteFailed('${responseData?['message'] ?? e.message}');
          }
          _showToast(message, backgroundColor: Colors.red);
        }
      } catch (e) {
        debugPrint('Error deleting food: $e');
        _showToast(l10n.deleteFailed(e.toString()), backgroundColor: Colors.red);
      }
    }
  }

  Future<void> _handleSubmit() async {
    final l10n = AppLocalizations.of(context)!;
    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      _showToast(l10n.pleaseEnterValidQuantity);
      return;
    }
    if (_selectedListId == null) {
      _showToast(l10n.pleaseSelectShoppingList);
      return;
    }

    if (_selectedFoodId == null && _foodController.text.isNotEmpty && _formData != null) {
      final text = _foodController.text.trim();
      final existingFood = _formData!.foods.cast<Food?>().firstWhere(
        (f) => f!.name.toLowerCase() == text.toLowerCase(),
        orElse: () => null,
      );
      if (existingFood != null) {
        _selectedFoodId = existingFood.id;
      } else {
        await _handleCreateAndSelectFood(text);
      }
    }

    if (_selectedFoodId == null) {
      _showToast(l10n.pleaseSelectOrEnterFood);
      return;
    }


    final newItem = NewShoppingItem(
        listId: _selectedListId!,
        foodId: _selectedFoodId!,
        foodName: _foodController.text,
        quantity: quantity,
        unitId: _selectedUnitId,
        categoryId: _selectedCategoryId,
        notes: _notesController.text.trim());
    debugPrint('Submitting shopping item: listId=${newItem.listId}, foodId=${newItem.foodId}, foodName=${newItem.foodName}, qty=${newItem.quantity}');
    widget.onAddItem(newItem);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Theme(
      data: theme.copyWith(colorScheme: theme.colorScheme.copyWith(primary: const Color(0xFFE58325))),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Material(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: FutureBuilder<void>(
                future: _loadFuture,
                builder: (context, snapshot) {
                  if (_formData == null && snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
                  }
                  if (snapshot.hasError) {
                    return SizedBox(height: 120, child: Center(child: Text(snapshot.error.toString())));
                  }
                  if (_formData == null) {
                    return SizedBox(height: 120, child: Center(child: Text(l10n.couldNotLoadFormData)));
                  }

                  final formData = _formData!;
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Container(
                            width: 40, height: 4,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)),
                          ),
                        ),
                        Text(l10n.addNewItem, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _buildToastBanner(),
                        if (widget.shoppingListId == null) ...[
                          DropdownButtonFormField<String>(
                            value: _selectedListId,
                            decoration: InputDecoration(labelText: l10n.shoppingList, border: const OutlineInputBorder(), isDense: true),
                            items: formData.lists.map((list) => DropdownMenuItem(value: list.id, child: Text(list.name))).toList(),
                            onChanged: (value) => setState(() => _selectedListId = value),
                            validator: (value) => value == null ? l10n.pleaseSelectList : null,
                          ),
                          const SizedBox(height: 12),
                        ],
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: _buildFoodAutocomplete(formData.foods)),
                            const SizedBox(width: 12),
                            Expanded(flex: 2, child: _buildQuantityField()),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildAdvancedSectionToggle(),
                        _buildAdvancedSection(formData),
                        const SizedBox(height: 12),
                        _buildSubmitButton(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToastBanner() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => SizeTransition(
        sizeFactor: animation,
        axisAlignment: -1,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: _toastMessage != null
          ? Container(
              key: ValueKey(_toastMessage),
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _toastColor ?? Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _toastColor == Colors.green ? Icons.check_circle
                        : _toastColor == Colors.red ? Icons.error
                        : Icons.info,
                    color: Colors.white, size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_toastMessage!, style: const TextStyle(color: Colors.white, fontSize: 13))),
                  GestureDetector(
                    onTap: () => setState(() => _toastMessage = null),
                    child: const Icon(Icons.close, color: Colors.white70, size: 16),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildAdvancedSectionToggle() {
    final l10n = AppLocalizations.of(context)!;
    return TextButton.icon(
      onPressed: () => setState(() => _showAdvanced = !_showAdvanced),
      icon: Icon(_showAdvanced ? Icons.expand_less : Icons.expand_more),
      label: Text(l10n.advanced),
    );
  }

  Widget _buildAdvancedSection(_FormData formData) {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Visibility(
        visible: _showAdvanced,
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildAutocomplete<Unit>(label: l10n.unit, options: formData.units, onSelected: (unit) => setState(() => _selectedUnitId = unit.id)),
            const SizedBox(height: 12),
            _buildAutocomplete<Category>(label: l10n.category, options: formData.categories, onSelected: (cat) => setState(() => _selectedCategoryId = cat.id)),
            const SizedBox(height: 12),
            _buildNotesField(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFoodAutocomplete(List<Food> foodOptions) {
    final l10n = AppLocalizations.of(context)!;
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
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: l10n.food,
            border: const OutlineInputBorder(),
            suffixIcon: _showAddFoodButton
              ? IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _handleCreateAndSelectFood(controller.text),
                  tooltip: l10n.addNewFood,
                )
              : null,
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: SizedBox(
               width: MediaQuery.of(context).size.width * 0.55,
               child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 250),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final food = options.elementAt(index);
                    return InkWell(
                      onTap: () => onSelected(food),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(food.name),
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  // First unfocus to close the autocomplete overlay
                                  _foodFocusNode.unfocus();
                                  // Then show delete dialog after overlay is closed
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    _handleDeleteFood(food);
                                  });
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuantityField() {
    final l10n = AppLocalizations.of(context)!;
    return TextField(
      controller: _quantityController,
      decoration: InputDecoration(labelText: l10n.quantity, border: const OutlineInputBorder()),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  Widget _buildNotesField() {
    final l10n = AppLocalizations.of(context)!;
    return TextField(
      controller: _notesController,
      decoration: InputDecoration(labelText: l10n.notesOptional, border: const OutlineInputBorder()),
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildSubmitButton() {
    final l10n = AppLocalizations.of(context)!;
    return Align(
      alignment: Alignment.centerRight,
      child: Tooltip(
        message: l10n.addItem,
        child: ElevatedButton(
          onPressed: _handleSubmit,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
            backgroundColor: const Color(0xFFE58325),
            foregroundColor: Colors.white,
          ),
          child: const Icon(Icons.add_shopping_cart),
        ),
      ),
    );
  }

  Widget _buildAutocomplete<T extends Object>({
    required String label,
    required List<T> options,
    required ValueChanged<T> onSelected,
  }) {
    return Autocomplete<T>(
      displayStringForOption: (option) => (option as dynamic).name,
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text == '') return options;
        return options.where((T option) {
          final name = (option as dynamic).name as String;
          return name.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: onSelected,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        );
      },
    );
  }
}
