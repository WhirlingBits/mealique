import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/sync/recipe_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/mealplan_model.dart';
import '../../models/recipes_model.dart';

class AddMealForm extends StatefulWidget {
  final Function(PlanEntryType entryType, Recipe recipe) onAddMeal;
  final Set<PlanEntryType> occupiedEntryTypes;
  final PlanEntryType? editingEntryType;
  final DateTime selectedDate;

  const AddMealForm({
    super.key,
    required this.onAddMeal,
    required this.selectedDate,
    this.occupiedEntryTypes = const {},
    this.editingEntryType,
  });

  @override
  State<AddMealForm> createState() => _AddMealFormState();
}

class _AddMealFormState extends State<AddMealForm> {
  final _focusScopeNode = FocusScopeNode();
  bool _isAnythingFocused = false;
  bool _isLoadingRandom = false;

  PlanEntryType _selectedEntryType = PlanEntryType.breakfast;
  Recipe? _selectedRecipe;

  final TextEditingController _recipeController = TextEditingController();
  final FocusNode _recipeFocusNode = FocusNode();
  String _recipeText = '';

  final RecipeRepository _recipeRepository = RecipeRepository();
  List<Recipe> _cachedRecipes = [];
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

    // Set initial entry type: editing type, or first free type
    if (widget.editingEntryType != null) {
      _selectedEntryType = widget.editingEntryType!;
    } else {
      final freeType = PlanEntryType.values.cast<PlanEntryType?>().firstWhere(
        (t) => !widget.occupiedEntryTypes.contains(t),
        orElse: () => null,
      );
      _selectedEntryType = freeType ?? PlanEntryType.breakfast;
    }

    _loadRecipes('');
  }

  void _debouncedSearch(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _loadRecipes(query);
    });
  }

  Future<void> _loadRecipes(String query) async {
    try {
      final recipes = await _recipeRepository.getRecipes(
        searchQuery: query.isEmpty ? null : query,
        perPage: 20,
      );
      if (mounted) {
        setState(() {
          _cachedRecipes = recipes;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadRandomRecipe() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoadingRandom = true;
    });

    try {
      // Format date as YYYY-MM-DD
      final dateStr = widget.selectedDate.toIso8601String().split('T').first;
      // Convert entryType to API format (lowercase)
      final entryTypeStr = _selectedEntryType.name;

      final recipe = await _recipeRepository.getRandomRecipe(
        date: dateStr,
        entryType: entryTypeStr,
      );
      if (mounted) {
        if (recipe != null) {
          setState(() {
            _selectedRecipe = recipe;
            _recipeText = recipe.name;
            _recipeController.text = recipe.name;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.noRandomRecipeFound),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.noRandomRecipeFound),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRandom = false;
        });
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
    _recipeController.dispose();
    _recipeFocusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _recipeController.text.trim();
    if (text.isEmpty) return;

    Recipe recipeToSend;
    if (_selectedRecipe != null && _selectedRecipe!.name == text) {
      recipeToSend = _selectedRecipe!;
    } else {
      // Try to match against cached recipes
      final match = _cachedRecipes.where(
        (r) => r.name.toLowerCase() == text.toLowerCase(),
      );
      if (match.isNotEmpty) {
        recipeToSend = match.first;
      } else {
        recipeToSend = Recipe(
          id: '',
          name: text,
          slug: '',
          servings: 0,
          ingredients: [],
          instructions: [],
        );
      }
    }

    widget.onAddMeal(_selectedEntryType, recipeToSend);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    const accentColor = Color(0xFFE58325);

    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(primary: accentColor),
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
              child: SingleChildScrollView(
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
                        final isOccupied = widget.occupiedEntryTypes.contains(type) &&
                            type != widget.editingEntryType;
                        return DropdownMenuItem<PlanEntryType>(
                          value: type,
                          enabled: !isOccupied,
                          child: Text(
                            isOccupied
                                ? '${_localizedEntryType(l10n, type)} ✓'
                                : _localizedEntryType(l10n, type),
                            style: TextStyle(
                              color: isOccupied ? Colors.grey : null,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (PlanEntryType? newValue) {
                        if (newValue != null) {
                          setState(() => _selectedEntryType = newValue);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    // Recipe search with RawAutocomplete (like food autocomplete)
                    _buildRecipeAutocomplete(l10n),
                    const SizedBox(height: 12),
                    // Random recipe button
                    OutlinedButton.icon(
                      onPressed: _isLoadingRandom ? null : _loadRandomRecipe,
                      icon: _isLoadingRandom
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.casino_outlined),
                      label: Text(l10n.randomRecipe),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: accentColor,
                        side: BorderSide(color: accentColor),
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

  Widget _buildRecipeAutocomplete(AppLocalizations l10n) {
    return RawAutocomplete<Recipe>(
      textEditingController: _recipeController,
      focusNode: _recipeFocusNode,
      displayStringForOption: (recipe) => recipe.name,
      optionsBuilder: (TextEditingValue textEditingValue) {
        final query = textEditingValue.text.trim().toLowerCase();
        // Trigger background search for new results
        _debouncedSearch(textEditingValue.text.trim());
        if (query.isEmpty) return const Iterable.empty();
        return _cachedRecipes.where(
          (r) => r.name.toLowerCase().contains(query),
        );
      },
      onSelected: (Recipe recipe) {
        setState(() {
          _selectedRecipe = recipe;
          _recipeText = recipe.name;
        });
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: l10n.searchOrEnterRecipeName,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                      setState(() {
                        _selectedRecipe = null;
                        _recipeText = '';
                      });
                    },
                  )
                : null,
          ),
          onFieldSubmitted: (_) => _handleSubmit(),
          onChanged: (value) {
            setState(() {
              _recipeText = value;
              if (_selectedRecipe != null &&
                  _selectedRecipe!.name != value) {
                _selectedRecipe = null;
              }
            });
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 32,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 250),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final recipe = options.elementAt(index);
                    return InkWell(
                      onTap: () => onSelected(recipe),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 10.0),
                        child: Row(
                          children: [
                            const Icon(Icons.restaurant,
                                size: 20, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(recipe.name),
                                  if (recipe.totalTime != null &&
                                      recipe.totalTime!.isNotEmpty)
                                    Text(
                                      '⏱ ${recipe.totalTime}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
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
}
