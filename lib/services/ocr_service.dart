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

      return _parseRecipeFromText(recognizedText.text);
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

  /// Parst den erkannten Text und versucht, ein strukturiertes Rezept zu extrahieren.
  RecognizedRecipe _parseRecipeFromText(String rawText) {
    final lines = rawText.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    if (lines.isEmpty) {
      return RecognizedRecipe(
        rawText: rawText,
        suggestedName: '',
        suggestedIngredients: [],
        suggestedInstructions: [],
      );
    }

    // Heuristik: Erste Zeile ist oft der Rezeptname
    String suggestedName = '';
    List<String> ingredients = [];
    List<String> instructions = [];

    // Suche nach Abschnitts-Markern
    final ingredientMarkers = [
      'zutaten', 'ingredients', 'zutat', 'ingredient',
      'benötigt', 'einkaufsliste', 'was sie brauchen',
    ];
    final instructionMarkers = [
      'zubereitung', 'anleitung', 'instructions', 'steps',
      'schritte', 'so geht\'s', 'vorgehensweise', 'preparation',
    ];

    int ingredientStart = -1;
    int instructionStart = -1;

    for (int i = 0; i < lines.length; i++) {
      final lineLower = lines[i].toLowerCase();

      // Finde Zutaten-Abschnitt
      if (ingredientStart == -1) {
        for (final marker in ingredientMarkers) {
          if (lineLower.contains(marker)) {
            ingredientStart = i + 1;
            break;
          }
        }
      }

      // Finde Zubereitungs-Abschnitt
      if (instructionStart == -1) {
        for (final marker in instructionMarkers) {
          if (lineLower.contains(marker)) {
            instructionStart = i + 1;
            break;
          }
        }
      }
    }

    // Versuche den Namen zu extrahieren (erste Zeile vor Zutaten/Zubereitung)
    if (lines.isNotEmpty) {
      // Finde eine Zeile, die wie ein Titel aussieht
      for (int i = 0; i < lines.length && i < 5; i++) {
        final line = lines[i];
        final lineLower = line.toLowerCase();

        // Überspringe Marker-Zeilen
        bool isMarker = false;
        for (final marker in [...ingredientMarkers, ...instructionMarkers]) {
          if (lineLower.contains(marker)) {
            isMarker = true;
            break;
          }
        }

        if (!isMarker && line.length > 3 && line.length < 80) {
          // Prüfe ob es wie eine Zutat aussieht (hat Zahlen am Anfang)
          final isIngredientLike = RegExp(r'^\d+').hasMatch(line);
          if (!isIngredientLike) {
            suggestedName = line;
            break;
          }
        }
      }
    }

    // Extrahiere Zutaten
    if (ingredientStart > 0) {
      final end = instructionStart > ingredientStart
          ? instructionStart - 1
          : lines.length;

      for (int i = ingredientStart; i < end && i < lines.length; i++) {
        final line = lines[i];
        // Zutaten haben typischerweise Mengenangaben
        if (_looksLikeIngredient(line)) {
          ingredients.add(line);
        }
      }
    } else {
      // Fallback: Suche nach Zeilen, die wie Zutaten aussehen
      for (final line in lines) {
        if (_looksLikeIngredient(line)) {
          ingredients.add(line);
        }
      }
    }

    // Extrahiere Zubereitungsschritte
    if (instructionStart > 0) {
      for (int i = instructionStart; i < lines.length; i++) {
        final line = lines[i];
        if (line.length > 10) {
          // Entferne Nummerierung am Anfang
          final cleaned = line.replaceFirst(RegExp(r'^[\d]+[.):]\s*'), '');
          if (cleaned.isNotEmpty) {
            instructions.add(cleaned);
          }
        }
      }
    } else {
      // Fallback: Längere Zeilen ohne Mengenangaben sind wahrscheinlich Schritte
      for (final line in lines) {
        if (line.length > 30 && !_looksLikeIngredient(line)) {
          final cleaned = line.replaceFirst(RegExp(r'^[\d]+[.):]\s*'), '');
          if (cleaned.isNotEmpty && !instructions.contains(cleaned)) {
            instructions.add(cleaned);
          }
        }
      }
    }

    return RecognizedRecipe(
      rawText: rawText,
      suggestedName: suggestedName,
      suggestedIngredients: ingredients,
      suggestedInstructions: instructions,
    );
  }

  /// Prüft, ob eine Zeile wie eine Zutat aussieht.
  bool _looksLikeIngredient(String line) {
    // Zutaten haben oft: Mengenangaben (Zahlen), Einheiten, kurze Länge
    if (line.length < 5 || line.length > 80) return false;

    // Hat eine Zahl am Anfang oder enthält typische Einheiten
    final hasQuantity = RegExp(r'\d').hasMatch(line);
    final hasUnit = RegExp(
      r'\b(g|kg|ml|l|EL|TL|Stück|Prise|Bund|Dose|Packung|cup|tbsp|tsp|oz|lb)\b',
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

