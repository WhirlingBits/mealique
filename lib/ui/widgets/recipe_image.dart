import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mealique/config/app_constants.dart';
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

/// Global cached config to avoid repeated secure storage reads
class _ImageConfigCache {
  static String? serverUrl;
  static String? token;
  static bool _isRefreshing = false;

  /// Notifier für Änderungen - Widgets können darauf hören
  static final ValueNotifier<int> refreshNotifier = ValueNotifier<int>(0);

  static bool get hasData => serverUrl != null && token != null;

  /// Force refresh the cache from storage
  static Future<void> refresh({bool force = false}) async {
    // Prevent concurrent refreshes
    if (_isRefreshing && !force) return;
    _isRefreshing = true;

    final storage = TokenStorage();
    // Retry logic for secure storage after standby
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final results = await Future.wait([
          storage.getServerUrl(),
          storage.getToken(),
        ]);
        final newServerUrl = results[0] ?? '';
        final newToken = results[1] ?? '';

        // Prüfe ob sich die Daten geändert haben
        final hasChanged = serverUrl != newServerUrl || token != newToken;
        
        // Update cache values
        serverUrl = newServerUrl;
        token = newToken;
        
        debugPrint('ImageConfigCache: Refreshed - serverUrl=$serverUrl, token=${token?.substring(0, (token?.length ?? 0).clamp(0, 10))}..., hasChanged=$hasChanged, force=$force');

        // Benachrichtige alle Widgets, dass sich der Cache geändert hat
        // Bei force: true immer benachrichtigen (z.B. nach App-Resume)
        if (hasChanged || force) {
          refreshNotifier.value++;
          debugPrint('ImageConfigCache: Notified listeners, new version=${refreshNotifier.value}');
        }
        
        _isRefreshing = false;
        return;
      } on PlatformException catch (e) {
        debugPrint('ImageConfigCache: Storage not ready (attempt ${attempt + 1}): $e');
        if (attempt < 2) {
          await Future.delayed(Duration(milliseconds: 300 * (attempt + 1)));
        }
      } catch (e) {
        debugPrint('ImageConfigCache: Error reading storage: $e');
        if (attempt < 2) {
          await Future.delayed(Duration(milliseconds: 300 * (attempt + 1)));
        }
      }
    }
    _isRefreshing = false;
  }

  static void invalidate() {
    serverUrl = null;
    token = null;
    refreshNotifier.value++;
    debugPrint('ImageConfigCache: Invalidated');
  }
}

/// Lädt das Bild eines Rezepts vom Mealie-Server.
/// Falls kein Bild vorhanden oder der Ladevorgang fehlschlägt,
/// wird das Mealique-Logo als Platzhalter angezeigt.
class RecipeImage extends StatefulWidget {
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

  /// Invalidates the cached config (call after login/logout)
  static void invalidateCache() {
    _ImageConfigCache.invalidate();
  }

  /// Refreshes the cache (call when app resumes from background)
  static Future<void> refreshCache() async {
    await _ImageConfigCache.refresh(force: true);
  }

  @override
  State<RecipeImage> createState() => _RecipeImageState();
}

class _RecipeImageState extends State<RecipeImage> {
  bool _isLoading = true;
  String _serverUrl = '';
  String _token = '';
  int _cacheVersion = 0;

  @override
  void initState() {
    super.initState();
    _cacheVersion = _ImageConfigCache.refreshNotifier.value;
    _ImageConfigCache.refreshNotifier.addListener(_onCacheRefresh);
    _loadConfig();
  }

  @override
  void dispose() {
    _ImageConfigCache.refreshNotifier.removeListener(_onCacheRefresh);
    super.dispose();
  }

  void _onCacheRefresh() {
    if (!mounted) return;
    // Cache hat sich geändert - Daten neu laden
    final newVersion = _ImageConfigCache.refreshNotifier.value;
    if (_cacheVersion != newVersion) {
      debugPrint('RecipeImage[${widget.recipeId}]: Cache version changed from $_cacheVersion to $newVersion, reloading...');
      _cacheVersion = newVersion;
      setState(() {
        _serverUrl = _ImageConfigCache.serverUrl ?? '';
        _token = _ImageConfigCache.token ?? '';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadConfig() async {
    // Always try to refresh if no data cached
    if (!_ImageConfigCache.hasData) {
      await _ImageConfigCache.refresh();
    }

    if (mounted) {
      setState(() {
        _serverUrl = _ImageConfigCache.serverUrl ?? '';
        _token = _ImageConfigCache.token ?? '';
        _cacheVersion = _ImageConfigCache.refreshNotifier.value;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kein Bild angegeben → direkt Mealique-Logo zeigen
    if (widget.imageHint == null || widget.imageHint!.isEmpty) {
      return _buildFallback(width: widget.width, height: widget.height);
    }

    if (_isLoading) {
      return _buildLoading();
    }

    // Demo mode or empty server - show fallback
    if (_serverUrl.isEmpty || _serverUrl == AppConstants.demoServerUrl) {
      return _buildFallback(width: widget.width, height: widget.height);
    }

    final cleanServerUrl = _serverUrl.replaceAll(RegExp(r'/$'), '');
    // API URL: /api/media/recipes/{recipe_id}/images/{file_name}
    final imageUrl =
        '$cleanServerUrl/api/media/recipes/${widget.recipeId}/images/${widget.size.fileName}';

    // Verwende cacheKey mit Version UND Token-Hash, um Bilder nach Cache-Refresh neu zu laden
    // Das Token kann sich nach App-Resume geändert haben
    final tokenHash = _token.isNotEmpty ? _token.hashCode.toString() : 'notoken';
    final cacheKey = '${widget.recipeId}_${widget.size.fileName}_v${_cacheVersion}_$tokenHash';

    debugPrint('RecipeImage[${widget.recipeId}]: Building with cacheKey=$cacheKey, serverUrl=$cleanServerUrl');

    return CachedNetworkImage(
      key: ValueKey(cacheKey),
      cacheKey: cacheKey,
      imageUrl: imageUrl,
      httpHeaders: _token.isNotEmpty
          ? {'Authorization': 'Bearer $_token'}
          : null,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      placeholder: (_, __) => _buildLoading(),
      errorWidget: (_, url, error) {
        debugPrint('RecipeImage[${widget.recipeId}]: Error loading $url - $error');
        return _buildFallback(width: widget.width, height: widget.height);
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

