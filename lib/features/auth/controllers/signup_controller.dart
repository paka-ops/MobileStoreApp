import 'package:flutter/material.dart';

import 'package:mobile_store_app/shared/services/employer_service.dart';

/// Action résultant du bouton « Suivant » / « Terminer l'inscription ».
enum SignupStepAction {
  /// Aucune action (cas non atteint, conservé pour exhaustivité).
  none,

  /// L'étape courante est valide : le parcours avance d'un cran.
  advance,

  /// Dernière étape valide : l'inscription doit être envoyée.
  submit,

  /// Étape incomplète : l'écran affiche le message d'aide.
  blocked,
}

/// ============================================================================
/// SIGNUP CONTROLLER — logique du parcours de création de compte employeur.
///
/// Responsabilités (identiques à l'implémentation d'origine) :
///   1. conserver les six champs, l'étape courante et les deux bascules
///      d'affichage des mots de passe
///   2. valider chaque étape (règles exactes : champs requis, mot de passe
///      ≥ 4 caractères, confirmation identique)
///   3. envoyer la requête `POST /v1/employers` avec les cinq champs
///      (firstname, lastname, username, password, phone)
///
/// `formKey` reste unique et partagée entre les trois étapes : c'est elle qui
/// permet à `validate()` de ne contrôler que les champs montés.
///
/// **Comportement hérité conservé** : pendant l'inscription, l'état de
/// chargement est relâché automatiquement au bout de 7 secondes, exactement
/// comme le faisait le `controlsBuilder` d'origine. Le minuteur est simplement
/// déplacé du `build()` vers le contrôleur (même délai, même effet).
/// ============================================================================
class SignupController extends ChangeNotifier {
  SignupController({EmployerService? employerService})
      : _employerService = employerService ?? EmployerService();

  final EmployerService _employerService;

  /// Clé du formulaire partagée par les trois étapes.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  int _currentStep = 0;
  bool _isLoading = false;
  bool _isObscured = true;
  bool _isConfirmObscured = true;
  bool _disposed = false;

  /// Étape affichée (0 : identité, 1 : contact, 2 : sécurité).
  int get currentStep => _currentStep;

  /// `true` pendant l'envoi de l'inscription.
  bool get isLoading => _isLoading;

  /// `true` tant que le mot de passe est masqué.
  bool get isObscured => _isObscured;

  /// `true` tant que la confirmation est masquée.
  bool get isConfirmObscured => _isConfirmObscured;

  /// Bascule l'affichage du mot de passe.
  void toggleObscured() {
    _isObscured = !_isObscured;
    notifyListeners();
  }

  /// Bascule l'affichage de la confirmation.
  void toggleConfirmObscured() {
    _isConfirmObscured = !_isConfirmObscured;
    notifyListeners();
  }

  /// Valide l'étape courante et décide de la suite du parcours.
  SignupStepAction next() {
    bool isStepValid = false;

    if (_currentStep == 0) {
      if (lastnameController.text.isNotEmpty &&
          firstnameController.text.isNotEmpty) {
        isStepValid = true;
      } else {
        formKey.currentState!.validate();
      }
    } else if (_currentStep == 1) {
      if (usernameController.text.isNotEmpty &&
          phoneController.text.isNotEmpty) {
        isStepValid = true;
      } else {
        formKey.currentState!.validate();
      }
    } else if (_currentStep == 2) {
      if (formKey.currentState!.validate()) {
        isStepValid = true;
      }
    }

    if (!isStepValid) return SignupStepAction.blocked;

    if (_currentStep < 2) {
      _currentStep += 1;
      notifyListeners();
      return SignupStepAction.advance;
    }
    return SignupStepAction.submit;
  }

  /// Revient à l'étape précédente (sans effet sur la première).
  void back() {
    if (_currentStep <= 0) return;
    _currentStep -= 1;
    notifyListeners();
  }

  /// Envoie l'inscription. Retourne `true` si le compte a été créé.
  Future<bool> submit(BuildContext context) async {
    _setLoading(true);
    _scheduleLoadingAutoReset();

    final Map<String, dynamic> employerMap = <String, dynamic>{};
    employerMap.putIfAbsent("firstname", () => firstnameController.text);
    employerMap.putIfAbsent("lastname", () => lastnameController.text);
    employerMap.putIfAbsent("username", () => usernameController.text);
    employerMap.putIfAbsent("password", () => passwordController.text);
    employerMap.putIfAbsent("phone", () => phoneController.text);

    final bool isCreated =
        await _employerService.createEmployer(employerMap, context);

    _setLoading(false);
    return isCreated;
  }

  /// Relâche le chargement après 7 s si l'appel réseau n'a pas répondu.
  void _scheduleLoadingAutoReset() {
    Future<void>.delayed(const Duration(seconds: 7), () {
      if (_disposed) return;
      _setLoading(false);
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    lastnameController.dispose();
    firstnameController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
