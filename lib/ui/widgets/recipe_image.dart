import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mealique/data/local/token_storage.dart';

/// Bildgröße für Rezeptbilder
enum RecipeImageSize {
  /// Vollauflösung
  original('original.webp'),
  /// Mittlere Auflösung (empfohlen für Listen)
  min('min-original.webp'),
  /// Kleine Auflösung (Thumbnails)
  tiny('tiny-original.webp');

  final String fileName;
  const RecipeImageSize(this.fileName);
}

/// Lädt das Bild eines Rezepts vom Mealie-Server.
/// Falls kein Bild vorhanden oder der Ladevorgang fehlschlägt,
/// wird das Mealique-Logo als Platzhalter angezeigt.
class RecipeImage extends StatelessWidget {
  /// ID des Rezepts (wird für die Bild-URL genutzt).
  final String recipeId;

  /// Gibt an, ob das Rezept ein Bild hat (aus recipe.image).
  /// Wenn null oder leer, wird das Fallback-Bild angezeigt.
  final String? imageHint;

  /// Bildgröße - bestimmt welche Datei geladen wird
  final RecipeImageSize size;

  final BoxFit fit;
  final double? width;
  final double? height;

  const RecipeImage({
    super.key,
    required this.recipeId,
    this.imageHint,
    this.size = RecipeImageSize.min,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  Future<Map<String, String>> _loadConfig() async {
    final storage = TokenStorage();
    final serverUrl = await storage.getServerUrl();
    final token = await storage.getToken();
    return {
      'serverUrl': serverUrl ?? '',
      'token': token ?? '',
    };
  }

  @override
  Widget build(BuildContext context) {
    // Kein Bild angegeben → direkt Mealique-Logo zeigen
    if (imageHint == null || imageHint!.isEmpty) {
      return _buildFallback(width: width, height: height);
    }

    return FutureBuilder<Map<String, String>>(
      future: _loadConfig(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!['serverUrl']!.isEmpty) {
          return _buildFallback(width: width, height: height);
        }

        final serverUrl = snapshot.data!['serverUrl']!.replaceAll(RegExp(r'/$'), '');
        final token = snapshot.data!['token']!;
        // API URL: /api/media/recipes/{recipe_id}/images/{file_name}
        // file_name: original.webp, min-original.webp, tiny-original.webp
        final imageUrl =
            '$serverUrl/api/media/recipes/$recipeId/images/${size.fileName}';

        return CachedNetworkImage(
          imageUrl: imageUrl,
          httpHeaders: token.isNotEmpty
              ? {'Authorization': 'Bearer $token'}
              : null,
          fit: fit,
          width: width,
          height: height,
          placeholder: (_, __) => _buildLoading(),
          errorWidget: (_, __, ___) => _buildFallback(width: width, height: height),
        );
      },
    );
  }

  static Widget _buildFallback({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFE58325).withValues(alpha: 0.12),
      child: Center(
        child: Image.asset(
          'assets/mealique.png',
          width: 56,
          height: 56,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  static Widget _buildLoading() {
    return Container(
      color: const Color(0xFFE58325).withValues(alpha: 0.08),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFFE58325),
        ),
      ),
    );
  }
}

