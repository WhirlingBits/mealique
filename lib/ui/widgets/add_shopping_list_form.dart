import 'package:flutter/material.dart';

class AddShoppingListForm extends StatefulWidget {
  final Function(String) onAddList;

  const AddShoppingListForm({super.key, required this.onAddList});

  @override
  State<AddShoppingListForm> createState() => _AddShoppingListFormState();
}

class _AddShoppingListFormState extends State<AddShoppingListForm> {
  final _textController = TextEditingController();

  void _handleSubmit() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      widget.onAddList(text);
      _textController.clear();
    }
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
            padding: const EdgeInsets.all(16.0),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          labelText: 'Name der neuen Einkaufsliste...',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _handleSubmit(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Tooltip(
                      message: 'Einkaufsliste erstellen',
                      child: ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(16),
                          backgroundColor: const Color(0xFFE58325),
                          foregroundColor: Colors.white,
                        ),
                        child: const Icon(Icons.playlist_add),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
