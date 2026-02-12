import 'package:flutter/material.dart';
import 'package:mealique/data/sync/recipe_repository.dart';
import 'package:mealique/models/recipes_model.dart';

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

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _searchFuture = _searchRecipes(widget.initialQuery);
  }

  Future<List<Recipe>> _searchRecipes(String query) {
    return _recipeRepository.getRecipes(searchQuery: query);
  }

  void _onSearchSubmitted(String query) {
    if (query.isNotEmpty) {
      setState(() {
        _searchFuture = _searchRecipes(query);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search recipes...',
            border: InputBorder.none,
          ),
          onSubmitted: _onSearchSubmitted,
        ),
      ),
      body: FutureBuilder<List<Recipe>>(
        future: _searchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No recipes found.'));
          }

          final recipes = snapshot.data!;
          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return ListTile(
                title: Text(recipe.name),
                // TODO: Add navigation to recipe detail screen
              );
            },
          );
        },
      ),
    );
  }
}
