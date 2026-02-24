

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/Store.dart';

class WelcomePreLoginScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _WelcomeState();
}

class _WelcomeState extends State<WelcomePreLoginScreen>{
  final mockStore = Store(
    id: "1ER",
    name: 'Boutique E-Gestion Lomé',
    location: '123 Rue de la Révolution, Quartier Adidogomé',
    employerId: 'emp-99',
    productIds: ['prod-1', 'prod-2', 'prod-3', 'prod-4'],
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(



      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Se connecter", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the next screen or perform any action
                  Navigator.pushNamed(context, "/login");
                },
                child: Text("Get Started"),
              ),
            ],
          ),
        ),
      ),
      drawer: Drawer(

      ),
    );
  }

}