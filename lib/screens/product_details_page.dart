import 'package:flutter/material.dart';
import 'package:mobile_store_app/models/product.dart';
import 'package:mobile_store_app/service/product_service.dart';

// Modèle pour stocker les statistiques récupérées
class ProductStats {
  final int totalSold;
  final int totalEntered;
  final double revenue;

  ProductStats({
    required this.totalSold,
    required this.totalEntered,
    required this.revenue,
  });
}

class ProductStatsScreen extends StatefulWidget {
  final Product product;
  Map<String, dynamic>? statsData; // Données brutes de l'API (optionnel)

  ProductStatsScreen({super.key, required this.product});

  @override
  State<ProductStatsScreen> createState() => _ProductStatsScreenState();
}

class _ProductStatsScreenState extends State<ProductStatsScreen> {
  // On utilise un FutureBuilder pour gérer l'appel asynchrone des statistiques
  late Future<ProductStats> _statsFuture;
  void getProductsStats(String productId) async {
    Map<String,dynamic>? data = await ProductService().getStatsForProduct(productId);
    widget.statsData = data;
    print("voic $data");
  }

  @override
  void initState() {
    super.initState();
    getProductsStats(widget.product.id);
    // On lance la récupération des données au démarrage de l'écran
    _statsFuture = _fetchProductStats();
  }

  // Méthode pour appeler le service et récupérer les statistiques
  Future<ProductStats> _fetchProductStats() async {
    // NOTE : Vous devez implémenter la logique dans votre ProductService
    // pour que cette méthode fonctionne.
    // Par exemple : return ProductService().getStatsForProduct(widget.product.id);

    // Pour l'instant, nous simulons une réponse de l'API après 1 seconde.
    await Future.delayed(const Duration(seconds: 1));
    return ProductStats(
      totalSold: widget.statsData?['totalSell'] ?? 0,       // Exemple : 125 produits vendus
      totalEntered: widget.statsData?['baseStock']??0,    // Exemple : 200 produits entrés en stock
      revenue:widget.statsData?['totalSell'] ?? 0  * (widget.product.price ?? 0), // Revenu = vendus * prix
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistiques de ${widget.product.name}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: FutureBuilder<ProductStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          // Cas 1 : En attente des données
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Cas 2 : Erreur lors de la récupération
          if (snapshot.hasError) {
            return Center(child: Text("Erreur de chargement des données : ${snapshot.error}"));
          }

          // Cas 3 : Données récupérées avec succès
          if (snapshot.hasData) {
            final stats = snapshot.data!;
            final stockRestant = widget.product.quantity ?? 0;

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Carte d'informations générales
                _buildInfoCard(stockRestant),

                const SizedBox(height: 20),
                const Text("Statistiques de Vente et Stock",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(height: 20),

                // Grille pour les statistiques
                GridView.count(
                  crossAxisCount: 2, // 2 colonnes
                  shrinkWrap: true, // Pour que la grille s'adapte à son contenu
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2, // Ratio pour la taille des cartes
                  children: [
                    _buildStatCard(
                      'Produits Vendus',
                      stats.totalSold.toString(),
                      Icons.shopping_cart,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'Produits Entrés',
                      stats.totalEntered.toString(),
                      Icons.inventory,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Chiffre d\'Affaires',
                      '${stats.revenue.toStringAsFixed(0)} F', // Formatage du revenu
                      Icons.attach_money,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'Taux de Vente',
                      '${(stats.totalSold / stats.totalEntered * 100).toStringAsFixed(1)} %',
                      Icons.trending_up,
                      Colors.purple,
                    ),
                  ],
                ),
              ],
            );
          }

          // Cas par défaut (ne devrait pas être atteint)
          return const Center(child: Text("Aucune donnée disponible."));
        },
      ),
    );
  }

  // Widget pour la carte d'informations du produit
  Widget _buildInfoCard(int stockRestant) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Prix de vente : ${widget.product.price} F",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Stock Actuel", style: TextStyle(fontSize: 16)),
                Text(
                  stockRestant.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _getQuantityColor(stockRestant),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour une carte de statistique individuelle
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const Spacer(),
            Text(
              title,
              style: TextStyle(color: color, fontSize: 14),
            ),
            Text(
              value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour la couleur du stock (réutilisée)
  Color _getQuantityColor(int qty) {
    if (qty <= 5) return Colors.red;
    if (qty <= 15) return Colors.orange;
    return Colors.green;
  }
}
