import 'package:flutter/material.dart';

/// Breakpoints für responsive Layouts.
///
/// - compact: < 600px (Phones)
/// - medium: 600px - 840px (kleine Tablets)
/// - expanded: >= 840px (große Tablets, Desktop)
class Breakpoints {
  static const double compact = 600;
  static const double medium = 840;
  static const double expanded = 1200;

  Breakpoints._();
}

/// Enumeration der verschiedenen Bildschirmgrößen-Kategorien.
enum ScreenSize { compact, medium, expanded }

/// Hilfsklasse für responsive Design-Entscheidungen.
class ResponsiveUtils {
  /// Gibt die aktuelle Bildschirmgrößen-Kategorie zurück.
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= Breakpoints.medium) {
      return ScreenSize.expanded;
    } else if (width >= Breakpoints.compact) {
      return ScreenSize.medium;
    }
    return ScreenSize.compact;
  }

  /// Prüft ob die aktuelle Bildschirmbreite einem Tablet entspricht (>= 600px).
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= Breakpoints.compact;
  }

  /// Prüft ob die aktuelle Bildschirmbreite einem großen Tablet/Desktop entspricht (>= 840px).
  static bool isLargeTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= Breakpoints.medium;
  }

  /// Gibt die optimale Anzahl an Grid-Spalten basierend auf der Bildschirmbreite zurück.
  static int getGridCrossAxisCount(BuildContext context, {int minColumns = 2}) {
    final width = MediaQuery.of(context).size.width;
    if (width >= Breakpoints.expanded) {
      return minColumns + 3; // z.B. 5 Spalten für großes Tablet/Desktop
    } else if (width >= Breakpoints.medium) {
      return minColumns + 2; // z.B. 4 Spalten für großes Tablet
    } else if (width >= Breakpoints.compact) {
      return minColumns + 1; // z.B. 3 Spalten für kleines Tablet
    }
    return minColumns; // Standard für Phones
  }

  /// Gibt einen passenden horizontalen Padding-Wert basierend auf der Bildschirmbreite zurück.
  static double getHorizontalPadding(BuildContext context) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.expanded:
        return 32.0;
      case ScreenSize.medium:
        return 24.0;
      case ScreenSize.compact:
        return 16.0;
    }
  }

  /// Berechnet die Breite für das Detail-Panel in Master-Detail Layouts.
  /// Gibt null zurück, wenn kein Master-Detail Layout verwendet werden soll.
  static double? getDetailPanelWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= Breakpoints.medium) {
      // 55% der Bildschirmbreite für das Detail-Panel
      return width * 0.55;
    }
    return null; // Kein Master-Detail Layout
  }

  /// Berechnet die Breite für das Master-Panel in Master-Detail Layouts.
  static double? getMasterPanelWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= Breakpoints.medium) {
      // 45% der Bildschirmbreite für das Master-Panel
      return width * 0.45;
    }
    return null; // Kein Master-Detail Layout
  }
}

/// Ein Widget, das basierend auf der Bildschirmgröße verschiedene Builder aufruft.
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) compactBuilder;
  final Widget Function(BuildContext context)? mediumBuilder;
  final Widget Function(BuildContext context)? expandedBuilder;

  const ResponsiveBuilder({
    super.key,
    required this.compactBuilder,
    this.mediumBuilder,
    this.expandedBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.medium && expandedBuilder != null) {
          return expandedBuilder!(context);
        } else if (constraints.maxWidth >= Breakpoints.compact && (mediumBuilder ?? expandedBuilder) != null) {
          return (mediumBuilder ?? expandedBuilder)!(context);
        }
        return compactBuilder(context);
      },
    );
  }
}

/// Ein Widget, das ein Master-Detail Layout auf Tablets und ein einfaches Layout auf Phones anzeigt.
class MasterDetailLayout extends StatelessWidget {
  final Widget masterPanel;
  final Widget? detailPanel;
  final Widget? emptyDetailPlaceholder;
  final double masterPanelMinWidth;
  final double masterPanelMaxWidth;

  const MasterDetailLayout({
    super.key,
    required this.masterPanel,
    this.detailPanel,
    this.emptyDetailPlaceholder,
    this.masterPanelMinWidth = 300,
    this.masterPanelMaxWidth = 400,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTabletLayout = constraints.maxWidth >= Breakpoints.medium;

        if (!isTabletLayout) {
          // Phone: Nur Master-Panel anzeigen
          return masterPanel;
        }

        // Tablet: Master-Detail Layout
        final masterWidth = (constraints.maxWidth * 0.4).clamp(
          masterPanelMinWidth,
          masterPanelMaxWidth,
        );

        return Row(
          children: [
            SizedBox(
              width: masterWidth,
              child: masterPanel,
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: detailPanel ??
                  emptyDetailPlaceholder ??
                  _buildEmptyPlaceholder(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyPlaceholder(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Wähle ein Element aus der Liste',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

/// Extension-Methode für einfacheren Zugriff auf responsive Utilities.
extension ResponsiveContext on BuildContext {
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isLargeTablet => ResponsiveUtils.isLargeTablet(this);
  ScreenSize get screenSize => ResponsiveUtils.getScreenSize(this);
  int get gridColumns => ResponsiveUtils.getGridCrossAxisCount(this);
}

