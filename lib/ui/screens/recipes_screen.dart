import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mealique/core/utils/responsive_utils.dart';
import 'package:mealique/data/remote/api_exceptions.dart';
import 'package:mealique/ui/screens/edit_recipe_screen.dart';
import 'package:mealique/ui/screens/recipe_detail_screen.dart';
import 'package:mealique/ui/widgets/recipe_actions_menu.dart';
import 'package:mealique/ui/widgets/recipe_image.dart';
import 'package:mealique/ui/widgets/sort_dialog.dart';
import 'package:provider/provider.dart';
import '../../data/sync/recipe_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/recipes_model.dart';
import '../../providers/settings_provider.dart';
import '../widgets/add_recipe_form.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final RecipeRepository _recipeRepository = RecipeRepository();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  // Pagination
  List<Recipe> _recipes = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _initialLoading = true;
  Object? _error;
  static const int _perPage = 20;

  String? _sortField;
  String _sortDirection = 'asc';

  // Lokale Favoriten-Overrides: slug → isFavorite
  final Map<String, bool> _favoriteOverrides = {};
  final Set<String> _favoriteLoading = {};

  static const _accent = Color(0xFFE58325);

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _sortField = settings.recipeSortField;
    _sortDirection = settings.recipeSortDirection;
    _loadRecipes();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _resetAndLoad();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreRecipes();
    }
  }

  void _resetAndLoad() {
    setState(() {
      _recipes = [];
      _currentPage = 1;
      _hasMore = true;
      _error = null;
      _initialLoading = true;
    });
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final newRecipes = await _recipeRepository.getRecipes(
        page: _currentPage,
        perPage: _perPage,
        sort: _sortField,
        orderDirection: _sortDirection,
        searchQuery: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _recipes.addAll(newRecipes);
          _hasMore = newRecipes.length >= _perPage;
          _isLoading = false;
          _initialLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _isLoading = false;
          _initialLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreRecipes() async {
    if (_isLoading || !_hasMore) return;
    _currentPage++;
    await _loadRecipes();
  }

  void _refreshRecipes() {
    _resetAndLoad();
  }

  // ─── Favoriten ──────────────────────────────────────────────────────────

  bool _isFavorite(Recipe recipe) =>
      _favoriteOverrides[recipe.slug] ?? recipe.isFavorite;

  Future<void> _toggleFavorite(Recipe recipe) async {
    if (_favoriteLoading.contains(recipe.slug)) return;
    final current = _isFavorite(recipe);
    final newValue = !current;

    setState(() {
      _favoriteOverrides[recipe.slug] = newValue;
      _favoriteLoading.add(recipe.slug);
    });

    try {
      await _recipeRepository.setFavorite(recipe.slug, isFavorite: newValue);
    } catch (e) {
      if (mounted) {
        setState(() => _favoriteOverrides[recipe.slug] = current);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.errorUpdating(e.toString())),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _favoriteLoading.remove(recipe.slug));
    }
  }

  // ─── Edit / Delete ───────────────────────────────────────────────────────

  Future<void> _editRecipe(Recipe recipe) async {
    try {
      final fullRecipe = await _recipeRepository.getRecipe(recipe.slug);
      if (!mounted) return;
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => EditRecipeScreen(recipe: fullRecipe)),
      );
      if (result == true) _refreshRecipes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.errorUpdating(e.toString())),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<void> _deleteRecipe(Recipe recipe) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteRecipe),
        content: Text(l10n.confirmDeleteRecipe),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.cancel)),
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
        _refreshRecipes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.itemDeletedSuccess(recipe.name)),
            backgroundColor: Colors.green,
          ));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.errorDeleting(e.toString())),
            backgroundColor: Colors.red,
          ));
        }
      }
    }
  }

  // ─── Sort / Add ─────────────────────────────────────────────────────────

  void _showSortDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showSortDialog(
      context: context,
      options: [
        SortOption(field: 'name', label: l10n.sortByName),
        SortOption(field: 'created_at', label: l10n.sortByDateCreated),
        SortOption(field: 'update_at', label: l10n.sortByDateUpdated),
        SortOption(field: 'rating', label: l10n.sortByRating),
        SortOption(field: 'total_time', label: l10n.sortByPrepTime),
      ],
      currentField: _sortField,
      currentDirection: _sortDirection,
    );
    if (result != null) {
      _sortField = result.field;
      _sortDirection = result.direction;
      Provider.of<SettingsProvider>(context, listen: false)
          .setRecipeSort(result.field, result.direction);
      _refreshRecipes();
    }
  }

  void _showAddRecipeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: AddRecipeForm(
          onAddRecipe: (recipeJson) async {
            Navigator.pop(ctx);
            final l10n = AppLocalizations.of(context)!;
            try {
              final data = Map<String, dynamic>.from(jsonDecode(recipeJson) as Map);
              await _recipeRepository.createRecipe(data);
              if (mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(l10n.recipeCreated)));
                _refreshRecipes();
              }
            } on DioException catch (e) {
              if (mounted) {
                final detail = e.response?.data?['detail'] ?? e.message;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('${l10n.error}: $detail'),
                  backgroundColor: Colors.red,
                ));
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('${l10n.error}: $e'),
                  backgroundColor: Colors.red,
                ));
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildRecipeGrid(AppLocalizations l10n) {
    // Initial loading
    if (_initialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (_error != null && _recipes.isEmpty) {
      return _buildErrorWidget(_error!, _refreshRecipes);
    }

    // Empty state
    if (_recipes.isEmpty) {
      return Center(child: Text(l10n.noRecipesFound));
    }

    // Recipe grid with infinite scroll
    return RefreshIndicator(
      onRefresh: () async => _refreshRecipes(),
      child: SlidableAutoCloseBehavior(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Adaptive grid columns based on screen width
            final crossAxisCount = ResponsiveUtils.getGridCrossAxisCount(context, minColumns: 2);
            // Adjust aspect ratio for more columns to prevent too small cards
            final aspectRatio = crossAxisCount > 3 ? 0.85 : 0.8;

            return GridView.builder(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(
                ResponsiveUtils.getHorizontalPadding(context),
                8,
                ResponsiveUtils.getHorizontalPadding(context),
                80,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: aspectRatio,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _recipes.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                // Loading indicator at the end
                if (index >= _recipes.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return _buildRecipeCard(context, _recipes[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorWidget(Object error, VoidCallback onRetry) {
    final l10n = AppLocalizations.of(context)!;
    String msg;
    if (error is DioException && error.error is ApiException) {
      final e = error.error as ApiException;
      if (e is NetworkException) {
        msg = l10n.checkInternetConnection;
      } else if (e is ServerException) {
        msg = l10n.serverError;
      } else {
        msg = e.message;
      }
    } else {
      msg = l10n.unexpectedError;
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(msg, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: Text(l10n.tryAgain)),
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
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        title: Text(l10n.recipes),
        actions: [
          RecipeActionsMenu(
            onAddRecipe: () => _showAddRecipeSheet(context),
            onSort: _showSortDialog,
            onRefresh: _refreshRecipes,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Suchzeile ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.search,
                        hintStyle:
                            TextStyle(color: _accent.withValues(alpha: 0.6)),
                        prefixIcon: const Icon(Icons.search, color: _accent),
                        suffixIcon: ListenableBuilder(
                          listenable: _searchController,
                          builder: (_, __) =>
                              _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear,
                                          size: 18, color: Colors.grey),
                                      onPressed: () {
                                        _searchController.clear();
                                        _resetAndLoad();
                                      },
                                    )
                                  : const SizedBox.shrink(),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: _accent, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: _accent, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: _accent, width: 2),
                        ),
                        filled: true,
                        fillColor: _accent.withValues(alpha: 0.08),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Sortier-Button – öffnet Sort-Dialog
                  Tooltip(
                    message: l10n.sort,
                    child: InkWell(
                      onTap: _showSortDialog,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          border: Border.all(color: _accent, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                          color: _accent.withValues(alpha: 0.08),
                        ),
                        child: const Icon(Icons.sort, color: _accent),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Rezept-Grid ──────────────────────────────────────────
            Expanded(
              child: _buildRecipeGrid(l10n),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecipeSheet(context),
        tooltip: l10n.addRecipe,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, Recipe recipe) {
    final fav = _isFavorite(recipe);
    final favBusy = _favoriteLoading.contains(recipe.slug);

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
              onPressed: (_) => _editRecipe(recipe),
              backgroundColor: _accent,
              foregroundColor: Colors.white,
              icon: Icons.edit,
            ),
            SlidableAction(
              flex: 1,
              onPressed: (_) => _deleteRecipe(recipe),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
            ),
          ],
        ),
        child: Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: InkWell(
            onTap: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: Colors.transparent,
                builder: (_) =>
                    RecipeDetailScreen(recipeSlug: recipe.slug),
              );
              // Favoriten-Status nach Schließen des Detail-Screens sync.
              if (mounted) {
                try {
                  final updated = await _recipeRepository
                      .getFavoriteStatus(recipe.slug);
                  if (mounted) {
                    setState(
                        () => _favoriteOverrides[recipe.slug] = updated);
                  }
                } catch (_) {}
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Bild + Herz ──────────────────────────────────────
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      RecipeImage(
                        recipeId: recipe.id,
                        imageHint: recipe.image,
                        size: RecipeImageSize.min,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Material(
                          color: Colors.black26,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => _toggleFavorite(recipe),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: favBusy
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(
                                      fav
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 18,
                                      color: fav
                                          ? Colors.red[300]
                                          : Colors.white,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Rezept-Infos ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 13, color: Colors.grey),
                          const SizedBox(width: 3),
                          Text(
                            recipe.totalTime ?? '–',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      if (recipe.rating > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              i < recipe.rating
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              size: 14,
                              color: i < recipe.rating
                                  ? Colors.amber
                                  : Colors.grey[300],
                            ),
                          ),
                        ),
                      ],
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
