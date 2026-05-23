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
  final _servingsController = TextEditingController();
  List<TextEditingController> _ingredientControllers = [];
  List<TextEditingController> _instructionControllers = [];

  @override
  void dispose() {
    _ocrService.dispose();
    _nameController.dispose();
    _servingsController.dispose();
    for (final c in _ingredientControllers) {
      c.dispose();
    }
    for (final c in _instructionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Foto aufnehmen / wechseln ─────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 92,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _recognizedRecipe = null;
          _clearEditors();
        });
        await _processImage();
      }
    } catch (e) {
      if (mounted) {
        _showError('${AppLocalizations.of(context)!.error}: $e');
      }
    }
  }

  // ── OCR ────────────────────────────────────────────────────────────────────

  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    setState(() => _isProcessing = true);

    try {
      final result =
          await _ocrService.recognizeRecipeFromImage(_selectedImage!);

      if (mounted) {
        setState(() {
          _recognizedRecipe = result;
          _initEditors(result);
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _showError('${AppLocalizations.of(context)!.error}: $e');
      }
    }
  }

  // ── Editor-Verwaltung ─────────────────────────────────────────────────────

  void _initEditors(RecognizedRecipe result) {
    _clearEditors();
    _nameController.text = result.suggestedName;
    _servingsController.clear();

    _ingredientControllers = result.suggestedIngredients
        .map((i) => TextEditingController(text: i))
        .toList();
    if (_ingredientControllers.isEmpty) {
      _ingredientControllers.add(TextEditingController());
    }

    _instructionControllers = result.suggestedInstructions
        .map((s) => TextEditingController(text: s))
        .toList();
    if (_instructionControllers.isEmpty) {
      _instructionControllers.add(TextEditingController());
    }
  }

  void _clearEditors() {
    _nameController.clear();
    _servingsController.clear();
    for (final c in _ingredientControllers) {
      c.dispose();
    }
    for (final c in _instructionControllers) {
      c.dispose();
    }
    _ingredientControllers = [];
    _instructionControllers = [];
  }

  void _addIngredient() {
    setState(() => _ingredientControllers.add(TextEditingController()));
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredientControllers[index].dispose();
      _ingredientControllers.removeAt(index);
    });
  }

  void _addInstruction() {
    setState(() => _instructionControllers.add(TextEditingController()));
  }

  void _removeInstruction(int index) {
    setState(() {
      _instructionControllers[index].dispose();
      _instructionControllers.removeAt(index);
    });
  }

  // ── Speichern ─────────────────────────────────────────────────────────────

  Future<void> _saveRecipe() async {
    final l10n = AppLocalizations.of(context)!;

    if (_nameController.text.trim().isEmpty) {
      _showWarning(l10n.pleaseEnterName);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final ingredientLines = _ingredientControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final instructionLines = _instructionControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final recipeData = <String, dynamic>{
        'name': _nameController.text.trim(),
        if (_servingsController.text.trim().isNotEmpty)
          'recipeYield': _servingsController.text.trim(),
        'recipeIngredient': ingredientLines
            .map((i) => {'note': i, 'display': i})
            .toList(),
        'recipeInstructions': instructionLines
            .asMap()
            .entries
            .map((e) => {'id': '${e.key + 1}', 'text': e.value})
            .toList(),
      };

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
        _showError('${l10n.error}: $e');
      }
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _showWarning(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.orange),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        title: Text(l10n.importRecipeFromPhoto),
        actions: [
          // Erneut scannen
          if (_selectedImage != null && !_isProcessing)
            IconButton(
              icon: const Icon(Icons.document_scanner_outlined),
              onPressed: _processImage,
              tooltip: l10n.reScan,
            ),
          // Speichern
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

  // ── Bildauswahl ───────────────────────────────────────────────────────────

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
            _buildPickButtons(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildPickButtons(AppLocalizations l10n) {
    return Wrap(
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
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => _pickImage(ImageSource.gallery),
          icon: const Icon(Icons.photo_library),
          label: Text(l10n.chooseFromGallery),
          style: OutlinedButton.styleFrom(
            foregroundColor: _accent,
            side: const BorderSide(color: _accent),
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  // ── Verarbeitungs-/Ergebnis-Ansicht ──────────────────────────────────────

  Widget _buildProcessingView(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bildvorschau
          _buildImagePreview(l10n),

          const SizedBox(height: 24),

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
            _buildNameField(l10n),
            const SizedBox(height: 16),
            _buildServingsField(l10n),
            const SizedBox(height: 24),
            _buildIngredientsSection(l10n),
            const SizedBox(height: 24),
            _buildInstructionsSection(l10n),
            if (_recognizedRecipe!.rawText.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildRawTextExpansion(l10n),
            ],
            const SizedBox(height: 32),
            _buildSaveButton(l10n),
          ],
        ],
      ),
    );
  }

  Widget _buildImagePreview(AppLocalizations l10n) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(_selectedImage!, fit: BoxFit.cover),
            // Schließen-Button (oben rechts)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filled(
                onPressed: () {
                  setState(() {
                    _selectedImage = null;
                    _recognizedRecipe = null;
                    _clearEditors();
                  });
                },
                icon: const Icon(Icons.close),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            // „Foto wechseln"-Menü (oben links)
            Positioned(
              top: 8,
              left: 8,
              child: PopupMenuButton<ImageSource>(
                tooltip: l10n.changePhoto,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                ),
                onSelected: _pickImage,
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: ImageSource.camera,
                    child: ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: Text(l10n.takePhoto),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: ImageSource.gallery,
                    child: ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: Text(l10n.chooseFromGallery),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
            // Ladeoverlay
            if (_isProcessing)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
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
    );
  }

  // ── Felder ────────────────────────────────────────────────────────────────

  Widget _buildNameField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(l10n.name),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.sentences,
          decoration: _inputDecoration(l10n.pleaseEnterName),
        ),
      ],
    );
  }

  Widget _buildServingsField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(l10n.servings),
        const SizedBox(height: 8),
        TextField(
          controller: _servingsController,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration('z.B. 4'),
        ),
      ],
    );
  }

  Widget _buildIngredientsSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionTitle(l10n.ingredients),
            TextButton.icon(
              onPressed: _addIngredient,
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.addIngredient),
              style: TextButton.styleFrom(foregroundColor: _accent),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_ingredientControllers.isEmpty)
          _emptyHint(l10n.noIngredientsAdded)
        else
          ...List.generate(_ingredientControllers.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ingredientControllers[i],
                      decoration: _inputDecoration(null),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red.shade300,
                    tooltip: l10n.removeIngredient,
                    onPressed: () => _removeIngredient(i),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildInstructionsSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionTitle(l10n.instructions),
            TextButton.icon(
              onPressed: _addInstruction,
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.addInstruction),
              style: TextButton.styleFrom(foregroundColor: _accent),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_instructionControllers.isEmpty)
          _emptyHint(l10n.noInstructionsAdded)
        else
          ...List.generate(_instructionControllers.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Schritt-Nummer
                  Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.only(top: 12, right: 8),
                    decoration: const BoxDecoration(
                      color: _accent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _instructionControllers[i],
                      maxLines: null,
                      minLines: 2,
                      decoration: _inputDecoration(l10n.addInstructionHint),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red.shade300,
                    tooltip: l10n.remove,
                    onPressed: () => _removeInstruction(i),
                    padding: const EdgeInsets.only(top: 4),
                    alignment: Alignment.topCenter,
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildRawTextExpansion(AppLocalizations l10n) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        l10n.recognizedRawText,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(color: Colors.grey),
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
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n) {
    return SizedBox(
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ── Shared Helpers ────────────────────────────────────────────────────────

  Text _sectionTitle(String text) => Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      );

  Widget _emptyHint(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(text,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
      );

  InputDecoration _inputDecoration(String? hint) => InputDecoration(
        hintText: hint,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _accent, width: 2),
        ),
      );
}
