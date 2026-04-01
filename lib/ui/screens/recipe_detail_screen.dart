import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mealique/data/remote/api_exceptions.dart';
import 'package:mealique/data/sync/recipe_repository.dart';
import 'package:mealique/data/local/token_storage.dart';
import 'package:mealique/models/recipes_model.dart';
import 'package:mealique/ui/screens/edit_recipe_screen.dart';
import 'package:mealique/ui/widgets/recipe_detail_actions_menu.dart';
import 'package:mealique/ui/widgets/recipe_image.dart';
import '../../l10n/app_localizations.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeSlug;

  const RecipeDetailScreen({super.key, required this.recipeSlug});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final RecipeRepository _recipeRepository = RecipeRepository();
  late Future<Recipe> _recipeFuture;

  // Favoriten-Status wird separat geladen/gespeichert
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
        // Favoriten-Status im Hintergrund nachladen
        _loadFavoriteStatus(recipe.slug);
        return recipe;
      });
    });
  }

  Future<void> _loadFavoriteStatus(String slug) async {
    try {
      final status = await _recipeRepository.getFavoriteStatus(slug);
      if (mounted) setState(() => _isFavorite = status);
    } catch (_) {
      if (mounted) setState(() => _isFavorite = false);
    }
  }

  Future<void> _toggleFavorite(Recipe recipe) async {
    if (_favoriteLoading) return;
    final current = _isFavorite ?? false;
    final newValue = !current;

    // Optimistisches Update sofort zeigen
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            l10n.recipeNotFound,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingRow(Recipe recipe) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.rating,
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
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
                    : Colors.grey[400],
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
          letterSpacing: 1.2,
          color: _accentColor,
        ),
      ),
    );
  }

  Widget _buildIngredientItem(String text, {required bool isChecked}) {
    return CheckboxListTile(
      value: isChecked,
      onChanged: (val) {},
      title: Text(
        text,
        style: TextStyle(
          decoration: isChecked ? TextDecoration.lineThrough : null,
          color: isChecked ? Colors.grey : Colors.black,
        ),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
      activeColor: _accentColor,
    );
  }

  Widget _buildInstructionStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: _accentColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeContent(Recipe recipe) {
    final l10n = AppLocalizations.of(context)!;

    return RefreshIndicator(
      onRefresh: () async => _loadRecipe(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        children: [
          // -- Hero image area --
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: RecipeImage(
                    recipeId: recipe.id,
                    imageHint: recipe.image,
                    size: RecipeImageSize.original,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          _accentColor.withValues(alpha: 0.9),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      recipe.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // -- Info chips --
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoChip(Icons.access_time, recipe.totalTime ?? '- Min'),
              Container(width: 1, height: 24, color: Colors.grey[300]),
              _buildInfoChip(Icons.person_outline, l10n.servingsCount(recipe.servings)),
            ],
          ),
          const SizedBox(height: 16),

          // -- Rating --
          _buildRatingRow(recipe),
          const SizedBox(height: 16),

          // -- Add to shopping list button --
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: Text(l10n.addToShoppingList),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // -- Description --
          if (recipe.description != null && recipe.description!.isNotEmpty) ...[
            _buildSectionTitle(l10n.description),
            Text(
              recipe.description!,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ],

          // -- Ingredients --
          if (recipe.ingredients.isNotEmpty) ...[
            _buildSectionTitle(l10n.ingredients),
            for (final ingredient in recipe.ingredients)
              _buildIngredientItem(ingredient.note, isChecked: false),
          ],

          // -- Instructions --
          if (recipe.instructions.isNotEmpty) ...[
            _buildSectionTitle(l10n.instructions),
            const SizedBox(height: 8),
            for (int i = 0; i < recipe.instructions.length; i++)
              _buildInstructionStep(i + 1, recipe.instructions[i].text),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
        title: FutureBuilder<Recipe>(
          future: _recipeFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data!.name);
            }
            return const Text('');
          },
        ),
        actions: [
          FutureBuilder<Recipe>(
            future: _recipeFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              final recipe = snapshot.data!;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_favoriteLoading)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    IconButton(
                      icon: Icon(
                        (_isFavorite ?? false)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: (_isFavorite ?? false)
                            ? Colors.red[300]
                            : Colors.white,
                      ),
                      tooltip: (_isFavorite ?? false)
                          ? AppLocalizations.of(context)!.removeFromFavorites
                          : AppLocalizations.of(context)!.addToFavorites,
                      onPressed: () => _toggleFavorite(recipe),
                    ),
                  RecipeDetailActionsMenu(
                    onEdit: () => _showEditRecipeSheet(recipe),
                    onDelete: () => _confirmDeleteRecipe(recipe),
                    onShare: () => _shareRecipe(recipe),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Recipe>(
        future: _recipeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error!, _loadRecipe);
          }
          if (!snapshot.hasData) {
            return _buildEmptyState();
          }
          return _buildRecipeContent(snapshot.data!);
        },
      ),
    );
  }
}
