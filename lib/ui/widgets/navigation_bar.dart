import 'package:flutter/material.dart';
import 'package:mealique/l10n/app_localizations.dart';

class AppNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const AppNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    final double iconSize;
    final double labelFontSize;

    if (screenWidth > 600) { // Tablet
      iconSize = 28.0;
      labelFontSize = 14.0;
    } else if (screenWidth < 360) { // Small phone
      iconSize = 22.0;
      labelFontSize = 10.0; // Further reduced for very narrow screens
    } else { // Regular phone
      iconSize = 24.0;
      labelFontSize = 12.0;
    }

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(
            color: Colors.white,
            fontSize: labelFontSize,
            overflow: TextOverflow.ellipsis, // Prevent wrapping with an ellipsis
          ),
        ),
        iconTheme: WidgetStateProperty.all(
          IconThemeData(color: Colors.white, size: iconSize),
        ),
      ),
      child: NavigationBar(
        backgroundColor: const Color(0xFFE58325),
        indicatorColor: Colors.white.withOpacity(0.2),
        onDestinationSelected: onDestinationSelected,
        selectedIndex: selectedIndex,
        // On very small screens, only show the label for the selected item.
        labelBehavior: screenWidth < 360
            ? NavigationDestinationLabelBehavior.onlyShowSelected
            : NavigationDestinationLabelBehavior.alwaysShow,
        destinations: <Widget>[
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: l10n.recipes,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: l10n.planner,
          ),
          NavigationDestination(
            icon: const Icon(Icons.shopping_cart_outlined),
            selectedIcon: const Icon(Icons.shopping_cart),
            label: l10n.shopping,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}
