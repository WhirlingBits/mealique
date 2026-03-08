import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/sync/recipe_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/mealplan_model.dart';
import '../../models/recipes_model.dart';

class AddMealForm extends StatefulWidget {
  final Function(PlanEntryType entryType, Recipe recipe) onAddMeal;

  const AddMealForm({
    super.key,
    required this.onAddMeal,
  });

  @override
  State<AddMealForm> createState() => _AddMealFormState();
}

class _AddMealFormState extends State<AddMealForm> {
  final _focusScopeNode = FocusScopeNode();
  bool _isAnythingFocused = false;

  PlanEntryType _selectedEntryType = PlanEntryType.breakfast;
  Recipe? _selectedRecipe;

  final TextEditingController _recipeController = TextEditingController();
  String _recipeText = '';

  final RecipeRepository _recipeRepository = RecipeRepository();
  List<Recipe> _recipeSuggestions = [];
  bool _isLoadingSuggestions = false;
  Timer? _debounce;

  String _localizedEntryType(AppLocalizations l10n, PlanEntryType type) {
    switch (type) {
      case PlanEntryType.breakfast:
        return l10n.breakfast;
      case PlanEntryType.lunch:
        return l10n.lunch;
      case PlanEntryType.dinner:
        return l10n.dinner;
      case PlanEntryType.snack:
        return l10n.snack;
      case PlanEntryType.side:
        return l10n.side;
      case PlanEntryType.drink:
        return l10n.drink;
      case PlanEntryType.dessert:
        return l10n.dessert;
    }
  }

  @override
  void initState() {
    super.initState();
    _focusScopeNode.addListener(_onFocusChange);
    _recipeController.addListener(_onRecipeTextChanged);
    // Load initial recipes
    _loadRecipes('');
  }

  void _onRecipeTextChanged() {
    final text = _recipeController.text;
    if (_recipeText != text) {
      setState(() {
        _recipeText = text;
        // Reset selection if user edits text after selecting
        if (_selectedRecipe != null && _selectedRecipe!.name != text) {
          _selectedRecipe = null;
        }
      });
      _debouncedSearch(text);
    }
  }

  void _debouncedSearch(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _loadRecipes(query);
    });
  }

  Future<void> _loadRecipes(String query) async {
    setState(() => _isLoadingSuggestions = true);
    try {
      final recipes = await _recipeRepository.getRecipes(
        searchQuery: query.isEmpty ? null : query,
        perPage: 20,
      );
      if (mounted) {
        setState(() {
          _recipeSuggestions = recipes;
          _isLoadingSuggestions = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingSuggestions = false);
      }
    }
  }

  void _onFocusChange() {
    if (_isAnythingFocused != _focusScopeNode.hasFocus) {
      setState(() {
        _isAnythingFocused = _focusScopeNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusScopeNode.removeListener(_onFocusChange);
    _focusScopeNode.dispose();
    _recipeController.removeListener(_onRecipeTextChanged);
    _recipeController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _recipeController.text.trim();
    if (text.isEmpty) return;

    Recipe recipeToSend;
    if (_selectedRecipe != null && _selectedRecipe!.name == text) {
      recipeToSend = _selectedRecipe!;
    } else {
      // Treat as custom/new recipe name
      recipeToSend = Recipe(
        id: '',
        name: text,
        slug: '',
        servings: 0,
        ingredients: [],
        instructions: [],
      );
    }

    widget.onAddMeal(_selectedEntryType, recipeToSend);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    const accentColor = Color(0xFFE58325);

    // Filter suggestions based on current text
    final filteredSuggestions = _recipeText.isEmpty
        ? _recipeSuggestions
        : _recipeSuggestions
            .where((r) => r.name.toLowerCase().contains(_recipeText.toLowerCase()))
            .toList();

    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: accentColor,
        ),
      ),
      child: PopScope(
        canPop: !_isAnythingFocused,
        onPopInvokedWithResult: (bool didPop, _) {
          if (didPop) return;
          _focusScopeNode.unfocus();
        },
        child: Material(
          elevation: 20.0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SafeArea(
            child: FocusScope(
              node: _focusScopeNode,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Meal Type Dropdown
                    DropdownButtonFormField<PlanEntryType>(
                      initialValue: _selectedEntryType,
                      decoration: InputDecoration(
                        labelText: l10n.meal,
                        border: const OutlineInputBorder(),
                      ),
                      items: PlanEntryType.values.map((PlanEntryType type) {
                        return DropdownMenuItem<PlanEntryType>(
                          value: type,
                          child: Text(_localizedEntryType(l10n, type)),
                        );
                      }).toList(),
                      onChanged: (PlanEntryType? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedEntryType = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    // Recipe search field
                    TextFormField(
                      controller: _recipeController,
                      decoration: InputDecoration(
                        labelText: l10n.searchOrEnterRecipeName,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _isLoadingSuggestions
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : _recipeText.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _recipeController.clear();
                                      setState(() {
                                        _selectedRecipe = null;
                                      });
                                      _loadRecipes('');
                                    },
                                  )
                                : null,
                      ),
                      onFieldSubmitted: (_) => _handleSubmit(),
                    ),
                    // Recipe suggestions list
                    if (filteredSuggestions.isNotEmpty)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: Card(
                          margin: const EdgeInsets.only(top: 4),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: filteredSuggestions.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final recipe = filteredSuggestions[index];
                              final isSelected = _selectedRecipe?.id == recipe.id;
                              return ListTile(
                                dense: true,
                                leading: Icon(
                                  Icons.restaurant,
                                  size: 20,
                                  color: isSelected ? accentColor : Colors.grey,
                                ),
                                title: Text(
                                  recipe.name,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? accentColor : null,
                                  ),
                                ),
                                subtitle: recipe.totalTime != null && recipe.totalTime!.isNotEmpty
                                    ? Text(
                                        '⏱ ${recipe.totalTime}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      )
                                    : null,
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle, color: accentColor)
                                    : null,
                                onTap: () {
                                  setState(() {
                                    _selectedRecipe = recipe;
                                    _recipeController.text = recipe.name;
                                    _recipeText = recipe.name;
                                  });
                                  FocusScope.of(context).unfocus();
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Submit Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: Tooltip(
                        message: l10n.addMealToPlanner,
                        child: ElevatedButton(
                          onPressed: _recipeText.trim().isNotEmpty
                              ? _handleSubmit
                              : null,
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(16),
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Icon(Icons.add),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
