import 'package:flutter/material.dart';

class EmployerCategoryDetailScreen extends StatefulWidget {
  const EmployerCategoryDetailScreen({super.key});

  @override
  State createState() => _EmployerCategoryDetailsState();
}

class _EmployerCategoryDetailsState extends State<EmployerCategoryDetailScreen> {
  // Liste simulée des produits
  final List<Map<String, dynamic>> products = [
    {"name": "iPhone 15 Pro", "price": 750000, "qty": 3, "ref": "APP-001"},
    {"name": "Samsung S23", "price": 450000, "qty": 12, "ref": "SAM-042"},
    {"name": "Coque Silicone", "price": 5000, "qty": 50, "ref": "ACC-009"},
    {"name": "Airpods Pro 2", "price": 150000, "qty": 8, "ref": "APP-005"},
  ];

  // Fonction pour déterminer la couleur selon la quantité
  Color _getQuantityColor(int qty) {
    if (qty <= 5) return Colors.red;      // Faible
    if (qty <= 15) return Colors.orange;  // Moyen
    return Colors.green;                  // Grand
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des Stocks"),
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
              decoration: InputDecoration(
                hintText: "Rechercher un produit...",
                prefixIcon: const Icon(Icons.inventory_2_outlined),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // --- LISTE DES PRODUITS DÉPLIABLES ---
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];
                final Color statusColor = _getQuantityColor(p['qty']);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 1,
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: statusColor.withOpacity(0.1),
                      child: Icon(Icons.shopping_bag_outlined, color: statusColor),
                    ),
                    title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Réf: ${p['ref']}"),
                    // L'icône de dépliage est gérée automatiquement par ExpansionTile
                    children: [
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // --- INFOS DÉTAILLÉES ---
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildDetailItem("Prix", "${p['price']} F"),
                                _buildDetailItem("Quantité", "${p['qty']}", color: statusColor),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // --- BOUTONS D'ACTION ---
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildActionButton(Icons.edit, "Modifier", Colors.blue, () {}),
                                _buildActionButton(Icons.add_box, "Restocker", Colors.green, () {
                                  _showRestockDialog(context, p['name']);
                                }),
                                _buildActionButton(Icons.delete_outline, "Supprimer", Colors.red, () {}),
                                _buildActionButton(Icons.info_rounded, "information", Colors.deepOrange, (){
                                  _showRestockDialog(context, p['name']);
                                })
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour un détail (Prix ou Quantité)
  Widget _buildDetailItem(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
      ],
    );
  }

  // Widget pour les boutons Modifier/Restocker/Supprimer
  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  // Dialogue rapide pour restocker
  void _showRestockDialog(BuildContext context, String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Restocker $productName"),
        content: const TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: "Quantité à ajouter"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Ajouter")),
        ],
      ),
    );
  }
}