import 'package:flutter/material.dart';
import 'package:mobile_store_app/screens/EmployerFormPage.dart';
import 'package:mobile_store_app/utils/app_colors.dart' show appDarkMode, DashColors;

class WelcomePreLoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WelcomeState();
}

class _WelcomeState extends State<WelcomePreLoginScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = DashColors(context);
    
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // --- EN-TÊTE : Logo et Slogan ---
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/boutika.png',
                        height: 42,
                        width: 42,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "BouTiKa",
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          "ma boutique autrement",
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ValueListenableBuilder<bool>(
                      valueListenable: appDarkMode,
                      builder: (context, isDark, _) => IconButton(
                        tooltip: isDark ? 'Activer le thème clair' : 'Activer le thème sombre',
                        onPressed: () => appDarkMode.value = !isDark,
                        icon: Icon(
                          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // --- ZONE CENTRALE : Illustration et Message ---
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: colors.primarySoft,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.border, width: 1),
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  size: 70,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 40),

              Text(
                "Bienvenue",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Gérez votre stock, suivez vos ventes et\npilotez votre boutique en toute simplicité.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // --- ZONE D'ACTION : Boutons placés en bas pour l'ergonomie ---
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, "/login"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Se connecter",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EmployerFormPage()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: colors.card,
                    foregroundColor: colors.textPrimary,
                    elevation: 0,
                    side: BorderSide(color: colors.border, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Créer un compte",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30), // Marge en bas du téléphone
            ],
          ),
        ),
      ),
    );
  }
}
