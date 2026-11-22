import 'package:flutter/material.dart';

import 'package:mobile_store_app/models/Store.dart';
import 'package:mobile_store_app/service/store_service.dart';
import 'package:mobile_store_app/service/user_service.dart';

/// Résultat d'une tentative de connexion.
///
///   • `success = true`  → session ouverte + boutiques chargées
///   • `success = false` → identifiants refusés (message « Identifiants
///     incorrects »)
class LoginResult {
  final bool success;
  final List<Store> stores;
  final String userType;

  const LoginResult({
    required this.success,
    this.stores = const <Store>[],
    this.userType = '',
  });

  /// Identifiants refusés.
  const LoginResult.invalid()
      : success = false,
        stores = const <Store>[],
        userType = '';

  /// Session ouverte.
  const LoginResult.authenticated({
    required this.stores,
    required this.userType,
  }) : success = true;
}

/// ============================================================================
/// LOGIN CONTROLLER — logique de l'écran de connexion.
///
/// Responsabilités (identiques à l'implémentation d'origine) :
///   1. conserver la saisie (identifiant / mot de passe) et l'état du formulaire
///   2. gérer l'état « mot de passe masqué » et l'état de chargement
///   3. appeler `UserService.login` puis `StoreService.getStoresByUser`
///   4. restituer un [LoginResult] à l'écran, qui seul navigue et affiche
///      les messages
///
/// Le `try/finally` de l'original est conservé : l'état de chargement est
/// toujours relâché, y compris si le service lève une exception (le service a
/// déjà affiché le message réseau, et l'exception continue de remonter comme
/// avant).
/// ============================================================================
class LoginController extends ChangeNotifier {
  LoginController({
    UserService? userService,
    StoreService? storeService,
  })  : _userService = userService ?? UserService(),
        _storeService = storeService ?? StoreService();

  final UserService _userService;
  final StoreService _storeService;

  /// Clé du formulaire (attachée au `Form`, comme auparavant).
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isObscured = true;
  bool _isLoading = false;
  bool _disposed = false;

  /// `true` tant que le mot de passe est masqué.
  bool get isObscured => _isObscured;

  /// `true` pendant l'appel réseau : les champs et le bouton sont désactivés.
  bool get isLoading => _isLoading;

  /// Bascule l'affichage du mot de passe.
  void toggleObscured() {
    _isObscured = !_isObscured;
    notifyListeners();
  }

  /// Tente la connexion.
  ///
  /// Retourne `null` si une tentative est déjà en cours (le bouton est
  /// désactivé dans ce cas, exactement comme auparavant).
  Future<LoginResult?> submit(BuildContext context) async {
    if (_isLoading) return null;

    _setLoading(true);
    try {
      final bool authenticated = await _userService.login(
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
        context: context,
      );

      // Garde d'usage du contexte : si l'écran a disparu pendant l'appel,
      // la tentative est abandonnée (l'appelant ne navigue pas).
      if (!context.mounted) return null;

      if (!authenticated) return const LoginResult.invalid();

      final List<Store> stores =
          await _storeService.getStoresByUser(context);

      if (!context.mounted) return null;

      return LoginResult.authenticated(
        stores: stores,
        userType: UserService.userType ?? '',
      );
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
