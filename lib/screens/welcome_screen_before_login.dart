import 'package:flutter/material.dart';
import 'package:mobile_store_app/screens/EmployerFormPage.dart';

class WelcomePreLoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WelcomeState();
}

class _WelcomeState extends State<WelcomePreLoginScreen> {
  @override
  Widget build(BuildContext context) {
    // Récupération du violet de ton thème (Get Started)
    final Color themePurple = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5, // Une très légère ombre pour séparer du corps
        centerTitle: false, // Aligné à gauche
        toolbarHeight: 70, // On augmente un peu la hauteur pour tout caser
        title: Row(
          children: [
            // --- 1. LE LOGO (Petit format pour l'AppBar) ---
            Image.asset(
              'assets/images/boutika.png',
              height: 45, // Taille idéale pour une barre de navigation
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12), // Espace entre le logo et le texte

            // --- 2. TEXTES (Nom + Slogan) ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "BouTiKa",
                  style: TextStyle(
                    color: themePurple, // Ton beau violet
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  "ma boutique autrement",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                    fontWeight: FontWeight.normal,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [TextButton(onPressed: (){Navigator.push(context,MaterialPageRoute(builder: (context)=>EmployerFormPage()));}, child: Text("Creer un compte"),)],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // L'espace central est maintenant plus aéré
              Icon(
                Icons.storefront_outlined, // Une icône de secours ou une illustration
                size: 100,
                color: themePurple.withOpacity(0.2),
              ),
              const SizedBox(height: 40),

              Text(
                "Bienvenue",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Prêt à gérer votre stock ?",
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 60),

              // --- TON BOUTON VIOLET ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, "/login"),
                  child: Text(
                    "Se connecter",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}