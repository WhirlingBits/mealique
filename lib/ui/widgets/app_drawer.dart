import 'package:flutter/material.dart';
import 'package:mealique/l10n/app_localizations.dart';

class AppDrawer extends StatelessWidget {
  final String? name;
  final String? email;
  final String? imageUrl;
  final String? logoAssetPath;

  const AppDrawer({
    super.key,
    this.name,
    this.email,
    this.imageUrl,
    this.logoAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
            child: UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              accountName: Text(name ?? 'Gast'),
              accountEmail: Text(email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage:
                imageUrl != null ? NetworkImage(imageUrl!) as ImageProvider : null,
                child: imageUrl == null
                    ? const Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.blue,
                )
                    : null,
              ),
              otherAccountsPictures: const [],
              onDetailsPressed: null,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(l10n.home),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: Text(l10n.recipes),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle),
            title: Text(l10n.addRecipe),
            onTap: () {
            Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: Text(l10n.shoppingList),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(l10n.settings),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}