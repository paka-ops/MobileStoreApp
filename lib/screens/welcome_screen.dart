import 'package:flutter/material.dart';
import '../widgets/store_item.dart';
import '../models/Store.dart';

class WelcomeScreen extends StatefulWidget {
  List<Store> stores;
  WelcomeScreen({required this.stores});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

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
    );
  }
}