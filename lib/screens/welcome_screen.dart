import 'package:flutter/material.dart';
import 'package:mobile_store_app/service/store_service.dart';
import '../widgets/store_item.dart';
import '../models/Store.dart';

class WelcomeScreen extends StatefulWidget {
  List<Store> stores;
  WelcomeScreen({required this.stores});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  TextEditingController _storeNameController = TextEditingController();
  TextEditingController _storeAddressController = TextEditingController();
  final _storeFormKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    List<Store> stores = widget.stores;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Mes Boutiques'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.4, // Ratio ajusté pour éviter le débordement
              ),
              itemCount: stores.length,
              itemBuilder: (context, index) => StoreItem(store: stores[index]),
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: stores.length,
              itemBuilder: (context, index) => StoreItem(store: stores[index]),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          return _showAddStoreForm(context);
        },
        child: const Icon(Icons.add, color: Colors.white),

      ),
    );
  }
  void _showAddStoreForm(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
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
              Navigator.pop(context);
            },
            child: const Text("Annuler", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () async {
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
                  Store? store = await storeService.addStore(storeData);
                  if(store!=null) {
                    setState(() {
                      widget.stores.add(store);
                    });
                  }

                  Navigator.pop(context);
                  _storeNameController.clear();
                  _storeAddressController.clear();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Boutique créée avec succès !")),
                  );
                } catch (e) {
                  print("Erreur lors de l'ajout: $e");
                }
              }
            },
            child: const Text("Créer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}