import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mealique/data/sync/mealplan_repository.dart';
import 'package:mealique/data/sync/recipe_repository.dart';
import 'package:mealique/data/sync/user_repository.dart';
import 'package:mealique/l10n/app_localizations.dart';
import 'package:mealique/models/mealplan_model.dart';
import 'package:mealique/models/recipes_model.dart';
import 'package:mealique/models/user_self_model.dart';
import 'package:mealique/ui/screens/recipe_search_screen.dart';
import '../widgets/add_recipe_form.dart';
import '../widgets/add_shopping_list_form.dart';
import '../widgets/add_shopping_list_item_form.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final MealplanRepository _mealplanRepository = MealplanRepository();
  final RecipeRepository _recipeRepository = RecipeRepository();
  final UserRepository _userRepository = UserRepository();

  late Future<List<MealplanEntry>> _todaysMealsFuture;
  late Future<List<Recipe>> _popularRecipesFuture;
  late Future<UserSelf> _userFuture;

  @override
  void initState() {
    super.initState();
    _todaysMealsFuture = _fetchTodaysMeals();
    _popularRecipesFuture = _fetchPopularRecipes();
    _userFuture = _userRepository.getSelfUser();
  }

  Future<List<MealplanEntry>> _fetchTodaysMeals() async {
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    final mealsByDay = await _mealplanRepository.getMealplans(today, today);
    return mealsByDay[today] ?? [];
  }

  Future<List<Recipe>> _fetchPopularRecipes() async {
    return _recipeRepository.getRecipes(sort: '-rating', perPage: 5);
  }

  void _showAddRecipeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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

  void _showAddShoppingListItemSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: AddShoppingListItemForm(
          onAddItem: (item) {
            // TODO: Implement shopping item creation logic
            print('New item to add:');
            print('  List ID: ${item.listId}');
            print('  Food ID: ${item.foodId}');
            print('  Quantity: ${item.quantity}');
            print('  Unit ID: ${item.unitId}');
            print('  Category ID: ${item.categoryId}');
            Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  void _showAddShoppingListSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: AddShoppingListForm(
          onAddList: (listName) {
            // TODO: Implement shopping list creation logic
            print('Shopping list to create: $listName');
            Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  String _getGreeting(BuildContext context, String name) {
    final l10n = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return l10n.greetingGoodMorning(name);
    } else if (hour < 18) {
      return l10n.greetingGoodDay(name);
    } else {
      return l10n.greetingGoodEvening(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Begrüßung und Suche
              FutureBuilder<UserSelf>(
                future: _userFuture,
                builder: (context, snapshot) {
                  String name = 'there'; // Default name
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    name = snapshot.data!.fullName;
                  }
                  return Text(
                    _getGreeting(context, name),
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  );
                },
              ),
              const SizedBox(height: 4),
              Text(
                l10n.whatDoYouWantToCook,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: l10n.recipeSearch,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.cardColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
                onSubmitted: (query) {
                  if (query.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RecipeSearchScreen(initialQuery: query),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),

              // Section: Today
              _buildSectionTitle(l10n.today.toUpperCase()),
              const SizedBox(height: 8),
              FutureBuilder<List<MealplanEntry>>(
                future: _todaysMealsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text(l10n.noMealsPlanned));
                  }

                  final meals = snapshot.data!;
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: List.generate(meals.length, (index) {
                          final meal = meals[index];
                          final entryType = toBeginningOfSentenceCase(
                                  meal.entryType.name) ??
                              meal.entryType.name;
                          return Column(
                            children: [
                              _buildMealRow(
                                meal.recipe?.name ??
                                    meal.title ??
                                    l10n.unnamedMeal,
                                entryType,
                              ),
                              if (index < meals.length - 1)
                                const Divider(height: 24),
                            ],
                          );
                        }),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Section: Popluar Recipes
              _buildSectionTitle(l10n.popularRecipes.toUpperCase()),
              const SizedBox(height: 8),
              SizedBox(
                height: 150,
                child: FutureBuilder<List<Recipe>>(
                  future: _popularRecipesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('No popular recipes found.'));
                    }

                    final recipes = snapshot.data!;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        return _buildRecipeCard(recipe);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Section: Quick Actions
              _buildSectionTitle(l10n.quickActions.toUpperCase()),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showAddRecipeSheet(context);
                      },
                      icon: const Icon(Icons.post_add),
                      label: Text(l10n.recipe),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showAddShoppingListItemSheet(context);
                      },
                      icon: const Icon(Icons.add_shopping_cart),
                      label: Text(l10n.item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.cardColor,
                        foregroundColor: theme.textTheme.bodyLarge?.color,
                        elevation: 1,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showAddShoppingListSheet(context);
                      },
                      icon: const Icon(Icons.playlist_add),
                      label: Text(l10n.list),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.cardColor,
                        foregroundColor: theme.textTheme.bodyLarge?.color,
                        elevation: 1,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildMealRow(String title, String trailingText) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          trailingText,
          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                // TODO: Use recipe image once available
                color: Colors.orangeAccent, // Placeholder color
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.image, color: Colors.white54, size: 40),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            recipe.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
