import 'package:flutter/material.dart';

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFE58325);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            backgroundColor: accentColor,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  // TODO: Favoriten Logik
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Rezepttitel',
                style: TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: Colors.grey[400],
                    child: const Icon(Icons.image, size: 80, color: Colors.white54),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          // UPDATE: Übergangsfarbe (Gradient) auf Orange angepasst
                          accentColor.withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInfoChip(Icons.access_time, '30 Min'),
                      Container(width: 1, height: 24, color: Colors.grey[300]),
                      _buildInfoChip(Icons.person_outline, '2 Portionen'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text('Zur Einkaufsliste'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('ZUTATEN', accentColor),
                  const SizedBox(height: 8),
                  _buildIngredientItem('200g Nudeln', isChecked: true, accentColor: accentColor),
                  _buildIngredientItem('1 Zwiebel', isChecked: false, accentColor: accentColor),
                  _buildIngredientItem('2 Tomaten', isChecked: false, accentColor: accentColor),
                  const SizedBox(height: 32),
                  _buildSectionTitle('ZUBEREITUNG', accentColor),
                  const SizedBox(height: 16),
                  _buildInstructionStep(1, 'Wasser in einem großen Topf zum Kochen bringen und salzen.', accentColor),
                  _buildInstructionStep(2, 'Nudeln hinzufügen und al dente kochen.', accentColor),
                  _buildInstructionStep(3, 'Währenddessen die Sauce zubereiten: Zwiebeln und Tomaten schneiden und anbraten.', accentColor),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: color, // UPDATE: Titel in Orange
      ),
    );
  }

  Widget _buildIngredientItem(String text, {required bool isChecked, required Color accentColor}) {
    return CheckboxListTile(
      value: isChecked,
      onChanged: (val) {},
      title: Text(
        text,
        style: TextStyle(
          decoration: isChecked ? TextDecoration.lineThrough : null,
          color: isChecked ? Colors.grey : Colors.black,
        ),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
      activeColor: accentColor,
    );
  }

  Widget _buildInstructionStep(int number, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color, // UPDATE: Nummer-Hintergrund in Orange
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white, // UPDATE: Text weiß für Kontrast
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
