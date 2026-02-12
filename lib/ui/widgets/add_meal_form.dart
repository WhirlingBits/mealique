import 'package:flutter/material.dart';

// Placeholder models, assuming they exist elsewhere
class Recipe {
  final String id;
  final String name;
  Recipe({required this.id, required this.name});
}

class AddMealForm extends StatefulWidget {
  final Function(String mealType, Recipe recipe) onAddMeal;

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

  String? _selectedMealType;
  Recipe? _selectedRecipe;

  final TextEditingController _recipeController = TextEditingController();
  String _recipeText = '';

  // Dummy data - replace with your actual data
  final List<String> _mealTypes = ['Frühstück', 'Mittagessen', 'Abendessen', 'Snack'];
  final List<Recipe> _availableRecipes = [
    Recipe(id: 'r1', name: 'Spaghetti Carbonara'),
    Recipe(id: 'r2', name: 'Hähnchen Curry'),
    Recipe(id: 'r3', name: 'Linsen-Suppe'),
    Recipe(id: 'r4', name: 'Avocado Toast'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedMealType = _mealTypes.first;
    _focusScopeNode.addListener(_onFocusChange);
    _recipeController.addListener(() {
      if (_recipeText != _recipeController.text) {
        setState(() {
          _recipeText = _recipeController.text;
        });
      }
    });
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
    _focusScopeNode.removeListener(_onFocusChange);
    _focusScopeNode.dispose();
    _recipeController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_selectedMealType == null) return;

    final text = _recipeController.text.trim();
    if (text.isEmpty) return;

    Recipe recipeToSend;
    // Check if the typed text exactly matches a selected recipe.
    if (_selectedRecipe != null && _selectedRecipe!.name == text) {
      recipeToSend = _selectedRecipe!;
    } else {
      // If not, or if nothing was selected, treat it as a new recipe.
      recipeToSend = Recipe(
        id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
        name: text,
      );
    }

    widget.onAddMeal(_selectedMealType!, recipeToSend);
    Navigator.of(context).pop(); // Close the sheet
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const accentColor = Color(0xFFE58325);

    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: accentColor,
        ),
      ),
      child: PopScope(
        canPop: !_isAnythingFocused,
        onPopInvoked: (bool didPop) {
          if (didPop) return;
          _focusScopeNode.unfocus();
        },
        child: Material(
          elevation: 20.0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: FocusScope(
                node: _focusScopeNode,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
                      DropdownButtonFormField<String>(
                        initialValue: _selectedMealType,
                        decoration: const InputDecoration(
                          labelText: 'Mahlzeit',
                          border: OutlineInputBorder(),
                        ),
                        items: _mealTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedMealType = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      // Recipe Autocomplete
                      Autocomplete<Recipe>(
                        displayStringForOption: (Recipe option) => option.name,
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text == '') {
                            return _availableRecipes;
                          }
                          return _availableRecipes.where((Recipe option) {
                            return option.name.toLowerCase().contains(
                                  textEditingValue.text.toLowerCase(),
                                );
                          });
                        },
                        onSelected: (Recipe selection) {
                          setState(() {
                            _selectedRecipe = selection;
                          });
                           // Update text field when a selection is made
                          _recipeController.text = selection.name;
                        },
                        fieldViewBuilder:
                            (context, textEditingController, focusNode, onFieldSubmitted) {
                          // This is a workaround to use our own controller with Autocomplete
                          // We are essentially syncing the internal controller with our own.
                          return TextFormField(
                            controller: _recipeController,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Rezept suchen oder neuen Namen eingeben',
                              border: OutlineInputBorder(),
                            ),
                            onFieldSubmitted: (_) => _handleSubmit(),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Submit Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: Tooltip(
                          message: 'Mahlzeit hinzufügen',
                          child: ElevatedButton(
                            onPressed: _recipeText.trim().isNotEmpty && _selectedMealType != null
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
      ),
    );
  }
}
