import 'package:flutter/material.dart';
import 'package:mealique/data/remote/labels_api.dart';
import 'package:mealique/data/sync/recipe_repository.dart';
import 'package:mealique/models/food_model.dart';
import 'package:mealique/models/shopping_item_model.dart';
import '../../l10n/app_localizations.dart';

/// Screen zur Verwaltung von Lebensmitteln und deren Kategorie-Zuordnung.
/// Wenn ein Food einer Kategorie zugeordnet ist, erbt jedes Shopping-Item
/// automatisch diese Kategorie.
class FoodLabelsScreen extends StatefulWidget {
  const FoodLabelsScreen({super.key});

  @override
  State<FoodLabelsScreen> createState() => _FoodLabelsScreenState();
}

class _FoodLabelsScreenState extends State<FoodLabelsScreen> {
  final RecipeRepository _recipeRepo = RecipeRepository();
  final LabelsApi _labelsApi = LabelsApi();

  List<Food>? _foods;
  List<ShoppingItemLabel>? _labels;
  bool _loading = true;
  String? _error;
  String _searchQuery = '';

  static const Color _accent = Color(0xFFE58325);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _recipeRepo.getFoods(),
        _labelsApi.getLabels(),
      ]);

      if (mounted) {
        setState(() {
          _foods = results[0] as List<Food>;
          _labels = results[1] as List<ShoppingItemLabel>;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  List<Food> get _filteredFoods {
    if (_foods == null) return [];
    if (_searchQuery.isEmpty) return _foods!;

    final query = _searchQuery.toLowerCase();
    return _foods!.where((f) => f.name.toLowerCase().contains(query)).toList();
  }

  Future<void> _assignLabel(Food food, String? labelId) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      await _recipeRepo.updateFoodLabel(food.id, labelId);

      // Update local state
      final index = _foods!.indexWhere((f) => f.id == food.id);
      if (index != -1) {
        final updatedLabel = labelId != null
            ? _labels!.where((l) => l.id == labelId).firstOrNull
            : null;

        // Create updated food with new label
        setState(() {
          _foods![index] = Food(
            id: food.id,
            name: food.name,
            pluralName: food.pluralName,
            description: food.description,
            extras: food.extras,
            labelId: labelId,
            aliases: food.aliases,
            householdsWithIngredientFood: food.householdsWithIngredientFood,
            label: updatedLabel,
            createdAt: food.createdAt,
            updatedAt: food.updatedAt,
          );
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.changesSaved),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Color _parseColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty) return Colors.grey;
    try {
      final hex = colorStr.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        title: Text(l10n.foodLabels),
      ),
      body: Column(
        children: [
          // Info-Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.blue.withValues(alpha: 0.1),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.foodLabelsInfo,
                    style: const TextStyle(fontSize: 13, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),

          // Suchfeld
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.searchFood,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Liste
          Expanded(child: _buildBody(l10n)),
        ],
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: Text(l10n.tryAgain),
            ),
          ],
        ),
      );
    }

    final foods = _filteredFoods;

    if (foods.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isEmpty ? l10n.noFoodsFound : l10n.noResultsFound,
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
        itemCount: foods.length,
        itemBuilder: (context, index) {
          final food = foods[index];
          return _buildFoodTile(food, l10n);
        },
      ),
    );
  }

  Widget _buildFoodTile(Food food, AppLocalizations l10n) {
    final currentLabel = food.label ??
        (_labels != null && food.labelId != null
            ? _labels!.where((l) => l.id == food.labelId).firstOrNull
            : null);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: currentLabel != null
            ? Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _parseColor(currentLabel.color),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.restaurant, color: Colors.white, size: 20),
              )
            : Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.restaurant, color: Colors.grey[400], size: 20),
              ),
        title: Text(
          food.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          currentLabel?.name ?? l10n.noCategory,
          style: TextStyle(
            color: currentLabel != null ? _parseColor(currentLabel.color) : Colors.grey,
            fontSize: 13,
          ),
        ),
        trailing: PopupMenuButton<String?>(
          icon: const Icon(Icons.arrow_drop_down),
          tooltip: l10n.selectCategory,
          onSelected: (labelId) => _assignLabel(food, labelId),
          itemBuilder: (context) => [
            PopupMenuItem<String?>(
              value: null,
              child: Row(
                children: [
                  Icon(Icons.clear, color: Colors.grey[400], size: 20),
                  const SizedBox(width: 8),
                  Text('— ${l10n.noCategory}'),
                ],
              ),
            ),
            if (_labels != null)
              ..._labels!.map((label) => PopupMenuItem<String?>(
                    value: label.id,
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _parseColor(label.color),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(label.name),
                        if (food.labelId == label.id) ...[
                          const Spacer(),
                          const Icon(Icons.check, color: Colors.green, size: 18),
                        ],
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

