import 'package:flutter/material.dart';
import 'package:mobile_store_app/models/employer.dart';
import 'package:mobile_store_app/screens/login_screen.dart';
import 'package:mobile_store_app/service/employer_service.dart';
import 'package:mobile_store_app/utils/message.dart';
import 'package:mobile_store_app/utils/app_colors.dart'
    show DashColors, PremiumRadii;
import 'package:mobile_store_app/widgets/boutika_loader.dart';

// =====================================================================
// INSCRIPTION EMPLOYEUR — visuel « BouTika Premium »
// ---------------------------------------------------------------------
// LOGIQUE INCHANGÉE : étapes, validations, navigation avant/arrière et
// soumission `_submitForm` strictement identiques. Seule la présentation
// change (médaillon, progression animée, contrôles 52 px).
// =====================================================================
class EmployerFormPage extends StatefulWidget {
  const EmployerFormPage({super.key});

  @override
  State<EmployerFormPage> createState() => _EmployerFormPageState();
}

class _EmployerFormPageState extends State<EmployerFormPage> {
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isObscured = true;
  bool _isConfirmObscured = true;

  // Controllers
  final _formKey = GlobalKey<FormState>();
  final lastnameController = TextEditingController();
  final firstnameController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    lastnameController.dispose();
    firstnameController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Style des champs — même signature, rendu premium (focus émeraude).
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
      contentPadding:
          const EdgeInsets.symmetric(vertical: 17, horizontal: 16),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PremiumRadii.input),
        borderSide: BorderSide(color: colors.danger, width: 1.3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = DashColors(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Container(
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(PremiumRadii.sm),
              border: Border.all(color: colors.border, width: 1),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: colors.textPrimary,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildHeader(colors),
              _buildProgressIndicator(colors),
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context)
                        .colorScheme
                        .copyWith(primary: colors.primary),
                  ),
                  child: Stepper(
                    type: StepperType.horizontal,
                    elevation: 0,
                    currentStep: _currentStep,
                    onStepContinue: _handleNext,
                    onStepCancel: _handleBack,
                    controlsBuilder: (context, details) =>
                        _buildStepControls(context, details, colors),
                    steps: _buildSteps(colors),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // En-tête — médaillon dégradé + titres hiérarchisés.
  Widget _buildHeader(DashColors colors) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: colors.primaryGradient,
            borderRadius: BorderRadius.circular(PremiumRadii.md),
            boxShadow: colors.glowShadow,
          ),
          child: const Icon(
            Icons.storefront_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          "Créer votre compte",
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Complétez les étapes pour commencer",
          style: TextStyle(color: colors.textSecondary, fontSize: 13),
        ),
      ],
    );
  }

  // Progression — barres animées (même index `_currentStep`).
  Widget _buildProgressIndicator(DashColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 20, 40, 8),
      child: Column(
        children: [
          Row(
            children: List.generate(3, (index) {
              final reached = index <= _currentStep;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: reached ? colors.primary : colors.border,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: reached ? colors.glowShadow : null,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          Text(
            "Étape ${_currentStep + 1} sur 3",
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Étapes — champs, contrôleurs et validateurs strictement inchangés.
  List<Step> _buildSteps(DashColors colors) {
    TextStyle stepTitle(bool active) => TextStyle(
          fontSize: 12,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          color: active ? colors.primary : colors.textSecondary,
        );

    return [
      Step(
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        isActive: _currentStep >= 0,
        title: Text("Identité", style: stepTitle(_currentStep == 0)),
        content: Column(
          children: [
            TextFormField(
              controller: lastnameController,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14.5,
              ),
              decoration: _inputStyle("Nom", Icons.person_outline, colors),
              validator: (v) => v!.isEmpty ? "Champ requis" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: firstnameController,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14.5,
              ),
              decoration:
                  _inputStyle("Prénom", Icons.person_outline, colors),
              validator: (v) => v!.isEmpty ? "Champ requis" : null,
            ),
          ],
        ),
      ),
      Step(
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        isActive: _currentStep >= 1,
        title: Text("Contact", style: stepTitle(_currentStep == 1)),
        content: Column(
          children: [
            TextFormField(
              controller: usernameController,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14.5,
              ),
              decoration: _inputStyle(
                  "Nom d'utilisateur", Icons.alternate_email, colors),
              validator: (v) => v!.isEmpty ? "Champ requis" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14.5,
              ),
              decoration:
                  _inputStyle("Téléphone", Icons.phone_outlined, colors),
              validator: (v) => v!.isEmpty ? "Champ requis" : null,
            ),
          ],
        ),
      ),
      Step(
        isActive: _currentStep >= 2,
        title: Text("Sécurité", style: stepTitle(_currentStep == 2)),
        content: Column(
          children: [
            TextFormField(
              controller: passwordController,
              obscureText: _isObscured,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14.5,
              ),
              decoration:
                  _inputStyle("Mot de passe", Icons.lock_outline, colors)
                      .copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                      _isObscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: colors.textSecondary),
                  onPressed: () =>
                      setState(() => _isObscured = !_isObscured),
                ),
              ),
              validator: (v) =>
                  v!.length < 4 ? "4 caractères minimum" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: _isConfirmObscured,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14.5,
              ),
              decoration: _inputStyle(
                      "Confirmer mot de passe", Icons.lock_reset, colors)
                  .copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                      _isConfirmObscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: colors.textSecondary),
                  onPressed: () => setState(
                      () => _isConfirmObscured = !_isConfirmObscured),
                ),
              ),
              validator: (v) => v != passwordController.text
                  ? "Les mots de passe diffèrent"
                  : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: colors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Assurez-vous que les mots de passe correspondent",
                    style: TextStyle(
                        fontSize: 12, color: colors.textSecondary),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ];
  }

  // Contrôles d'étape — logique d'origine conservée, boutons 52 px.
  Widget _buildStepControls(
      BuildContext context, ControlsDetails details, DashColors colors) {
    bool isLastStep = _currentStep == 2;

    _isLoading == true
        ? Future.delayed(const Duration(seconds: 7), () {
            setState(() {
              _isLoading = false;
            });
          })
        : null;

    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: details.onStepCancel,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: colors.card,
                    foregroundColor: colors.textPrimary,
                    side: BorderSide(color: colors.border, width: 1.2),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(PremiumRadii.input)),
                  ),
                  child: const Text("Retour",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(PremiumRadii.input),
                  boxShadow:
                      _isLoading ? null : colors.glowShadow,
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(PremiumRadii.input)),
                  ),
                  child: _isLoading
                      ? const BouTikaLoader.compact()
                      : Text(
                          isLastStep
                              ? "Terminer l'inscription"
                              : "Suivant",
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14.5),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext() {
    bool isStepValid = false;

    if (_currentStep == 0) {
      if (lastnameController.text.isNotEmpty &&
          firstnameController.text.isNotEmpty) {
        isStepValid = true;
      } else {
        _formKey.currentState!.validate();
      }
    } else if (_currentStep == 1) {
      if (usernameController.text.isNotEmpty &&
          phoneController.text.isNotEmpty) {
        isStepValid = true;
      } else {
        _formKey.currentState!.validate();
      }
    } else if (_currentStep == 2) {
      if (_formKey.currentState!.validate()) {
        isStepValid = true;
      }
    }

    if (isStepValid) {
      if (_currentStep < 2) {
        setState(() => _currentStep += 1);
      } else {
        _submitForm();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text("Veuillez remplir tous les champs de cette étape"),
          backgroundColor: DashColors(context).danger,
        ),
      );
    }
  }

  void _handleBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  Future<void> _submitForm() async {
    setState(() => _isLoading = true);
    Map<String, dynamic> employerMap = {};
    employerMap.putIfAbsent("firstname", () => firstnameController.text);
    employerMap.putIfAbsent("lastname", () => lastnameController.text);
    employerMap.putIfAbsent("username", () => usernameController.text);
    employerMap.putIfAbsent("password", () => passwordController.text);
    employerMap.putIfAbsent("phone", () => phoneController.text);

    EmployerService employerService = EmployerService();
    bool isCreated =
        await employerService.createEmployer(employerMap, context);
    if (mounted) setState(() => _isLoading = false);

    if (isCreated == true) {
      showSuccessMessage("Compte creer avec success", context);
      Future.delayed(const Duration(seconds: 3), () => Navigator.pushNamed(context, "/login"));
    }
  }
}
