import 'package:flutter/material.dart';
import 'category_detail_screen.dart'; // On va le créer juste après

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  // Liste simulée des catégories
  final List<Map<String, dynamic>> allCategories = [
    {"name": "Électronique", "icon": Icons.phone_android, "count": 24},
    {"name": "Vêtements", "icon": Icons.checkroom, "count": 150},
    {"name": "Alimentation", "icon": Icons.local_grocery_store, "count": 85},
    {"name": "Beauté", "icon": Icons.content_cut, "count": 42},
    {"name": "Maison", "icon": Icons.home, "count": 60},
  ];

  List<Map<String, dynamic>> displayedCategories = [];

  @override
  void initState() {
    super.initState();
    displayedCategories = allCategories; // Au début, on affiche tout
  }

  void _filterCategories(String query) {
    setState(() {
      displayedCategories = allCategories
          .where((cat) => cat['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Catégories & Rayons"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- BARRE DE RECHERCHE ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filterCategories,
              decoration: InputDecoration(
                hintText: "Rechercher un rayon...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // --- LISTE DES CARTES ---
          Expanded(
            child: ListView.builder(
              itemCount: displayedCategories.length,
              itemBuilder: (context, index) {
                final cat = displayedCategories[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[50],
                      child: Icon(cat['icon'], color: Colors.blueAccent),
                    ),
                    title: Text(cat['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${cat['count']} produits disponibles"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Aller vers les détails de la catégorie

                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}