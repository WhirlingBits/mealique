import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mealique/data/remote/api_exceptions.dart';
import 'package:mealique/data/sync/recipe_repository.dart';
import 'package:mealique/models/recipes_model.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeSlug;

  const RecipeDetailScreen({super.key, required this.recipeSlug});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final RecipeRepository _recipeRepository = RecipeRepository();
  late Future<Recipe> _recipeFuture;

  @override
  void initState() {
    super.initState();
    _recipeFuture = _recipeRepository.getRecipe(widget.recipeSlug);
  }

  Widget _buildErrorWidget(Object error, VoidCallback onRetry) {
    String errorMessage;
    if (error is DioException && error.error is ApiException) {
      final apiError = error.error as ApiException;
      errorMessage = apiError.message;
    } else {
      errorMessage = 'Ein unerwarteter Fehler ist aufgetreten.';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(errorMessage, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Erneut versuchen')),
        ],
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
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<Recipe>(
              future: _recipeFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return _buildErrorWidget(snapshot.error!, () {
                    setState(() {
                      _recipeFuture = _recipeRepository.getRecipe(widget.recipeSlug);
                    });
                  });
                } else if (!snapshot.hasData) {
                  return const Center(child: Text('Recipe not found.'));
                }

                final recipe = snapshot.data!;

                return CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 250.0,
                      pinned: true,
                      backgroundColor: accentColor,
                      automaticallyImplyLeading: false,
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.favorite_border),
                          onPressed: () {
                            // TODO: Favoriten Logik
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            // TODO: Menü Logik
                          },
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(
                          recipe.name,
                          style: const TextStyle(
                            color: Colors.white,
                            shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                          ),
                        ),
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(
                              color: Colors.grey[400],
                              child: const Icon(Icons.image, size: 80, color: Colors.white54),
                            ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    accentColor.withOpacity(0.9),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildInfoChip(Icons.access_time, recipe.totalTime ?? '- Min'),
                                Container(width: 1, height: 24, color: Colors.grey[300]),
                                _buildInfoChip(Icons.person_outline, '${recipe.servings} Portionen'),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.add),
                                label: const Text('Zur Einkaufsliste'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            _buildSectionTitle('ZUTATEN', accentColor),
                            const SizedBox(height: 8),
                            for (final ingredient in recipe.ingredients)
                              _buildIngredientItem(ingredient.note, isChecked: false, accentColor: accentColor),
                            const SizedBox(height: 32),
                            _buildSectionTitle('ZUBEREITUNG', accentColor),
                            const SizedBox(height: 16),
                            for (int i = 0; i < recipe.instructions.length; i++)
                              _buildInstructionStep(i + 1, recipe.instructions[i].text, accentColor),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
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

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: color,
      ),
    );
  }

  Widget _buildIngredientItem(String text, {required bool isChecked, required Color accentColor}) {
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
      activeColor: accentColor,
    );
  }

  Widget _buildInstructionStep(int number, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
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
}
