import 'package:flutter/material.dart';
import 'package:mobile_store_app/models/Store.dart';
import 'package:mobile_store_app/screens/welcome_screen.dart';
import 'package:mobile_store_app/service/store_service.dart';
import 'package:mobile_store_app/service/user_service.dart';
import 'package:mobile_store_app/utils/message.dart';
import 'package:mobile_store_app/utils/app_colors.dart'
    show DashColors, PremiumGap, PremiumRadii;
import 'package:mobile_store_app/widgets/boutika_loader.dart';
import 'package:mobile_store_app/widgets/premium_kit.dart';

// =====================================================================
// CONNEXION — visuel « BouTika Premium »
// ---------------------------------------------------------------------
// LOGIQUE INCHANGÉE : contrôleurs, états de chargement, callbacks et
// appel API `_handleLogin` strictement identiques. Seule la couche
// visuelle est repensée (halo apaisant, carte feutrée, CTA émeraude).
// =====================================================================
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Halo décoratif apaisant (voile émeraude diffus) ──
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 168,
                      height: 168,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            colors.primary.withOpacity(0.16),
                            colors.primary.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                    // Médaillon de marque : dégradé émeraude, ombre douce.
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        gradient: colors.primaryGradient,
                        borderRadius:
                            BorderRadius.circular(PremiumRadii.lg),
                        boxShadow: colors.glowShadow,
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Wordmark ──
                Text(
                  'BouTiKa',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'ma boutique autrement',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Carte de connexion feutrée ──
                PremiumCard(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bon retour 👋',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Connectez-vous pour piloter votre boutique.',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 13.5,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Formulaire — logique strictement inchangée.
                      const LoginPage(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Mention de confiance discrète ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 13,
                      color: colors.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Connexion sécurisée',
                      style: TextStyle(
                        color: colors.textTertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                PremiumGap.mdH,
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

  // Style des champs — même signature, rendu premium (48 px+, focus doux).
  InputDecoration _inputStyle(String label, IconData icon, DashColors colors) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: colors.textSecondary, fontSize: 14),
      floatingLabelStyle: TextStyle(
        color: colors.primary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(icon, color: colors.primary, size: 20),
      filled: true,
      fillColor: colors.fieldFill,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 17,
        horizontal: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PremiumRadii.input),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PremiumRadii.input),
        borderSide: BorderSide(color: colors.border, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PremiumRadii.input),
        borderSide: BorderSide(color: colors.primary, width: 1.6),
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
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14.5,
            ),
            decoration: _inputStyle(
              "Nom d'utilisateur",
              Icons.person_outline_rounded,
              colors,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: passwordController,
            enabled: !_isLoading,
            obscureText: _isObscured,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14.5,
            ),
            decoration: _inputStyle(
              'Mot de passe',
              Icons.lock_outline_rounded,
              colors,
            ).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
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
          ),
          const SizedBox(height: 24),
          // CTA émeraude avec halo — même callback `_handleLogin`.
          PremiumPrimaryButton(
            label: 'Se connecter',
            icon: _isLoading ? null : Icons.login_rounded,
            onPressed: _isLoading ? null : _handleLogin,
            loadingWidget: _isLoading
                ? const BouTikaLoader.compact()
                : null,
          ),
        ],
      ),
    );
  }

  // LOGIQUE MÉTIER INCHANGÉE — appel API et navigation identiques.
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
