import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealique/data/sync/recipe_repository.dart';
import 'package:mealique/services/ocr_service.dart';
import '../../l10n/app_localizations.dart';

/// Screen zum Importieren von Rezepten über Foto/OCR.
class RecipeImportScreen extends StatefulWidget {
  const RecipeImportScreen({super.key});

  @override
  State<RecipeImportScreen> createState() => _RecipeImportScreenState();
}

class _RecipeImportScreenState extends State<RecipeImportScreen> {
  static const _accent = Color(0xFFE58325);

  final ImagePicker _picker = ImagePicker();
  final OcrService _ocrService = OcrService();
  final RecipeRepository _recipeRepository = RecipeRepository();

  File? _selectedImage;
  RecognizedRecipe? _recognizedRecipe;
  bool _isProcessing = false;
  bool _isSaving = false;

  // Bearbeitbare Felder
  final _nameController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();

  @override
  void dispose() {
    _ocrService.dispose();
    _nameController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _recognizedRecipe = null;
        });
        await _processImage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    setState(() => _isProcessing = true);

    try {
      final result = await _ocrService.recognizeRecipeFromImage(_selectedImage!);

      if (mounted) {
        setState(() {
          _recognizedRecipe = result;
          _nameController.text = result.suggestedName;
          _ingredientsController.text = result.suggestedIngredients.join('\n');
          _instructionsController.text = result.suggestedInstructions.join('\n\n');
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveRecipe() async {
    final l10n = AppLocalizations.of(context)!;

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseEnterName),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Parse Zutaten aus Text
      final ingredientLines = _ingredientsController.text
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      // Parse Zubereitungsschritte
      final instructionLines = _instructionsController.text
          .split(RegExp(r'\n\n?'))
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      // Erstelle Rezept-Daten
      final recipeData = <String, dynamic>{
        'name': _nameController.text.trim(),
        'recipeIngredient': ingredientLines.map((i) => {
          'note': i,
          'display': i,
        }).toList(),
        'recipeInstructions': instructionLines.asMap().entries.map((e) => {
          'id': '${e.key + 1}',
          'text': e.value,
        }).toList(),
      };

      // Erstelle das Rezept über die API
      await _recipeRepository.createRecipe(recipeData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.recipeCreated),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        title: Text(l10n.importRecipeFromPhoto),
        actions: [
          if (_recognizedRecipe != null)
            IconButton(
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check),
              onPressed: _isSaving ? null : _saveRecipe,
              tooltip: l10n.save,
            ),
        ],
      ),
      body: _selectedImage == null
          ? _buildImageSelectionView(l10n)
          : _buildProcessingView(l10n),
    );
  }

  Widget _buildImageSelectionView(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 80,
              color: _accent.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.selectOrCaptureRecipePhoto,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.ocrDescription,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 32),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: Text(l10n.takePhoto),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: Text(l10n.chooseFromGallery),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _accent,
                    side: const BorderSide(color: _accent),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingView(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bildvorschau
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton.filled(
                      onPressed: () {
                        setState(() {
                          _selectedImage = null;
                          _recognizedRecipe = null;
                          _nameController.clear();
                          _ingredientsController.clear();
                          _instructionsController.clear();
                        });
                      },
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  if (_isProcessing)
                    Container(
                      color: Colors.black54,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.recognizingText,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Ergebnisse oder Anweisungen
          if (_isProcessing)
            const SizedBox.shrink()
          else if (_recognizedRecipe == null)
            Center(
              child: ElevatedButton.icon(
                onPressed: _processImage,
                icon: const Icon(Icons.document_scanner),
                label: Text(l10n.startRecognition),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                ),
              ),
            )
          else ...[
            // Rezeptname
            Text(
              l10n.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: l10n.pleaseEnterName,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _accent, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Zutaten
            Text(
              l10n.ingredients,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _ingredientsController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: l10n.ingredientsPerLine,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _accent, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Zubereitung
            Text(
              l10n.instructions,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _instructionsController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: l10n.instructionsPerStep,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _accent, width: 2),
                ),
              ),
            ),

            // Roher erkannter Text (erweiterbar)
            if (_recognizedRecipe!.rawText.isNotEmpty) ...[
              const SizedBox(height: 24),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(
                  l10n.recognizedRawText,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      _recognizedRecipe!.rawText,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),

            // Speichern-Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveRecipe,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(l10n.saveRecipe),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

