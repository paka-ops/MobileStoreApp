import 'package:flutter/material.dart';
import 'package:mobile_store_app/screens/store_page.dart';
import 'package:mobile_store_app/service/store_service.dart';
import 'package:mobile_store_app/service/user_service.dart';
import 'package:mobile_store_app/utils/message.dart';
import '../models/Store.dart';

class StoreItem extends StatefulWidget {
  Store store;
  List<Store> otherStores;
  final VoidCallback? onRefresh; // Ajouté pour rafraîchir la liste après action
  final void Function(bool value) isDeleted;
  StoreItem({super.key, required this.isDeleted, required this.store, required this.otherStores,this.onRefresh});

  @override
  _StoreItemState createState() => _StoreItemState();
}

class _StoreItemState extends State<StoreItem> {
  bool _showActions = false; // Pour basculer l'affichage des icônes d'action

  // --- DIALOGUE DE MISE À JOUR ---
  void _showUpdateDialog(BuildContext context) {
    final nameController = TextEditingController(text: widget.store.name);
    final locationController = TextEditingController(text: widget.store.location);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Modifier le magasin"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Nom")),
            TextField(controller: locationController, decoration: const InputDecoration(labelText: "Localisation")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              Map<String,dynamic> storeMap = {
                "name": nameController.text.trim(),
                "location": locationController.text.trim(),
              };
              Store store = await StoreService().updateStore(widget.store.id, storeMap,context);
              if(store != null){
                setState(() {
                  widget.store = store;
                });
              }
              Navigator.pop(context);
              if (widget.onRefresh != null) widget.onRefresh!();
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (_showActions) {
          setState(() => _showActions = false);
          return;
        }
          List<Store> otherStores = widget.otherStores;
          otherStores.remove(widget.store);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => StoreDetailScreen(
                    store: widget.store,
                    userType: UserService.userType ?? '',
                    otherStores: otherStores,
                  )));

      },
      onLongPress: () {
        setState(() {
          _showActions = !_showActions;
        });
      },
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                  color: _showActions ? Colors.blueAccent : Colors.grey.shade100,
                  width: _showActions ? 2 : 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- BANNIÈRE BLEUE ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.lightBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.store_mall_directory, size: 28, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.store.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!_showActions)
                          const Icon(Icons.verified, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                  // --- ZONE DÉTAILS ---
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.store.location ?? "Adresse non renseignée",
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- OVERLAY DES ACTIONS (MODIFIER / SUPPRIMER) ---
          if (_showActions)
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.edit,
                      label: "Modifier",
                      onTap: () {
                        setState(() => _showActions = false);
                        _showUpdateDialog(context);
                      },
                    ),
                    _buildActionButton(
                      icon: Icons.delete,
                      label: "Supprimer",
                      onTap: () {
                        setState(() => _showActions = false);
                        _showDeleteDialog(context);
                      },
                    ),
                    _buildActionButton(
                      icon: Icons.close,
                      label: "Fermer",
                      onTap: () => setState(() => _showActions = false),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- DIALOGUE DE SUPPRESSION ---
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer le magasin ?"),
        content: Text("Voulez-vous vraiment supprimer '${widget.store.name}' ? Cette action est irréversible."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          // --- Extrait du dialogue de suppression dans StoreItem.dart ---
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              // 1. Appel au service pour supprimer en base de données
              await StoreService().deleteStore(widget.store.id, context);

              if (context.mounted) {
                showSuccessMessage("Boutique ${widget.store.name} supprimée", context);
                Navigator.pop(context); // Ferme le dialogue

                // 2. C'EST ICI QUE ÇA SE JOUE : On appelle la fonction de rappel
                // pour prévenir WelcomeScreen qu'il faut retirer l'élément de la liste
                widget.isDeleted(true);
              }
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}