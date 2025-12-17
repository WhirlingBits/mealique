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

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        // Setzt die Textfarbe für alle Zustände auf Weiß
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(color: Colors.white),
        ),
        // Setzt die Icon-Farbe für alle Zustände auf Weiß
        iconTheme: WidgetStateProperty.all(
          const IconThemeData(color: Colors.white),
        ),
      ),
      child: NavigationBar(
        backgroundColor: const Color(0xFFE58325),
        // Halbtransparenter weißer Indikator für guten Kontrast
        indicatorColor: Colors.white.withOpacity(0.2),
        onDestinationSelected: onDestinationSelected,
        selectedIndex: selectedIndex,
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
            icon: const Icon(Icons.shopping_cart_outlined),
            selectedIcon: const Icon(Icons.shopping_cart),
            label: l10n.shoppingList,
          ),
        ],
      ),
    );
  }
}
