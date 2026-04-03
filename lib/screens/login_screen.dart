import 'package:flutter/material.dart';
import 'package:mobile_store_app/models/Store.dart';
import 'package:mobile_store_app/screens/welcome_screen.dart';
import 'package:mobile_store_app/service/store_service.dart';
import 'package:mobile_store_app/service/user_service.dart';
import 'package:mobile_store_app/utils/message.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView( // Pour éviter les erreurs d'overflow avec le clavier
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 150,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.blue[50], // Un bleu léger pour rappeler ton nouveau logo
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "BouTiKa",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: LoginPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Changement en StatefulWidget pour gérer l'état de l'œil
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isObscured = true;
  bool _isLoading = false; // 🔥 Nouvelle variable pour le chargement

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: usernameController,
            enabled: !_isLoading, // Désactive le champ pendant le chargement
            decoration: const InputDecoration(
              labelText: "Username",
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: passwordController,
            enabled: !_isLoading, // Désactive le champ pendant le chargement
            obscureText: _isObscured,
            decoration: InputDecoration(
              labelText: "Password",
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: Colors.blue,
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
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              // 🔥 Désactive le bouton si _isLoading est vrai
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text("Se connecter"),
            ),
          ),
        ],
      ),
    );
  }

  // Extraction de la logique de login pour plus de clarté
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
      // On arrête le chargement même si ça échoue (sauf si on a quitté l'écran)
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}