import 'package:flutter/material.dart';
import 'package:mobile_store_app/screens/store_page.dart';
import 'package:mobile_store_app/service/store_service.dart';
import '../models/Store.dart';

class StoreItem extends StatefulWidget {
  final Store store;
  const StoreItem({super.key, required this.store});

  @override
  _StoreItemState createState() => _StoreItemState();
}

class _StoreItemState extends State<StoreItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async{
        StoreService storeService = new StoreService();
        Store? store = await storeService.getStore(widget.store.id);
        if(store != null){
          Navigator.push(context, MaterialPageRoute(builder: (context)=> StoreDetailScreen(store: store)));
        }

      },
      child: Container(
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
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- BANNIÈRE BLEUE COMPACTE ---
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
                            widget.store.location?? "Adresse non renseignée",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${widget.store.productIds?.length ?? 0} Produits",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blueAccent,
                            fontSize: 13,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "Ouvert",
                            style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
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
    );
  }
}