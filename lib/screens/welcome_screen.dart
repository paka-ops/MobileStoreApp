import 'package:flutter/material.dart';
import 'package:mobile_store_app/service/store_service.dart';
import 'package:mobile_store_app/utils/message.dart';
import '../widgets/store_item.dart';
import '../models/Store.dart';

class WelcomeScreen extends StatefulWidget {
  final List<Store> stores; // Ajout de final
  final String userType;
  WelcomeScreen({required this.stores, required this.userType});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _storeAddressController = TextEditingController();
  final _storeFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Mes Boutiques'),
        centerTitle: true,
      ),
      body: widget.stores.isEmpty
          ? _buildEmptyState()
          : LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.4,
              ),
              itemCount: widget.stores.length,
              itemBuilder: (context, index) => StoreItem(
                store: widget.stores[index],
                otherStores: widget.stores,
                isDeleted: (value) {
                  if (value) {
                    setState(() {
                      widget.stores.removeAt(index);
                    });
                  }
                },
              ),
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: widget.stores.length,
              itemBuilder: (context, index) => StoreItem(
                store: widget.stores[index],
                otherStores: widget.stores,
                isDeleted: (value) {
                  if (value) {
                    setState(() {
                      widget.stores.removeAt(index);
                    });
                  }
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: (widget.userType == "employer")
          ? FloatingActionButton(
        onPressed: () => _showAddStoreForm(context),
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }

// ... (Garder tes méthodes _showAddStoreForm et _buildEmptyState telles quelles)
  void _showAddStoreForm(BuildContext context) {
    bool isLoading = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(builder: (stcontext,state){
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.store, color: Colors.blue), // Icône de boutique
              SizedBox(width: 10),
              Text("Nouvelle Boutique"),
            ],
          ),
          content: Form(
            key: _storeFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // CHAMP NOM DE LA BOUTIQUE
                TextFormField(
                  controller: _storeNameController,
                  decoration: const InputDecoration(
                    labelText: "Nom de la boutique",
                    prefixIcon: Icon(Icons.shop),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le nom est obligatoire';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                // CHAMP EMPLACEMENT (ADRESSE)
                TextFormField(
                  controller: _storeAddressController,
                  decoration: const InputDecoration(
                    labelText: "Emplacement / Adresse",
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez préciser l\'emplacement';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {

                _storeNameController.clear();
                _storeAddressController.clear();
                state((){isLoading = false;});
                Navigator.pop(context);
              },
              child: const Text("Annuler", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () async {
                state((){
                  isLoading = true;
                });
                if (_storeFormKey.currentState!.validate()) {
                  // Logique de création de l'objet Store
                  // On suppose que vous avez un StoreService
                  try {
                    // Création d'un nouvel objet Store localement ou via service
                    StoreService storeService = StoreService();
                    Map<String, dynamic> storeData = {
                      "name": _storeNameController.text,
                      "location": _storeAddressController.text,
                      "employee": null,
                      "employer":null,
                      "categories": null,
                    };
                    Store? store = await storeService.addStore(storeData,context);
                    if(mounted)state((){isLoading =false;});
                    if(store!=null) {
                      setState(() {
                        widget.stores.add(store);
                      });
                    }

                    Navigator.pop(context);
                    _storeNameController.clear();
                    _storeAddressController.clear();

                    showSuccessMessage("Boutique créée avec succès !", context);
                  } catch (e) {
                    print("Erreur lors de l'ajout: $e");
                  }
                }
              },
              child: isLoading?CircularProgressIndicator():const Text("Créer", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      }),
    );
  }
  void _showStoreDeletionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer la boutique"),
        content: const Text("Êtes-vous sûr de vouloir supprimer cette boutique ? Cette action est irréversible."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler", style: TextStyle(color: Colors.red))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              bool success = true; // Simulé pour l'instant
              Navigator.pop(context);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Boutique supprimée")));
                Navigator.pop(context); // Revenir à la liste des boutiques
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur lors de la suppression"), backgroundColor: Colors.red));
              }
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "Pas de boutique trouvé",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}