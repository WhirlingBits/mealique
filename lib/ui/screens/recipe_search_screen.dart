import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mealique/data/remote/api_exceptions.dart';
import 'package:mealique/data/sync/recipe_repository.dart';
import 'package:mealique/models/recipes_model.dart';
import 'package:mealique/ui/screens/recipe_detail_screen.dart';

class RecipeSearchScreen extends StatefulWidget {
  final String initialQuery;

  const RecipeSearchScreen({super.key, required this.initialQuery});

  @override
  State<RecipeSearchScreen> createState() => _RecipeSearchScreenState();
}

class _RecipeSearchScreenState extends State<RecipeSearchScreen> {
  final RecipeRepository _recipeRepository = RecipeRepository();
  late Future<List<Recipe>> _searchFuture;
  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _searchFuture = _searchRecipes(widget.initialQuery);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _onSearchSubmitted(_searchController.text);
    });
  }

  Future<List<Recipe>> _searchRecipes(String query) {
    if (query.isEmpty) {
      return Future.value([]);
    }
    return _recipeRepository.getRecipes(searchQuery: query);
  }

  void _onSearchSubmitted(String query) {
    setState(() {
      _searchFuture = _searchRecipes(query);
    });
  }

  Widget _buildErrorWidget(Object error, VoidCallback onRetry) {
    String errorMessage;
    if (error is DioException && error.error is ApiException) {
      final apiError = error.error as ApiException;
      errorMessage = apiError.message;
    } else {
      errorMessage = 'An unexpected error occurred.'; // TODO: l10n
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(errorMessage, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Try Again'), // TODO: l10n
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'No Recipes Found', // TODO: l10n
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for something else.', // TODO: l10n
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeListItem(Recipe recipe) {
    const accentColor = Color(0xFFE58325);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: accentColor, width: 1),
      ),
      child: Slidable(
        key: ValueKey(recipe.id),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.5,
          children: [
            SlidableAction(
              onPressed: (context) {
                // TODO: Edit recipe logic
              },
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Bearbeiten', // TODO: l10n
            ),
            SlidableAction(
              onPressed: (context) {
                // TODO: Add to favorites logic
              },
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.favorite,
              label: 'Favorit', // TODO: l10n
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(8),
          leading: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.image, color: Colors.white),
          ),
          title: Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(recipe.totalTime ?? '- min'),
          onTap: () {
            // We show the detail screen on top of the search sheet
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              backgroundColor: Colors.transparent,
              builder: (context) => RecipeDetailScreen(recipeSlug: recipe.slug),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFE58325);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: accentColor),
              decoration: InputDecoration(
                hintText: 'Search for recipes...', // TODO: l10n
                hintStyle: TextStyle(color: accentColor.withOpacity(0.7)),
                prefixIcon: const Icon(Icons.search, color: accentColor),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: accentColor),
                  onPressed: _searchController.clear,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: accentColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: accentColor, width: 2.0),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onSubmitted: _onSearchSubmitted,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Recipe>>(
              future: _searchFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return _buildErrorWidget(snapshot.error!, () {
                    _onSearchSubmitted(_searchController.text);
                  });
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                final recipes = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return _buildRecipeListItem(recipe);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
