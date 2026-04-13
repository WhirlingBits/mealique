import 'package:dio/dio.dart';
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
  final _categoryFocusNode = FocusNode();
  final _tagInputController = TextEditingController();
  final _tagFocusNode = FocusNode();
  final _toolInputController = TextEditingController();
  final _toolFocusNode = FocusNode();
  final _instructionInputController = TextEditingController();
  late final TextEditingController _recipeNoteController;
  final List<RecipeCategory> _categories = [];
  final List<RecipeTag> _tags = [];
  final List<RecipeTool> _tools = [];
  final List<String> _instructionSteps = [];

  // -- API data --
  final _recipeRepo = RecipeRepository();
  List<Food>? _foods;
  List<ShoppingItemUnit>? _units;
  List<RecipeCategory>? _availableCategories;
  List<RecipeTag>? _availableTags;
  List<RecipeTool>? _availableTools;
  bool _dataLoading = false;
  bool _saving = false;
  bool _showAddCategoryButton = false;
  bool _showAddTagButton = false;
  bool _showAddToolButton = false;

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

    // Kategorien, Tags und Tools werden in _loadData geladen
    // sobald die verfügbaren Listen vom Server abgerufen wurden
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

    // Listen for category input changes to show/hide add button
    _categoryInputController.addListener(_onCategoryInputChanged);
    _tagInputController.addListener(_onTagInputChanged);
    _toolInputController.addListener(_onToolInputChanged);
  }

  void _onCategoryInputChanged() {
    final text = _categoryInputController.text.trim();
    final hasText = text.isNotEmpty;
    final existsInAvailable = _availableCategories?.any(
      (c) => c.name.toLowerCase() == text.toLowerCase()
    ) ?? false;
    final existsInSelected = _categories.any(
      (c) => c.name.toLowerCase() == text.toLowerCase()
    );
    final shouldShow = hasText && !existsInAvailable && !existsInSelected;
    if (_showAddCategoryButton != shouldShow) {
      setState(() => _showAddCategoryButton = shouldShow);
    }
  }

  void _onTagInputChanged() {
    final text = _tagInputController.text.trim();
    final hasText = text.isNotEmpty;
    final existsInAvailable = _availableTags?.any(
      (t) => t.name.toLowerCase() == text.toLowerCase()
    ) ?? false;
    final existsInSelected = _tags.any(
      (t) => t.name.toLowerCase() == text.toLowerCase()
    );
    final shouldShow = hasText && !existsInAvailable && !existsInSelected;
    if (_showAddTagButton != shouldShow) {
      setState(() => _showAddTagButton = shouldShow);
    }
  }

  void _onToolInputChanged() {
    final text = _toolInputController.text.trim();
    final hasText = text.isNotEmpty;
    final existsInAvailable = _availableTools?.any(
      (t) => t.name.toLowerCase() == text.toLowerCase()
    ) ?? false;
    final existsInSelected = _tools.any(
      (t) => t.name.toLowerCase() == text.toLowerCase()
    );
    final shouldShow = hasText && !existsInAvailable && !existsInSelected;
    if (_showAddToolButton != shouldShow) {
      setState(() => _showAddToolButton = shouldShow);
    }
  }

  Future<void> _loadData() async {
    setState(() => _dataLoading = true);
    try {
      final results = await Future.wait([
        _recipeRepo.getFoods(),
        _recipeRepo.getUnits(),
        _recipeRepo.getCategories(),
        _recipeRepo.getTags(),
        _recipeRepo.getTools(),
      ]);
      if (mounted) {
        setState(() {
          _foods = results[0] as List<Food>;
          _units = results[1] as List<ShoppingItemUnit>;
          _availableCategories = results[2] as List<RecipeCategory>;
          _availableTags = results[3] as List<RecipeTag>;
          _availableTools = results[4] as List<RecipeTool>;

          // Resolve existing category names to full objects
          final r = widget.recipe;
          for (final categoryName in r.recipeCategory) {
            final found = _availableCategories!.cast<RecipeCategory?>().firstWhere(
              (c) => c!.name.toLowerCase() == categoryName.toLowerCase(),
              orElse: () => null,
            );
            if (found != null && !_categories.any((c) => c.id == found.id)) {
              _categories.add(found);
            }
          }

          // Resolve existing tag names to full objects
          for (final tagName in r.tags) {
            final found = _availableTags!.cast<RecipeTag?>().firstWhere(
              (t) => t!.name.toLowerCase() == tagName.toLowerCase(),
              orElse: () => null,
            );
            if (found != null && !_tags.any((t) => t.id == found.id)) {
              _tags.add(found);
            }
          }

          // Resolve existing tool names to full objects
          for (final toolName in r.tools) {
            final found = _availableTools!.cast<RecipeTool?>().firstWhere(
              (t) => t!.name.toLowerCase() == toolName.toLowerCase(),
              orElse: () => null,
            );
            if (found != null && !_tools.any((t) => t.id == found.id)) {
              _tools.add(found);
            }
          }

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
      'recipeCategory': _categories.map((c) => c.toJson()).toList(),
      'tags': _tags.map((t) => t.toJson()).toList(),
      'tools': _tools.map((t) => t.toJson()).toList(),
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
    } on DioException catch (e) {
      debugPrint('Error updating recipe: $e');
      if (mounted) {
        setState(() => _saving = false);
        String message;
        final responseData = e.response?.data;
        if (responseData is Map && responseData['message']?.toString().contains('already exists') == true) {
          message = l10n.recipeAlreadyExists(name);
        } else {
          message = l10n.errorUpdating(responseData?['message']?.toString() ?? e.message ?? e.toString());
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
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


  Future<void> _handleCreateAndSelectCategory(String categoryName) async {
    if (categoryName.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;

    try {
      final category = await _recipeRepo.getOrCreateCategory(categoryName);

      // Update local list
      List<RecipeCategory> newList;
      if (_availableCategories != null) {
        final exists = _availableCategories!.any((c) => c.id == category.id);
        newList = exists
            ? _availableCategories!
            : [..._availableCategories!, category];
      } else {
        newList = [category];
      }

      setState(() {
        _availableCategories = newList;
        if (!_categories.any((c) => c.id == category.id)) {
          _categories.add(category);
        }
        _categoryInputController.clear();
        _showAddCategoryButton = false;
      });

      _categoryFocusNode.unfocus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.categoryCreated(categoryName)), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorCreating(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleDeleteCategory(RecipeCategory category) async {
    if (_availableCategories == null) return;
    final l10n = AppLocalizations.of(context)!;

    _categoryFocusNode.unfocus();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteCategory),
        content: Text(l10n.confirmDeleteCategory(category.name)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.delete, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true && category.id != null) {
      try {
        await _recipeRepo.deleteCategory(category.id!);
        final newList = List<RecipeCategory>.from(_availableCategories!)
          ..removeWhere((c) => c.id == category.id);

        setState(() {
          _availableCategories = newList;
          _categories.removeWhere((c) => c.id == category.id);
          _categoryInputController.clear();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.itemDeletedSuccess(category.name)), backgroundColor: Colors.green),
          );
        }
      } on DioException catch (e) {
        if (mounted) {
          String message;
          final responseData = e.response?.data;
          if (e.response?.statusCode == 400 &&
              responseData is Map &&
              responseData['exception'] != null &&
              responseData['exception'].toString().contains('ForeignKeyViolation')) {
            message = l10n.categoryStillInUse(category.name);
          } else {
            message = l10n.deleteFailed('${responseData?['message'] ?? e.message}');
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.deleteFailed(e.toString())), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _handleCreateAndSelectTag(String tagName) async {
    if (tagName.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;

    try {
      final tag = await _recipeRepo.getOrCreateTag(tagName);

      // Update local list
      List<RecipeTag> newList;
      if (_availableTags != null) {
        final exists = _availableTags!.any((t) => t.id == tag.id);
        newList = exists
            ? _availableTags!
            : [..._availableTags!, tag];
      } else {
        newList = [tag];
      }

      setState(() {
        _availableTags = newList;
        if (!_tags.any((t) => t.id == tag.id)) {
          _tags.add(tag);
        }
        _tagInputController.clear();
        _showAddTagButton = false;
      });

      _tagFocusNode.unfocus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.tagCreated(tagName)), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorCreating(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleDeleteTag(RecipeTag tag) async {
    if (_availableTags == null) return;
    final l10n = AppLocalizations.of(context)!;

    _tagFocusNode.unfocus();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteTag),
        content: Text(l10n.confirmDeleteTag(tag.name)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.delete, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true && tag.id != null) {
      try {
        await _recipeRepo.deleteTag(tag.id!);
        final newList = List<RecipeTag>.from(_availableTags!)
          ..removeWhere((t) => t.id == tag.id);

        setState(() {
          _availableTags = newList;
          _tags.removeWhere((t) => t.id == tag.id);
          _tagInputController.clear();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.itemDeletedSuccess(tag.name)), backgroundColor: Colors.green),
          );
        }
      } on DioException catch (e) {
        if (mounted) {
          String message;
          final responseData = e.response?.data;
          if (e.response?.statusCode == 400 &&
              responseData is Map &&
              responseData['exception'] != null &&
              responseData['exception'].toString().contains('ForeignKeyViolation')) {
            message = l10n.tagStillInUse(tag.name);
          } else {
            message = l10n.deleteFailed('${responseData?['message'] ?? e.message}');
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.deleteFailed(e.toString())), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _handleCreateAndSelectTool(String toolName) async {
    if (toolName.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;

    try {
      final tool = await _recipeRepo.getOrCreateTool(toolName);

      // Update local list
      List<RecipeTool> newList;
      if (_availableTools != null) {
        final exists = _availableTools!.any((t) => t.id == tool.id);
        newList = exists
            ? _availableTools!
            : [..._availableTools!, tool];
      } else {
        newList = [tool];
      }

      setState(() {
        _availableTools = newList;
        if (!_tools.any((t) => t.id == tool.id)) {
          _tools.add(tool);
        }
        _toolInputController.clear();
        _showAddToolButton = false;
      });

      _toolFocusNode.unfocus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.toolCreated(toolName)), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorCreating(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleDeleteTool(RecipeTool tool) async {
    if (_availableTools == null) return;
    final l10n = AppLocalizations.of(context)!;

    _toolFocusNode.unfocus();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteTool),
        content: Text(l10n.confirmDeleteTool(tool.name)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.delete, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true && tool.id != null) {
      try {
        await _recipeRepo.deleteTool(tool.id!);
        final newList = List<RecipeTool>.from(_availableTools!)
          ..removeWhere((t) => t.id == tool.id);

        setState(() {
          _availableTools = newList;
          _tools.removeWhere((t) => t.id == tool.id);
          _toolInputController.clear();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.itemDeletedSuccess(tool.name)), backgroundColor: Colors.green),
          );
        }
      } on DioException catch (e) {
        if (mounted) {
          String message;
          final responseData = e.response?.data;
          if (e.response?.statusCode == 400 &&
              responseData is Map &&
              responseData['exception'] != null &&
              responseData['exception'].toString().contains('ForeignKeyViolation')) {
            message = l10n.toolStillInUse(tool.name);
          } else {
            message = l10n.deleteFailed('${responseData?['message'] ?? e.message}');
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.deleteFailed(e.toString())), backgroundColor: Colors.red),
          );
        }
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
              _buildCategoryInput(l10n),
              const SizedBox(height: 24),

              // ── Tags ──
              _buildSectionHeader(l10n.tags, Icons.label_outline),
              const SizedBox(height: 8),
              _buildTagInput(l10n),
              const SizedBox(height: 24),

              // ── Tools ──
              _buildSectionHeader(l10n.tools, Icons.handyman_outlined),
              const SizedBox(height: 8),
              _buildToolInput(l10n),
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


  Widget _buildCategoryInput(AppLocalizations l10n) {
    final categoryOptions = _availableCategories ?? <RecipeCategory>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected categories as chips
        if (_categories.isNotEmpty) ...[
          Wrap(
            spacing: 6, runSpacing: 4,
            children: _categories.asMap().entries.map((entry) {
              return Chip(
                label: Text(entry.value.name, style: const TextStyle(fontSize: 13)),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => setState(() => _categories.removeAt(entry.key)),
                backgroundColor: _accent.withAlpha(30),
                side: BorderSide(color: _accent.withAlpha(80)),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
        // Autocomplete input
        RawAutocomplete<RecipeCategory>(
          textEditingController: _categoryInputController,
          focusNode: _categoryFocusNode,
          displayStringForOption: (cat) => cat.name,
          optionsBuilder: (textEditingValue) {
            final query = textEditingValue.text.toLowerCase();
            if (query.isEmpty) return const Iterable.empty();
            return categoryOptions.where((cat) =>
              cat.name.toLowerCase().contains(query) &&
              !_categories.any((c) => c.id == cat.id)
            );
          },
          onSelected: (category) {
            if (!_categories.any((c) => c.id == category.id)) {
              setState(() => _categories.add(category));
            }
            _categoryInputController.clear();
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: l10n.categoriesHint,
                prefixIcon: const Icon(Icons.category_outlined, size: 20),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                suffixIcon: _showAddCategoryButton
                    ? IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => _handleCreateAndSelectCategory(controller.text.trim()),
                        tooltip: l10n.addNewCategory,
                      )
                    : null,
              ),
              onSubmitted: (_) {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                // Check if it matches an existing category
                final match = categoryOptions.cast<RecipeCategory?>().firstWhere(
                  (c) => c!.name.toLowerCase() == text.toLowerCase(),
                  orElse: () => null,
                );
                if (match != null && !_categories.any((c) => c.id == match.id)) {
                  setState(() => _categories.add(match));
                  controller.clear();
                } else if (_showAddCategoryButton) {
                  _handleCreateAndSelectCategory(text);
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
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final category = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(category),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(category.name),
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    _categoryFocusNode.unfocus();
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      _handleDeleteCategory(category);
                                    });
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(8),
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
            );
          },
        ),
      ],
    );
  }

  Widget _buildTagInput(AppLocalizations l10n) {
    final tagOptions = _availableTags ?? <RecipeTag>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected tags as chips
        if (_tags.isNotEmpty) ...[
          Wrap(
            spacing: 6, runSpacing: 4,
            children: _tags.asMap().entries.map((entry) {
              return Chip(
                label: Text(entry.value.name, style: const TextStyle(fontSize: 13)),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => setState(() => _tags.removeAt(entry.key)),
                backgroundColor: _accent.withAlpha(30),
                side: BorderSide(color: _accent.withAlpha(80)),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
        // Autocomplete input
        RawAutocomplete<RecipeTag>(
          textEditingController: _tagInputController,
          focusNode: _tagFocusNode,
          displayStringForOption: (tag) => tag.name,
          optionsBuilder: (textEditingValue) {
            final query = textEditingValue.text.toLowerCase();
            if (query.isEmpty) return const Iterable.empty();
            return tagOptions.where((tag) =>
              tag.name.toLowerCase().contains(query) &&
              !_tags.any((t) => t.id == tag.id)
            );
          },
          onSelected: (tag) {
            if (!_tags.any((t) => t.id == tag.id)) {
              setState(() => _tags.add(tag));
            }
            _tagInputController.clear();
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: l10n.tagsHint,
                prefixIcon: const Icon(Icons.label_outline, size: 20),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                suffixIcon: _showAddTagButton
                    ? IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => _handleCreateAndSelectTag(controller.text.trim()),
                        tooltip: l10n.addNewTag,
                      )
                    : null,
              ),
              onSubmitted: (_) {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                // Check if it matches an existing tag
                final match = tagOptions.cast<RecipeTag?>().firstWhere(
                  (t) => t!.name.toLowerCase() == text.toLowerCase(),
                  orElse: () => null,
                );
                if (match != null && !_tags.any((t) => t.id == match.id)) {
                  setState(() => _tags.add(match));
                  controller.clear();
                } else if (_showAddTagButton) {
                  _handleCreateAndSelectTag(text);
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
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final tag = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(tag),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(tag.name),
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    _tagFocusNode.unfocus();
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      _handleDeleteTag(tag);
                                    });
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(8),
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
            );
          },
        ),
      ],
    );
  }

  Widget _buildToolInput(AppLocalizations l10n) {
    final toolOptions = _availableTools ?? <RecipeTool>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected tools as chips
        if (_tools.isNotEmpty) ...[
          Wrap(
            spacing: 6, runSpacing: 4,
            children: _tools.asMap().entries.map((entry) {
              return Chip(
                label: Text(entry.value.name, style: const TextStyle(fontSize: 13)),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => setState(() => _tools.removeAt(entry.key)),
                backgroundColor: _accent.withAlpha(30),
                side: BorderSide(color: _accent.withAlpha(80)),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
        // Autocomplete input
        RawAutocomplete<RecipeTool>(
          textEditingController: _toolInputController,
          focusNode: _toolFocusNode,
          displayStringForOption: (tool) => tool.name,
          optionsBuilder: (textEditingValue) {
            final query = textEditingValue.text.toLowerCase();
            if (query.isEmpty) return const Iterable.empty();
            return toolOptions.where((tool) =>
              tool.name.toLowerCase().contains(query) &&
              !_tools.any((t) => t.id == tool.id)
            );
          },
          onSelected: (tool) {
            if (!_tools.any((t) => t.id == tool.id)) {
              setState(() => _tools.add(tool));
            }
            _toolInputController.clear();
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: l10n.toolsHint,
                prefixIcon: const Icon(Icons.handyman_outlined, size: 20),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                suffixIcon: _showAddToolButton
                    ? IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => _handleCreateAndSelectTool(controller.text.trim()),
                        tooltip: l10n.addNewTool,
                      )
                    : null,
              ),
              onSubmitted: (_) {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                // Check if it matches an existing tool
                final match = toolOptions.cast<RecipeTool?>().firstWhere(
                  (t) => t!.name.toLowerCase() == text.toLowerCase(),
                  orElse: () => null,
                );
                if (match != null && !_tools.any((t) => t.id == match.id)) {
                  setState(() => _tools.add(match));
                  controller.clear();
                } else if (_showAddToolButton) {
                  _handleCreateAndSelectTool(text);
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
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final tool = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(tool),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(tool.name),
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    _toolFocusNode.unfocus();
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      _handleDeleteTool(tool);
                                    });
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(8),
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
            );
          },
        ),
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
    _categoryInputController.removeListener(_onCategoryInputChanged);
    _categoryInputController.dispose();
    _categoryFocusNode.dispose();
    _tagInputController.removeListener(_onTagInputChanged);
    _tagInputController.dispose();
    _tagFocusNode.dispose();
    _toolInputController.removeListener(_onToolInputChanged);
    _toolInputController.dispose();
    _toolFocusNode.dispose();
    _instructionInputController.dispose();
    _recipeNoteController.dispose();
    super.dispose();
  }
}
