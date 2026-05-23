import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Service für die Texterkennung (OCR) von Rezeptbildern.
class OcrService {
  late final TextRecognizer _textRecognizer;

  OcrService() {
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  }

  /// Erkennt Text aus einem Bild und gibt das Ergebnis zurück.
  Future<RecognizedRecipe> recognizeRecipeFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      debugPrint('OCR raw text:\n${recognizedText.text}');
      return _parseRecipe(recognizedText);
    } catch (e) {
      debugPrint('OCR error: $e');
      return RecognizedRecipe(
        rawText: '',
        suggestedName: '',
        suggestedIngredients: [],
        suggestedInstructions: [],
      );
    }
  }

  /// Parst den erkannten Text mithilfe der ML Kit Block-Struktur.
  RecognizedRecipe _parseRecipe(RecognizedText recognizedText) {
    final rawText = recognizedText.text;

    // Alle Zeilen aus den Blöcken in Dokumentreihenfolge extrahieren.
    // ML Kit liefert Blöcke bereits in Leserichtung (oben → unten, links → rechts).
    final allLines = <String>[];
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final text = line.text.trim();
        if (text.isNotEmpty) allLines.add(text);
      }
    }

    if (allLines.isEmpty) {
      return RecognizedRecipe(
        rawText: rawText,
        suggestedName: '',
        suggestedIngredients: [],
        suggestedInstructions: [],
      );
    }

    // Abschnitts-Marker (DE + EN)
    const ingredientMarkers = [
      'zutaten', 'ingredients', 'zutat', 'ingredient',
      'benötigt', 'einkaufsliste', 'was sie brauchen',
      'für den teig', 'für die sauce', 'für die soße',
      'für den belag', 'für die füllung',
    ];
    const instructionMarkers = [
      'zubereitung', 'anleitung', 'instructions', 'steps',
      'schritte', "so geht's", 'vorgehensweise', 'preparation',
      "so wird's gemacht", 'zubereiten', 'so machst du',
    ];

    int ingredientStart = -1;
    int instructionStart = -1;

    for (int i = 0; i < allLines.length; i++) {
      final lineLower = allLines[i].toLowerCase();

      if (ingredientStart == -1) {
        for (final marker in ingredientMarkers) {
          if (lineLower.contains(marker)) {
            ingredientStart = i + 1;
            break;
          }
        }
      }

      if (instructionStart == -1) {
        for (final marker in instructionMarkers) {
          if (lineLower.contains(marker)) {
            instructionStart = i + 1;
            break;
          }
        }
      }
    }

    // Titel: erste Zeile, die kein Marker ist und nicht wie eine Zutat aussieht.
    String suggestedName = '';
    for (int i = 0; i < allLines.length && i < 6; i++) {
      final line = allLines[i];
      final lineLower = line.toLowerCase();

      bool isMarker = false;
      for (final m in [...ingredientMarkers, ...instructionMarkers]) {
        if (lineLower.contains(m)) {
          isMarker = true;
          break;
        }
      }

      if (!isMarker && line.length > 3 && line.length < 100) {
        final startsWithDigit = RegExp(r'^\d+').hasMatch(line);
        if (!startsWithDigit) {
          suggestedName = line;
          break;
        }
      }
    }

    // ── Zutaten ──────────────────────────────────────────────────────────────
    final List<String> ingredients = [];
    if (ingredientStart > 0) {
      final end = (instructionStart > ingredientStart && instructionStart > 0)
          ? instructionStart - 1
          : allLines.length;

      for (int i = ingredientStart; i < end && i < allLines.length; i++) {
        final line = allLines[i];
        if (line.length < 3) continue;
        // Abschnitts-Marker überspringen
        bool isMarker = false;
        for (final m in [...ingredientMarkers, ...instructionMarkers]) {
          if (line.toLowerCase().contains(m)) {
            isMarker = true;
            break;
          }
        }
        if (!isMarker) ingredients.add(line);
      }
    } else {
      // Fallback: Zeilen, die wie Zutaten aussehen
      for (final line in allLines) {
        if (_looksLikeIngredient(line)) {
          ingredients.add(line);
        }
      }
    }

    // ── Zubereitungsschritte ──────────────────────────────────────────────────
    final List<String> instructions = [];
    if (instructionStart > 0) {
      final raw = <String>[];
      for (int i = instructionStart; i < allLines.length; i++) {
        final line = allLines[i];
        if (line.length > 5) {
          final cleaned = line.replaceFirst(RegExp(r'^[\d]+[.):\-]\s*'), '');
          if (cleaned.isNotEmpty) raw.add(cleaned);
        }
      }
      instructions.addAll(_mergeInstructionLines(raw));
    } else {
      // Fallback: längere Zeilen ohne Mengenangaben
      final raw = <String>[];
      for (final line in allLines) {
        if (line.length > 30 && !_looksLikeIngredient(line)) {
          final cleaned = line.replaceFirst(RegExp(r'^[\d]+[.):\-]\s*'), '');
          if (cleaned.isNotEmpty && !raw.contains(cleaned)) raw.add(cleaned);
        }
      }
      instructions.addAll(_mergeInstructionLines(raw));
    }

    return RecognizedRecipe(
      rawText: rawText,
      suggestedName: suggestedName,
      suggestedIngredients: ingredients,
      suggestedInstructions: instructions,
    );
  }

  /// Kurze Folgezeilen werden mit dem vorherigen Schritt zusammengeführt.
  List<String> _mergeInstructionLines(List<String> lines) {
    if (lines.isEmpty) return lines;
    final merged = <String>[];
    for (final line in lines) {
      if (merged.isEmpty) {
        merged.add(line);
      } else {
        final prev = merged.last;
        final endsWithSentence =
            prev.endsWith('.') || prev.endsWith('!') || prev.endsWith('?');
        // Sehr kurze Zeile ohne Satzende → anhängen
        if (!endsWithSentence && line.length < 25) {
          merged[merged.length - 1] = '$prev $line';
        } else {
          merged.add(line);
        }
      }
    }
    return merged;
  }

  /// Prüft, ob eine Zeile wie eine Zutat aussieht.
  bool _looksLikeIngredient(String line) {
    if (line.length < 3 || line.length > 100) return false;

    final hasQuantity = RegExp(r'\d').hasMatch(line);
    final hasUnit = RegExp(
      r'\b(g|kg|ml|l|cl|dl|mg|EL|TL|Stück|Stk|Prise|Bund|Dose|Packung|Pkg|Becher|Glas|Tasse|'
      r'cup|tbsp|tsp|oz|lb|bunch|can|piece|handful|Handvoll|'
      r'Scheibe|Scheiben|Zehe|Zehen|Blatt|Blätter|'
      r'Esslöffel|Teelöffel|Liter|Gramm|Kilogramm|Milliliter)\b',
      caseSensitive: false,
    ).hasMatch(line);

    return hasQuantity || hasUnit;
  }

  /// Gibt die Ressourcen frei.
  void dispose() {
    _textRecognizer.close();
  }
}

/// Datenklasse für ein erkanntes Rezept.
class RecognizedRecipe {
  final String rawText;
  final String suggestedName;
  final List<String> suggestedIngredients;
  final List<String> suggestedInstructions;

  RecognizedRecipe({
    required this.rawText,
    required this.suggestedName,
    required this.suggestedIngredients,
    required this.suggestedInstructions,
  });

  bool get hasContent =>
      suggestedName.isNotEmpty ||
      suggestedIngredients.isNotEmpty ||
      suggestedInstructions.isNotEmpty;
}
