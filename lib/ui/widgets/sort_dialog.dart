import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class SortOption {
  final String field;
  final String label;

  const SortOption({required this.field, required this.label});
}

class SortResult {
  final String field;
  final String direction; // 'asc' or 'desc'

  const SortResult({required this.field, required this.direction});
}

Future<SortResult?> showSortDialog({
  required BuildContext context,
  required List<SortOption> options,
  String? currentField,
  String currentDirection = 'asc',
}) async {
  final l10n = AppLocalizations.of(context)!;
  String selectedField = currentField ?? options.first.field;
  String selectedDirection = currentDirection;

  return showDialog<SortResult>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(l10n.sortBy),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sort field selection
                ...options.map((option) => RadioListTile<String>(
                      title: Text(option.label),
                      value: option.field,
                      groupValue: selectedField,
                      activeColor: const Color(0xFFE58325),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedField = value!;
                        });
                      },
                    )),
                const Divider(),
                // Sort direction
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
                  child: Text(
                    l10n.sortDirection,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                RadioListTile<String>(
                  title: Row(
                    children: [
                      const Icon(Icons.arrow_upward, size: 18),
                      const SizedBox(width: 8),
                      Text(l10n.ascending),
                    ],
                  ),
                  value: 'asc',
                  groupValue: selectedDirection,
                  activeColor: const Color(0xFFE58325),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedDirection = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: Row(
                    children: [
                      const Icon(Icons.arrow_downward, size: 18),
                      const SizedBox(width: 8),
                      Text(l10n.descending),
                    ],
                  ),
                  value: 'desc',
                  groupValue: selectedDirection,
                  activeColor: const Color(0xFFE58325),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedDirection = value!;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(
                  SortResult(field: selectedField, direction: selectedDirection),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE58325),
                ),
                child: Text(l10n.sort),
              ),
            ],
          );
        },
      );
    },
  );
}

