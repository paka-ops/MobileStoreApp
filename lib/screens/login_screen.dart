import 'package:flutter/material.dart';
import 'package:mobile_store_app/models/Store.dart';
import 'package:mobile_store_app/screens/welcome_screen.dart';
import 'package:mobile_store_app/service/store_service.dart';
import 'package:mobile_store_app/service/user_service.dart';
import 'package:mobile_store_app/utils/message.dart';
import 'package:mobile_store_app/utils/app_colors.dart' show DashColors;
import 'package:mobile_store_app/widgets/boutika_loader.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = DashColors(context);
    
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo en haut
                Container(
                  width: 120,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: colors.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      "BouTiKa",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Titres de la page
                Text(
                  "Connexion",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Entrez vos identifiants pour accéder à votre boutique",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 30),

                // Formulaire
                const LoginPage(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isObscured = true;
  bool _isLoading = false;

  // Style commun pour les champs — aligné sur le design global
  InputDecoration _inputStyle(String label, IconData icon, DashColors colors) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: colors.textSecondary, fontSize: 14),
      prefixIcon: Icon(icon, color: colors.primary, size: 20),
      filled: true,
      fillColor: colors.card,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = DashColors(context);
    
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: usernameController,
            enabled: !_isLoading,
            decoration: _inputStyle("Nom d'utilisateur", Icons.person_outline, colors),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: passwordController,
            enabled: !_isLoading,
            obscureText: _isObscured,
            decoration: _inputStyle("Mot de passe", Icons.lock_outline, colors).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: colors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const BouTikaLoader.compact()
                  : const Text(
                "Se connecter",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    UserService userService = UserService();
    StoreService storeService = StoreService();
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    try {
      bool response = await userService.login(
          username: username, password: password, context: context);

      if (response == true) {
        List<Store> stores = await storeService.getStoresByUser(context);
        if (mounted) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => WelcomeScreen(
                      stores: stores,
                      userType: UserService.userType ?? ''
                  )
              )
          );
        }
      } else {
        showErrorMessage("Identifiants incorrects", context);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
