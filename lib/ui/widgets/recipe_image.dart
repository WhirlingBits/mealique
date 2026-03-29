import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mealique/data/local/token_storage.dart';

/// Lädt das Bild eines Rezepts vom Mealie-Server.
/// Falls kein Bild vorhanden oder der Ladevorgang fehlschlägt,
/// wird das Mealique-Logo als Platzhalter angezeigt.
class RecipeImage extends StatelessWidget {
  /// Slug oder ID des Rezepts (wird für die Bild-URL genutzt).
  final String recipeSlug;

  /// Optional: `recipe.image` Wert aus dem API-Response.
  /// Wenn null, wird trotzdem versucht, das Standardbild zu laden.
  final String? imageHint;

  final BoxFit fit;
  final double? width;
  final double? height;

  const RecipeImage({
    super.key,
    required this.recipeSlug,
    this.imageHint,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Kein Bild angegeben → direkt Mealique-Logo zeigen
    if (imageHint == null || imageHint!.isEmpty) {
      return _buildFallback(width: width, height: height);
    }

    return FutureBuilder<String?>(
      future: TokenStorage().getServerUrl(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return _buildFallback(width: width, height: height);
        }

        final serverUrl = snapshot.data!.replaceAll(RegExp(r'/$'), '');
        final imageUrl =
            '$serverUrl/api/media/recipes/$recipeSlug/images/original.webp';

        return CachedNetworkImage(
          imageUrl: imageUrl,
          fit: fit,
          width: width,
          height: height,
          placeholder: (_, __) => _buildLoading(),
          errorWidget: (_, __, ___) =>
              _buildFallback(width: width, height: height),
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

