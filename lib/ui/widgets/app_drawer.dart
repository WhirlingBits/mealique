import 'package:flutter/material.dart';
import 'package:mealique/l10n/app_localizations.dart';
import '../screens/settings_screen.dart';

class AppDrawer extends StatelessWidget {
  final String? name;
  final String? email;
  final String? imageUrl;
  final String? logoAssetPath;
  final ValueChanged<int>? onDestinationSelected;

  const AppDrawer({
    super.key,
    this.name,
    this.email,
    this.imageUrl,
    this.logoAssetPath,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = const Color(0xFFE58325);

    return Drawer(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/profile');
                  },
                  child: UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      color: primaryColor,
                    ),
                    accountName: Text(name ?? 'Gast'),
                    accountEmail: Text(email ?? ''),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: imageUrl != null
                          ? NetworkImage(imageUrl!) as ImageProvider
                          : null,
                      child: imageUrl == null
                          ? Icon(
                        Icons.person,
                        size: 40,
                        color: primaryColor,
                      )
                          : null,
                    ),
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text(l10n.settings),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(
                            title: Text(l10n.settings),
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          body: const SettingsScreen(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Über Mealique'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}