import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Dummy models for demonstration. Replace with your actual data models.
class ShoppingList {
  final String id;
  final String name;
  ShoppingList({required this.id, required this.name});
}

class FoodItem {
  final String id;
  final String name;
  FoodItem({required this.id, required this.name});
}

class Unit {
  final String id;
  final String name;
  Unit({required this.id, required this.name});
}

class Category {
  final String id;
  final String name;
  Category({required this.id, required this.name});
}

// Data class to hold all the information for a new item.
class NewShoppingItem {
  final String listId;
  final String foodId;
  final int quantity;
  final String unitId;
  final String categoryId;
  final String? notes;

  NewShoppingItem({
    required this.listId,
    required this.foodId,
    required this.quantity,
    required this.unitId,
    required this.categoryId,
    this.notes,
  });
}

class AddShoppingListItemForm extends StatefulWidget {
  final Function(NewShoppingItem item) onAddItem;
  final String? shoppingListId;

  const AddShoppingListItemForm({
    super.key,
    required this.onAddItem,
    this.shoppingListId,
  });

  @override
  State<AddShoppingListItemForm> createState() =>
      _AddShoppingListItemFormState();
}

class _AddShoppingListItemFormState extends State<AddShoppingListItemForm> {
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedListId;
  String? _selectedFoodId;
  String? _selectedUnitId;
  String? _selectedCategoryId;

  // --- Dummy Data: Replace with actual data fetching ---
  final List<ShoppingList> _availableLists = [
    ShoppingList(id: '1', name: 'Wocheneinkauf'),
    ShoppingList(id: '2', name: 'Party'),
  ];
  final List<FoodItem> _availableFoods = [
    FoodItem(id: 'f1', name: 'Tomaten'),
    FoodItem(id: 'f2', name: 'Milch'),
    FoodItem(id: 'f3', name: 'Brot'),
  ];
  final List<Unit> _availableUnits = [
    Unit(id: 'u1', name: 'Stück'),
    Unit(id: 'u2', name: 'g'),
    Unit(id: 'u3', name: 'L'),
  ];
  final List<Category> _availableCategories = [
    Category(id: 'c1', name: 'Obst & Gemüse'),
    Category(id: 'c2', name: 'Milchprodukte'),
    Category(id: 'c3', name: 'Backwaren'),
  ];
  // --- End of Dummy Data ---

  @override
  void initState() {
    super.initState();
    _selectedListId = widget.shoppingListId;
  }

  void _handleSubmit() {
    final quantity = int.tryParse(_quantityController.text);
    final notes = _notesController.text.trim();

    if (quantity == null ||
        quantity <= 0 ||
        _selectedListId == null ||
        _selectedFoodId == null ||
        _selectedUnitId == null ||
        _selectedCategoryId == null) {
      // Optional: Show an error message
      return;
    }

    final newItem = NewShoppingItem(
      listId: _selectedListId!,
      foodId: _selectedFoodId!,
      quantity: quantity,
      unitId: _selectedUnitId!,
      categoryId: _selectedCategoryId!,
      notes: notes.isNotEmpty ? notes : null,
    );

    widget.onAddItem(newItem);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: const Color(0xFFE58325),
        ),
      ),
      child: Material(
        elevation: 20.0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title
                Text(
                  'Neues Item hinzufügen',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // Scrollable Form Fields
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (widget.shoppingListId == null &&
                            _availableLists.isNotEmpty)
                          _buildAutocomplete<ShoppingList>(
                            label: 'Einkaufsliste wählen',
                            options: _availableLists,
                            onSelected: (list) =>
                                setState(() => _selectedListId = list.id),
                          ),
                        const SizedBox(height: 12),
                        if (_availableFoods.isNotEmpty)
                          _buildAutocomplete<FoodItem>(
                            label: 'Lebensmittel',
                            options: _availableFoods,
                            onSelected: (food) =>
                                setState(() => _selectedFoodId = food.id),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: _quantityController,
                                decoration: const InputDecoration(
                                    labelText: 'Anzahl',
                                    border: OutlineInputBorder()),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (_availableUnits.isNotEmpty)
                              Expanded(
                                flex: 3,
                                child: _buildAutocomplete<Unit>(
                                  label: 'Einheit',
                                  options: _availableUnits,
                                  onSelected: (unit) =>
                                      setState(() => _selectedUnitId = unit.id),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_availableCategories.isNotEmpty)
                          _buildAutocomplete<Category>(
                            label: 'Kategorie',
                            options: _availableCategories,
                            onSelected: (cat) =>
                                setState(() => _selectedCategoryId = cat.id),
                          ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _notesController,
                          decoration: const InputDecoration(
                              labelText: 'Notizen (optional)',
                              border: OutlineInputBorder()),
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Submit Button
                Align(
                  alignment: Alignment.centerRight,
                  child: Tooltip(
                    message: 'Item hinzufügen',
                    child: ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                        backgroundColor: const Color(0xFFE58325),
                        foregroundColor: Colors.white,
                      ),
                      child: const Icon(Icons.add_shopping_cart),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Generic Autocomplete Widget Builder
  Widget _buildAutocomplete<T extends Object>({
    required String label,
    required List<T> options,
    required ValueChanged<T> onSelected,
  }) {
    return Autocomplete<T>(
      displayStringForOption: (option) => (option as dynamic).name,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return options;
        }
        return options.where((T option) {
          final name = (option as dynamic).name as String;
          return name
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: onSelected,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final T option = options.elementAt(index);
                  return InkWell(
                    onTap: () {
                      onSelected(option);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text((option as dynamic).name),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
