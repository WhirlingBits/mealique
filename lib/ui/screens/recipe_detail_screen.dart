import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mealique/data/local/token_storage.dart';
import 'package:mealique/data/remote/api_exceptions.dart';
import 'package:mealique/data/sync/household_repository.dart';
import 'package:mealique/data/sync/recipe_repository.dart';
import 'package:mealique/l10n/app_localizations.dart';
import 'package:mealique/models/add_recipe_to_list_payload.dart';
import 'package:mealique/models/recipes_model.dart';
import 'package:mealique/models/shopping_list_model.dart';
import 'package:mealique/ui/screens/edit_recipe_screen.dart';
import 'package:mealique/ui/widgets/recipe_detail_actions_menu.dart';
import 'package:mealique/ui/widgets/recipe_image.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeSlug;

  const RecipeDetailScreen({super.key, required this.recipeSlug});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final RecipeRepository _recipeRepository = RecipeRepository();
  final HouseholdRepository _householdRepository = HouseholdRepository();
  late Future<Recipe> _recipeFuture;
  bool? _isFavorite; // null = noch nicht geladen
  bool _favoriteLoading = false;

  static const Color _accentColor = Color(0xFFE58325);

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  void _loadRecipe() {
    setState(() {
      _isFavorite = null; // zurücksetzen beim Neu-Laden
      _recipeFuture = _recipeRepository.getRecipe(widget.recipeSlug).then((recipe) {
        // Favoriten-Status separat nachladen (wird per-user gespeichert)
        // Nutze recipeId für effizienteren API-Call
        _loadFavoriteStatus(recipe.id);
        return recipe;
      });
    });
  }

  Future<void> _loadFavoriteStatus(String recipeId) async {
    try {
      debugPrint('Loading favorite status for recipeId: $recipeId');
      final status = await _recipeRepository.getFavoriteStatusById(recipeId);
      debugPrint('Favorite status loaded: $status');
      if (mounted) setState(() => _isFavorite = status);
    } catch (e) {
      debugPrint('Error loading favorite status: $e');
      if (mounted) setState(() => _isFavorite = false);
    }
  }

  Future<void> _toggleFavorite(Recipe recipe) async {
    if (_favoriteLoading) return;

    final current = _isFavorite ?? false;
    final newValue = !current;

    setState(() {
      _isFavorite = newValue;
      _favoriteLoading = true;
    });

    try {
      await _recipeRepository.setFavorite(recipe.slug, isFavorite: newValue);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newValue ? l10n.addToFavorites : l10n.removeFromFavorites,
            ),
            backgroundColor: newValue ? Colors.green : Colors.grey[700],
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      // Rollback bei Fehler
      if (mounted) {
        setState(() => _isFavorite = current);
        final l10n = AppLocalizations.of(context)!;
        _showError(l10n.errorUpdating(e.toString()));
      }
    } finally {
      if (mounted) setState(() => _favoriteLoading = false);
    }
  }

  Future<void> _confirmDeleteRecipe(Recipe recipe) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteRecipe),
        content: Text(l10n.confirmDeleteRecipe),
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
        await _recipeRepository.deleteRecipe(recipe.slug);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.itemDeletedSuccess(recipe.name)),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          _showError(l10n.errorDeleting(e.toString()));
        }
      }
    }
  }

  Future<void> _shareRecipe(Recipe recipe) async {
    final serverUrl = await TokenStorage().getServerUrl();
    final recipeUrl = '$serverUrl/recipe/${recipe.slug}';
    await Clipboard.setData(ClipboardData(text: recipeUrl));
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.share}: URL kopiert')),
      );
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showEditRecipeSheet(Recipe recipe) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EditRecipeScreen(recipe: recipe),
      ),
    );
    // If the recipe was updated, reload it
    if (result == true) {
      _loadRecipe();
    }
  }

  Future<void> _showAddToShoppingListDialog(Recipe recipe) async {
    final l10n = AppLocalizations.of(context)!;
    debugPrint('DEBUG: _showAddToShoppingListDialog triggered for recipe: ${recipe.name}');

    if (recipe.ingredients.isEmpty) {
      debugPrint('DEBUG: Recipe has no ingredients.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.noIngredientsToAdd),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Einkaufslisten laden
    List<ShoppingList>? lists;
    try {
      debugPrint('DEBUG: Fetching shopping lists...');
      lists = await _householdRepository.getShoppingLists();
      debugPrint('DEBUG: Found ${lists?.length ?? 0} lists.');
    } catch (e) {
      debugPrint('DEBUG: Error fetching shopping lists: $e');
      if (mounted) {
        _showError(l10n.unexpectedError);
      }
      return;
    }

    if (!mounted) return;

    if (lists == null || lists.isEmpty) {
      debugPrint('DEBUG: No shopping lists found on server.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.noShoppingListsFound),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Kopie der Liste für den Builder erstellen (nicht nullable)
    final shoppingLists = lists;

    // Dialog zur Auswahl der Einkaufsliste
    final selectedList = await showModalBottomSheet<ShoppingList>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.selectShoppingList,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: shoppingLists.length,
                itemBuilder: (context, index) {
                  final list = shoppingLists[index];
                  return ListTile(
                    leading: const Icon(Icons.shopping_cart_outlined, color: _accentColor),
                    title: Text(list.name),
                    onTap: () => Navigator.of(ctx).pop(list),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (selectedList == null || !mounted) {
      debugPrint('DEBUG: No list selected or screen unmounted.');
      return;
    }

    debugPrint('DEBUG: Selected list: ${selectedList.name} (${selectedList.id})');

    // Zutaten zur Liste hinzufügen
    try {
      // Konvertiere Zutaten in RecipeIngredientRef mit allen erforderlichen Daten
      final ingredientsPayload = recipe.ingredients
          .where((ing) => ing.referenceId != null && ing.referenceId!.isNotEmpty)
          .map((ing) => RecipeIngredientRef(
            referenceId: ing.referenceId!,
            quantity: ing.quantity > 0 ? ing.quantity : null,
            note: ing.note.isNotEmpty ? ing.note : null,
            display: ing.display.isNotEmpty ? ing.display : null,
            foodId: ing.foodId,
            foodName: ing.food,
            unitId: ing.unitId,
            unitName: ing.unit,
          ))
          .toList();

      debugPrint('DEBUG: Ingredients payload count: ${ingredientsPayload.length}');
      for (var p in ingredientsPayload) {
        debugPrint('DEBUG: Ingredient Ref: ${p.referenceId}, foodId: ${p.foodId}');
      }

      await _householdRepository.addRecipeIngredientsToShoppingList(
        listId: selectedList.id,
        recipeId: recipe.id,
        ingredients: ingredientsPayload.isNotEmpty ? ingredientsPayload : null,
      );

      debugPrint('DEBUG: Successfully added ingredients to list.');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.ingredientsAddedToList(selectedList.name)),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } on DioException catch (e) {
      debugPrint('DEBUG: DioException in addRecipeIngredientsToShoppingList:');
      debugPrint('DEBUG: Status: ${e.response?.statusCode}');
      debugPrint('DEBUG: Data: ${e.response?.data}');
      debugPrint('DEBUG: Message: ${e.message}');
      if (mounted) {
        final detail = e.response?.data?['detail'] ?? e.message ?? 'Unknown error';
        _showError(l10n.errorAdding(detail.toString()));
      }
    } catch (e) {
      debugPrint('DEBUG: Unexpected error in _showAddToShoppingListDialog: $e');
      if (mounted) {
        _showError(l10n.errorAdding(e.toString()));
      }
    }
  }

  Widget _buildErrorWidget(Object error, VoidCallback onRetry) {
    final l10n = AppLocalizations.of(context)!;
    String errorMessage;

    if (error is DioException && error.error is ApiException) {
      final apiError = error.error as ApiException;
      if (apiError is NetworkException) {
        errorMessage = l10n.checkInternetConnection;
      } else if (apiError is ServerException) {
        errorMessage = l10n.serverError;
      } else {
        errorMessage = apiError.message;
      }
    } else {
      errorMessage = l10n.unexpectedError;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: Text(l10n.tryAgain)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 80, color: isDark ? Colors.grey[600] : Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            l10n.recipeNotFound,
            style: TextStyle(fontSize: 18, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;
    return Row(
      children: [
        Icon(icon, size: 20, color: textColor?.withOpacity(0.7)),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingRow(Recipe recipe) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.rating,
          style: TextStyle(fontSize: 14, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
        ),
        const SizedBox(width: 8),
        ...List.generate(5, (i) {
          final starIndex = i + 1;
          return GestureDetector(
            onTap: () => _updateRating(recipe, starIndex),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                starIndex <= recipe.rating
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: starIndex <= recipe.rating
                    ? Colors.amber
                    : isDark ? Colors.grey[600] : Colors.grey[400],
                size: 32,
              ),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _updateRating(Recipe recipe, int newRating) async {
    // Toggle: tapping the same star resets to 0
    final rating = recipe.rating == newRating ? 0 : newRating;
    try {
      await _recipeRepository.setRating(recipe.slug, rating.toDouble());
      _loadRecipe();
    } catch (e) {
      debugPrint('Error updating rating: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _showError(l10n.errorUpdating(e.toString()));
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: _accentColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<Recipe>(
      future: _recipeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.error)),
            body: _buildErrorWidget(snapshot.error!, _loadRecipe),
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.recipeNotFound)),
            body: _buildEmptyState(),
          );
        }

        final recipe = snapshot.data!;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Dynamic AppBar with Image
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: _accentColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      RecipeImage(
                        recipeId: recipe.id,
                        imageHint: recipe.image,
                        fit: BoxFit.cover,
                      ),
                      // Gradient overlay for better text readability
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black54, Colors.transparent, Colors.black54],
                            stops: [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  // Favoriten-Button mit Ladezustand
                  if (_isFavorite == null)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    IconButton(
                      icon: Icon(
                        (_isFavorite ?? false) ? Icons.favorite : Icons.favorite_border,
                        color: (_isFavorite ?? false) ? Colors.red : Colors.white,
                      ),
                      onPressed: () => _toggleFavorite(recipe),
                    ),
                  RecipeDetailActionsMenu(
                    onEdit: () => _showEditRecipeSheet(recipe),
                    onDelete: () => _confirmDeleteRecipe(recipe),
                    onShare: () => _shareRecipe(recipe),
                  ),
                ],
              ),

              // Recipe Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Description
                      Text(
                        recipe.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (recipe.description != null && recipe.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          recipe.description!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                            height: 1.4,
                          ),
                        ),
                      ],

                      const Divider(height: 32),

                      // Cooking Info Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (recipe.totalTime != null)
                            _buildInfoChip(Icons.timer_outlined, recipe.totalTime!),
                          _buildInfoChip(Icons.people_outline, recipe.servings.toString()),
                        ],
                      ),

                      const Divider(height: 32),

                      // Rating Section
                      _buildRatingRow(recipe),

                      const Divider(height: 32),

                      // Ingredients Section
                      _buildSectionTitle(l10n.ingredients),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recipe.ingredients.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final ingredient = recipe.ingredients[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.circle, size: 8, color: _accentColor),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    ingredient.displayText,
                                    style: TextStyle(
                                      fontSize: 16,
                                      height: 1.3,
                                      color: Theme.of(context).textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                          label: Text(l10n.addToShoppingList),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _showAddToShoppingListDialog(recipe),
                        ),
                      ),

                      // Instructions Section
                      if (recipe.instructions.isNotEmpty) ...[
                        _buildSectionTitle(l10n.instructions),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recipe.instructions.length,
                          itemBuilder: (context, index) {
                            final instruction = recipe.instructions[index];
                            final isDark = Theme.of(context).brightness == Brightness.dark;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: _accentColor.withValues(alpha: isDark ? 0.3 : 0.1),
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: _accentColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      instruction.text,
                                      style: TextStyle(
                                        fontSize: 16,
                                        height: 1.5,
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],

                      // Notes Section
                      if (recipe.notes.isNotEmpty) ...[
                        _buildSectionTitle(l10n.notes),
                        ...recipe.notes.map((note) {
                          final isDark = Theme.of(context).brightness == Brightness.dark;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: isDark ? Colors.amber[900]?.withValues(alpha: 0.3) : Colors.amber[50],
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (note.title.isNotEmpty)
                                    Text(
                                      note.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  Text(
                                    note.text,
                                    style: TextStyle(
                                      height: 1.4,
                                      color: Theme.of(context).textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
