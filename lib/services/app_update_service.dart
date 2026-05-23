import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class AppUpdateInfo {
  const AppUpdateInfo({
    required this.canUpdate,
    required this.storeUrl,
    this.storeVersion,
  });

  final bool canUpdate;
  final String storeUrl;
  final String? storeVersion;
}

class AppUpdateService {
  AppUpdateService._();

  static final AppUpdateService instance = AppUpdateService._();

  Future<AppUpdateInfo> checkForUpdate({required String playStoreId}) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    final storeUrl =
        'https://play.google.com/store/apps/details?id=$playStoreId';

    final response = await http.get(
      Uri.parse('$storeUrl&hl=de&gl=DE'),
      headers: const {
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 14; Pixel 7) AppleWebKit/537.36 '
                '(KHTML, like Gecko) Chrome/126.0.0.0 Mobile Safari/537.36',
        'Accept-Language': 'de-DE,de;q=0.9,en;q=0.8',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Play Store request failed: ${response.statusCode}');
    }

    final storeVersion = _extractStoreVersion(response.body);
    if (storeVersion == null) {
      return AppUpdateInfo(
        canUpdate: false,
        storeUrl: storeUrl,
      );
    }

    final shouldUpdate = _isStoreVersionNewer(
      currentVersion: currentVersion,
      storeVersion: storeVersion,
    );

    return AppUpdateInfo(
      canUpdate: shouldUpdate,
      storeVersion: storeVersion,
      storeUrl: storeUrl,
    );
  }

  String? _extractStoreVersion(String html) {
    final decodedHtml = html.contains('\\u003c') ? _tryUnicodeUnescape(html) : html;

    final patterns = <RegExp>[
      RegExp(r'"softwareVersion"\s*:\s*"([^"]+)"'),
      RegExp(r'\[\[\["([0-9]+(?:\.[0-9A-Za-z-]+)+)"\]\]'),
      RegExp(r'>\s*Current Version\s*<[^>]*>\s*<span[^>]*>([^<]+)<'),
      RegExp(r'>\s*Aktuelle Version\s*<[^>]*>\s*<span[^>]*>([^<]+)<'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(decodedHtml);
      if (match != null) {
        final candidate = match.group(1)?.trim();
        if (candidate != null && candidate.isNotEmpty) {
          return candidate;
        }
      }
    }

    return null;
  }

  String _tryUnicodeUnescape(String input) {
    try {
      final escaped = input.replaceAll('"', r'\"');
      return jsonDecode('"$escaped"') as String;
    } catch (_) {
      return input;
    }
  }

  bool _isStoreVersionNewer({
    required String currentVersion,
    required String storeVersion,
  }) {
    final currentParts = _numericParts(currentVersion);
    final storeParts = _numericParts(storeVersion);

    final maxLen = currentParts.length > storeParts.length
        ? currentParts.length
        : storeParts.length;

    for (var i = 0; i < maxLen; i++) {
      final current = i < currentParts.length ? currentParts[i] : 0;
      final store = i < storeParts.length ? storeParts[i] : 0;

      if (store > current) return true;
      if (store < current) return false;
    }

    return false;
  }

  List<int> _numericParts(String version) {
    final matches = RegExp(r'\d+').allMatches(version);
    return matches
        .map((m) => int.tryParse(m.group(0) ?? '') ?? 0)
        .toList(growable: false);
  }
}

