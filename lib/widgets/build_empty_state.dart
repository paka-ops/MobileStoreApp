import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BuildEmptyState extends StatelessWidget{
  final String message;
  const BuildEmptyState({required this.message});
  @override
  Widget build(BuildContext context){
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
