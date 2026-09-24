import 'package:flutter/material.dart';
import 'package:mobile_store_app/core/widgets/inputs/app_text_field.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/widgets/navigation/app_header.dart';
import 'package:mobile_store_app/models/Store.dart';
import 'package:mobile_store_app/screens/welcome_screen.dart';
import 'package:mobile_store_app/service/store_service.dart';
import 'package:mobile_store_app/service/user_service.dart';
import 'package:mobile_store_app/utils/app_colors.dart' show DashColors;
import 'package:mobile_store_app/utils/message.dart';
import 'package:mobile_store_app/widgets/design_system.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = DashColors(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Marque
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: colors.primarySoft,
                    shape: BoxShape.circle,
                    boxShadow: colors.cardShadow,
                  ),
                  child: Icon(
                    Icons.storefront_rounded,
                    color: colors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 18),
                const AppBrandMark(),
                const SizedBox(height: 34),

                // Titres
                Text(
                  "Connexion",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h2.copyWith(color: colors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  "Entrez vos identifiants pour accéder à votre boutique",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),

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

  @override
  Widget build(BuildContext context) {
    final colors = DashColors(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextField(
            controller: usernameController,
            enabled: !_isLoading,
            label: "Nom d'utilisateur",
            hint: "Ex: jean.dupont",
            icon: Icons.person_outline,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: passwordController,
            enabled: !_isLoading,
            obscure: _isObscured,
            label: "Mot de passe",
            icon: Icons.lock_outline,
            suffix: IconButton(
              icon: Icon(
                _isObscured ? Icons.visibility_off : Icons.visibility,
                color: colors.textSecondary,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _isObscured = !_isObscured;
                });
              },
            ),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: "Se connecter",
            icon: Icons.login_rounded,
            isLoading: _isLoading,
            onPressed: _handleLogin,
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
