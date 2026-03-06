import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class AddShoppingListForm extends StatefulWidget {
  final Function(String) onAddList;

  const AddShoppingListForm({super.key, required this.onAddList});

  @override
  State<AddShoppingListForm> createState() => _AddShoppingListFormState();
}

class _AddShoppingListFormState extends State<AddShoppingListForm> {
  final _textController = TextEditingController();

  // Inline toast state
  String? _toastMessage;
  Color? _toastColor;

  void _showToast(String message, {Color? backgroundColor}) {
    if (!mounted) return;
    setState(() {
      _toastMessage = message;
      _toastColor = backgroundColor ?? Colors.grey[800];
    });
    Future.delayed(
      Duration(seconds: backgroundColor == Colors.red ? 4 : 2),
      () {
        if (mounted) setState(() => _toastMessage = null);
      },
    );
  }

  void _handleSubmit() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      _showToast(l10n.pleaseEnterName);
      return;
    }
    widget.onAddList(text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
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
                _buildToastBanner(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          labelText: l10n.newShoppingListNameHint,
                          border: const OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _handleSubmit(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Tooltip(
                      message: l10n.createShoppingList,
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

  Widget _buildToastBanner() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => SizeTransition(
        sizeFactor: animation,
        axisAlignment: -1,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: _toastMessage != null
          ? Container(
              key: ValueKey(_toastMessage),
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _toastColor ?? Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _toastColor == Colors.green
                        ? Icons.check_circle
                        : _toastColor == Colors.red
                            ? Icons.error
                            : Icons.info,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _toastMessage!,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _toastMessage = null),
                    child: const Icon(Icons.close, color: Colors.white70, size: 16),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
