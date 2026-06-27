import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mealique/core/utils/responsive_utils.dart';
import 'package:mealique/data/remote/api_exceptions.dart';
import 'package:mealique/data/sync/household_repository.dart';
import 'package:mealique/data/sync/mealplan_repository.dart';
import 'package:mealique/data/sync/recipe_repository.dart';
import 'package:mealique/data/sync/user_repository.dart';
import 'package:mealique/l10n/app_localizations.dart';
import 'package:mealique/models/mealplan_model.dart';
import 'package:mealique/models/recipes_model.dart';
import 'package:mealique/models/user_self_model.dart';
import 'package:mealique/ui/screens/recipe_search_screen.dart';
import 'package:mealique/ui/screens/recipe_detail_screen.dart';
import 'package:mealique/ui/widgets/dashboard_actions_menu.dart';
import 'package:mealique/ui/widgets/recipe_image.dart';
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
  final HouseholdRepository _householdRepository = HouseholdRepository();

  // Zustandsvariablen statt FutureBuilder – ermöglicht zweiphasiges Laden
  List<MealplanEntry>? _todaysMeals;
  List<Recipe>? _popularRecipes;
  UserSelf? _user;
  bool _loadingMeals = true;
  bool _loadingRecipes = true;
  Object? _mealsError;
  Object? _recipesError;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([
      _loadMeals(),
      _loadPopularRecipes(),
      _loadUser(),
    ]);
  }

  Future<void> _refreshAll() async {
    setState(() {
      _loadingMeals = true;
      _loadingRecipes = true;
      _mealsError = null;
      _recipesError = null;
    });
    await Future.wait([
      _loadMeals(skipCache: true),
      _loadPopularRecipes(skipCache: true),
      _loadUser(),
    ]);
  }

  Future<void> _loadMeals({bool skipCache = false}) async {
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);

    // Phase 1: Lokalen Cache sofort anzeigen
    if (!skipCache) {
      try {
        final cached = await _mealplanRepository.getMealplansLocalOnly(today, today);
        if (cached != null && mounted) {
          final meals = cached[today] ?? [];
          setState(() {
            _todaysMeals = _sortMeals(meals);
            _loadingMeals = false;
          });
        }
      } catch (_) {}
    }

    // Phase 2: API-Daten holen und Cache aktualisieren
    try {
      final mealsByDay = await _mealplanRepository.getMealplans(today, today);
      final meals = mealsByDay[today] ?? [];
      if (mounted) {
        setState(() {
          _todaysMeals = _sortMeals(meals);
          _loadingMeals = false;
          _mealsError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (_todaysMeals == null) _mealsError = e;
          _loadingMeals = false;
        });
      }
    }
  }

  Future<void> _loadPopularRecipes({bool skipCache = false}) async {
    // Phase 1: Lokalen Cache sofort anzeigen
    if (!skipCache) {
      try {
        final cached = await _recipeRepository.getRecipesLocalOnly();
        if (cached != null && cached.isNotEmpty && mounted) {
          setState(() {
            _popularRecipes = cached.take(5).toList();
            _loadingRecipes = false;
          });
        }
      } catch (_) {}
    }

    // Phase 2: API
    try {
      final recipes = await _recipeRepository.getRecipes(
          sort: 'rating', orderDirection: 'desc', perPage: 5);
      if (mounted) {
        setState(() {
          _popularRecipes = recipes;
          _loadingRecipes = false;
          _recipesError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (_popularRecipes == null) _recipesError = e;
          _loadingRecipes = false;
        });
      }
    }
  }

  Future<void> _loadUser() async {
    try {
      final user = await _userRepository.getSelfUser();
      if (mounted) setState(() => _user = user);
    } catch (_) {
      // Benutzername ist nicht kritisch – Fehler still ignorieren
    }
  }

  List<MealplanEntry> _sortMeals(List<MealplanEntry> meals) {
    final order = {
      PlanEntryType.breakfast: 0,
      PlanEntryType.lunch: 1,
      PlanEntryType.dinner: 2,
      PlanEntryType.side: 3,
      PlanEntryType.snack: 4,
      PlanEntryType.drink: 5,
      PlanEntryType.dessert: 6,
    };
    final sorted = List<MealplanEntry>.from(meals);
    sorted.sort((a, b) {
      final aOrder = order[a.entryType] ?? 99;
      final bOrder = order[b.entryType] ?? 99;
      return aOrder.compareTo(bOrder);
    });
    return sorted;
  }

  void _showAddRecipeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: AddRecipeForm(
          onAddRecipe: (recipeJson) async {
            // Pop immediately before any async gap so ctx stays valid
            Navigator.pop(ctx);
            final l10n = AppLocalizations.of(this.context)!;
            try {
              final data = Map<String, dynamic>.from(
                  jsonDecode(recipeJson) as Map);
              await _recipeRepository.createRecipe(data);
              if (!mounted) return;
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(content: Text(l10n.recipeCreated)),
              );
              setState(() {}); // refresh dashboard
            } on DioException catch (e) {
              debugPrint('DioException creating recipe: ${e.response?.statusCode} - ${e.response?.data}');
              if (!mounted) return;
              final detail = e.response?.data?['detail'] ?? e.message;
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(
                  content: Text('${l10n.error}: $detail'),
                  backgroundColor: Colors.red,
                ),
              );
            } catch (e) {
              debugPrint('Error creating recipe: $e');
              if (!mounted) return;
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(
                  content: Text('${l10n.error}: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
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
      builder: (ctx) => AddShoppingListItemForm(
        onAddItem: (item) async {
          // Pop immediately before any async gap so ctx stays valid
          Navigator.pop(ctx);
          final l10n = AppLocalizations.of(this.context)!;
          try {
            await _householdRepository.createShoppingItem(
              listId: item.listId,
              foodId: item.foodId,
              foodName: item.foodName,
              quantity: item.quantity.toDouble(),
              note: item.notes,
              unitId: item.unitId,
              categoryId: item.categoryId,
            );
            if (!mounted) return;
            ScaffoldMessenger.of(this.context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  content: Text(l10n.itemAddedSuccess(item.foodName)),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
          } on DioException catch (e) {
            final responseData = e.response?.data;
            debugPrint('API Error creating shopping item: ${e.response?.statusCode}, $responseData');
            if (!mounted) return;
            ScaffoldMessenger.of(this.context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  content: Text(l10n.errorAdding('${responseData?['detail'] ?? e.message}')),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
          } catch (e) {
            debugPrint('Error creating shopping item: $e');
            if (!mounted) return;
            ScaffoldMessenger.of(this.context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  content: Text(l10n.errorAdding(e.toString())),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
          }
        },
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
          onAddList: (listName) async {
            // Pop immediately before any async gap so ctx stays valid
            Navigator.pop(ctx);
            final l10n = AppLocalizations.of(this.context)!;
            try {
              await _householdRepository.createShoppingList(listName);
              if (!mounted) return;
              ScaffoldMessenger.of(this.context)
                ..clearSnackBars()
                ..showSnackBar(
                  SnackBar(
                    content: Text(l10n.listCreatedSuccess(listName)),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
            } catch (e) {
              debugPrint('Error creating shopping list: $e');
              if (!mounted) return;
              ScaffoldMessenger.of(this.context)
                ..clearSnackBars()
                ..showSnackBar(
                  SnackBar(
                    content: Text(l10n.errorCreating(e.toString())),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
            }
          },
        ),
      ),
    );
  }

  String _getGreeting(BuildContext context, String name) {
    final l10n = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.greetingGoodMorning(name);
    if (hour < 18) return l10n.greetingGoodDay(name);
    return l10n.greetingGoodEvening(name);
  }

  String _getGreetingNoName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.greetingGoodMorning('');
    if (hour < 18) return l10n.greetingGoodDay('');
    return l10n.greetingGoodEvening('');
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
      child: SingleChildScrollView(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);

    return Scaffold(
       appBar: AppBar(
        backgroundColor: const Color(0xFFE58325),
        foregroundColor: Colors.white,
        title: Text(l10n.home),
        actions: [
       DashboardActionsMenu(
            onRefresh: () => _refreshAll(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(horizontalPadding),
          child: isTablet
              ? _buildTabletLayout(context, l10n, theme)
              : _buildPhoneLayout(context, l10n, theme),
        ),
      ),
    );
  }

  /// Phone Layout: Single column layout
  Widget _buildPhoneLayout(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGreetingSection(context, l10n),
        const SizedBox(height: 16),
        _buildSearchField(context, l10n),
        const SizedBox(height: 24),
        _buildTodaySection(l10n),
        const SizedBox(height: 24),
        _buildPopularRecipesSection(l10n),
        const SizedBox(height: 24),
        _buildQuickActionsSection(l10n, theme),
      ],
    );
  }

  /// Tablet Layout: Two-column layout for better space utilization
  Widget _buildTabletLayout(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGreetingSection(context, l10n),
        const SizedBox(height: 16),
        _buildSearchField(context, l10n),
        const SizedBox(height: 24),
        // Two-column layout: Today + Quick Actions on left, Popular Recipes on right
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column: Today's Meals and Quick Actions
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTodaySection(l10n),
                  const SizedBox(height: 24),
                  _buildQuickActionsSection(l10n, theme),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Right column: Popular Recipes as grid
            Expanded(
              flex: 1,
              child: _buildPopularRecipesGridSection(l10n),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGreetingSection(BuildContext context, AppLocalizations l10n) {
    final name = _user?.fullName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name != null && name.isNotEmpty ? _getGreeting(context, name) : _getGreetingNoName(context),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.whatDoYouWantToCook,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context, AppLocalizations l10n) {
    return TextField(
      readOnly: true, // Prevent keyboard from appearing
      onTap: () {
        final screenHeight = MediaQuery.of(context).size.height;
        final topPadding = MediaQuery.of(context).padding.top;
        const appBarHeight = kToolbarHeight;

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          constraints: BoxConstraints(
            maxHeight: screenHeight - (topPadding + appBarHeight),
          ),
          builder: (context) => const RecipeSearchScreen(initialQuery: ''),
        );
      },
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: l10n.recipeSearch,
        hintStyle: TextStyle(color: const Color(0xFFE58325).withOpacity(0.6)),
        prefixIcon: const Icon(Icons.search, color: Color(0xFFE58325)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE58325), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE58325), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE58325), width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFFE58325).withOpacity(0.08),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
      ),
    );
  }

  Widget _buildTodaySection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.today.toUpperCase()),
        const SizedBox(height: 8),
        if (_loadingMeals && _todaysMeals == null)
          const Center(child: CircularProgressIndicator())
        else if (_mealsError != null && (_todaysMeals == null || _todaysMeals!.isEmpty))
          _buildErrorWidget(_mealsError!, () => _loadMeals(skipCache: true))
        else if (_todaysMeals == null || _todaysMeals!.isEmpty)
          Center(child: Text(l10n.noMealsPlanned))
        else
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: List.generate(_todaysMeals!.length, (index) {
                  final meal = _todaysMeals![index];
                  final entryType = toBeginningOfSentenceCase(meal.entryType.name);
                  return Column(
                    children: [
                      _buildMealRow(
                        meal.recipe?.name ?? meal.title ?? l10n.unnamedMeal,
                        entryType,
                      ),
                      if (index < _todaysMeals!.length - 1) const Divider(height: 24),
                    ],
                  );
                }),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPopularRecipesSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.popularRecipes.toUpperCase()),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: _buildRecipesContent(l10n, isGrid: false),
        ),
      ],
    );
  }

  Widget _buildRecipesContent(AppLocalizations l10n, {required bool isGrid}) {
    if (_loadingRecipes && _popularRecipes == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_recipesError != null && (_popularRecipes == null || _popularRecipes!.isEmpty)) {
      return _buildErrorWidget(_recipesError!, () => _loadPopularRecipes(skipCache: true));
    }
    if (_popularRecipes == null || _popularRecipes!.isEmpty) {
      return Center(child: Text(l10n.noPopularRecipesFound));
    }
    if (isGrid) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _popularRecipes!.length,
        itemBuilder: (context, index) => _buildRecipeGridCard(_popularRecipes![index]),
      );
    }
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _popularRecipes!.length,
      itemBuilder: (context, index) => _buildRecipeCard(_popularRecipes![index]),
    );
  }

  /// Tablet: Popular Recipes as Grid instead of horizontal list
  Widget _buildPopularRecipesGridSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.popularRecipes.toUpperCase()),
        const SizedBox(height: 8),
        _buildRecipesContent(l10n, isGrid: true),
      ],
    );
  }

  Widget _buildQuickActionsSection(AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          trailingText,
          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          builder: (context) => RecipeDetailScreen(recipeSlug: recipe.slug),
        );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: RecipeImage(
                  recipeId: recipe.id,
                  imageHint: recipe.image,
                  size: RecipeImageSize.min,
                  fit: BoxFit.cover,
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
      ),
    );
  }

  /// Tablet: Grid-style recipe card
  Widget _buildRecipeGridCard(Recipe recipe) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          builder: (context) => RecipeDetailScreen(recipeSlug: recipe.slug),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RecipeImage(
                recipeId: recipe.id,
                imageHint: recipe.image,
                size: RecipeImageSize.min,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                recipe.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
