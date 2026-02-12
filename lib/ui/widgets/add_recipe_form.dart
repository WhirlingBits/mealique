import 'dart:convert';
import 'package:flutter/material.dart';

class AddRecipeForm extends StatefulWidget {
  final Function(String) onAddRecipe;

  const AddRecipeForm({super.key, required this.onAddRecipe});

  @override
  State<AddRecipeForm> createState() => _AddRecipeFormState();
}

class _AddRecipeFormState extends State<AddRecipeForm> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _servingsController = TextEditingController();
  final _timeController = TextEditingController();

  bool _showDetails = false;
  final Color _accent = const Color(0xFFE58325);

  void _submitName() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _showDetails = true);
    // Fokus auf erstes Feld der Details setzen
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _submitAll() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final details = {
      'name': name,
      'description': _descController.text.trim(),
      'ingredients': _ingredientsController.text.trim(),
      'servings': _servingsController.text.trim(),
      'time': _timeController.text.trim(),
    };
    widget.onAddRecipe(jsonEncode(details));
    _clearAll();
  }

  void _clearAll() {
    _nameController.clear();
    _descController.clear();
    _ingredientsController.clear();
    _servingsController.clear();
    _timeController.clear();
    setState(() => _showDetails = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(primary: _accent),
      ),
      child: Material(
        elevation: 20.0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimatedCrossFade(
              firstChild: _buildNameStep(),
              secondChild: _buildDetailStep(),
              crossFadeState: _showDetails ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
              firstCurve: Curves.easeOut,
              secondCurve: Curves.easeIn,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name des neuen Rezepts...',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _submitName(),
              ),
            ),
            const SizedBox(width: 16),
            Tooltip(
              message: 'Weiter zu Details',
              child: ElevatedButton(
                onPressed: _submitName,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                ),
                child: const Icon(Icons.arrow_forward),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailStep() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Beschreibung (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ingredientsController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Zutaten (je Zeile ein Eintrag)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _servingsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Portionen',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _timeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Zubereitungszeit (Min)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _showDetails = false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.grey[400]!),
                  ),
                  child: const Text('Zurück'),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _submitAll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
                child: const Text('Fertig'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _ingredientsController.dispose();
    _servingsController.dispose();
    _timeController.dispose();
    super.dispose();
  }
}

