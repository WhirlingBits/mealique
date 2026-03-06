import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mealique/data/remote/api_exceptions.dart';
import 'package:mealique/ui/screens/recipe_detail_screen.dart';
import 'package:mealique/ui/widgets/recipe_actions_menu.dart';
import '../../data/sync/recipe_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/recipes_model.dart';
import '../widgets/add_recipe_form.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  late Future<List<Recipe>> _recipesFuture;
  final RecipeRepository _recipeRepository = RecipeRepository();

  @override
  void initState() {
    super.initState();
    _recipesFuture = _recipeRepository.getRecipes();
  }

  void _showAddRecipeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: AddRecipeForm(
          onAddRecipe: (recipeName) {
            // TODO: Implement recipe creation logic
            print('Recipe to add: $recipeName');
            Navigator.pop(ctx);
          },
        ),
      ),
    );
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
            ElevatedButton(
              onPressed: onRetry,
              child: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE58325),
        foregroundColor: Colors.white,
        title: Text(l10n.recipes),
        actions: [
          RecipeActionsMenu(
            onAddRecipe: () => _showAddRecipeSheet(context),
            onRefresh: () {
              setState(() {
                _recipesFuture = _recipeRepository.getRecipes();
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: l10n.search,
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.tune),
                      onPressed: () {},
                      tooltip: l10n.filter,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Recipe>>(
                future: _recipesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return _buildErrorWidget(snapshot.error!, () {
                      setState(() {
                        _recipesFuture = _recipeRepository.getRecipes();
                      });
                    });
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text(l10n.noRecipesFound));
                  }

                  final recipes = snapshot.data!;
                  return SlidableAutoCloseBehavior(
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        return _buildRecipeCard(context, recipes[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecipeSheet(context),
        tooltip: l10n.addRecipe,
        backgroundColor: Colors.green, // Changed to green
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, Recipe recipe) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Slidable(
        key: ValueKey(recipe.id),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.5,
          children: [
            SlidableAction(
              flex: 1,
              onPressed: (context) {
                // TODO: Bearbeiten Logik
              },
              backgroundColor: const Color(0xFFE58325),
              foregroundColor: Colors.white,
              icon: Icons.edit,
            ),
            SlidableAction(
              flex: 1,
              onPressed: (context) {
                // TODO: Löschen Logik
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
            ),
          ],
        ),
        child: Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: Colors.transparent,
                builder: (context) => RecipeDetailScreen(recipeSlug: recipe.slug),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.grey[300],
                        // TODO: Use recipe image
                        child: const Icon(Icons.image, size: 50, color: Colors.white),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.favorite_border, color: Colors.white),
                          onPressed: () {
                            // TODO: Toggle favorite
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            recipe.totalTime ?? '- m',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
