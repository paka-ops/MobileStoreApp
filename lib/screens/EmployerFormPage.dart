import 'package:flutter/material.dart';
import 'package:mobile_store_app/models/employer.dart';
import 'package:mobile_store_app/screens/login_screen.dart';
import 'package:mobile_store_app/service/employer_service.dart';
import 'package:mobile_store_app/utils/message.dart';

// ---------------------------------------------------------------------
// PALETTE — désaturée, confortable pour de longues sessions de travail
// ---------------------------------------------------------------------
class AppColors {
  static const primary = Color(0xFF4A7C82);       // teal désaturé, doux
  static const primarySoft = Color(0xFFEBF2F2);
  static const accent = Color(0xFFC08552);         // terracotta doux (dépenses/alertes)
  static const accentSoft = Color(0xFFF6ECE3);
  static const danger = Color(0xFFC96B6B);
  static const success = Color(0xFF6FA687);

  static const background = Color(0xFFF7F8FA);
  static const card = Colors.white;
  static const border = Color(0xFFEDEEF2);

  static const textDark = Color(0xFF2E333D);
  static const textGrey = Color(0xFF95999E);
}

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

  // Style commun pour les champs — aligné sur le design global
  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressIndicator(),
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.primary),
                  ),
                  child: Stepper(
                    type: StepperType.horizontal,
                    elevation: 0,
                    currentStep: _currentStep,
                    onStepContinue: _handleNext,
                    onStepCancel: _handleBack,
                    controlsBuilder: _buildStepControls,
                    steps: _buildSteps(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 120,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              "BouTiKa",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          "Créer votre compte",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textDark),
        ),
        const Text(
          "Complétez les étapes pour commencer",
          style: TextStyle(color: AppColors.textGrey, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: index <= _currentStep ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  List<Step> _buildSteps() {
    return [
      Step(
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        isActive: _currentStep >= 0,
        title: Text("Identité", style: TextStyle(fontSize: 12, color: _currentStep == 0 ? AppColors.primary : AppColors.textGrey)),
        content: Column(
          children: [
            TextFormField(
              controller: lastnameController,
              decoration: _inputStyle("Nom", Icons.person_outline),
              validator: (v) => v!.isEmpty ? "Champ requis" : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: firstnameController,
              decoration: _inputStyle("Prénom", Icons.person_outline),
              validator: (v) => v!.isEmpty ? "Champ requis" : null,
            ),
          ],
        ),
      ),
      Step(
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        isActive: _currentStep >= 1,
        title: Text("Contact", style: TextStyle(fontSize: 12, color: _currentStep == 1 ? AppColors.primary : AppColors.textGrey)),
        content: Column(
          children: [
            TextFormField(
              controller: usernameController,
              decoration: _inputStyle("Nom d'utilisateur", Icons.alternate_email),
              validator: (v) => v!.isEmpty ? "Champ requis" : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputStyle("Téléphone", Icons.phone_outlined),
              validator: (v) => v!.isEmpty ? "Champ requis" : null,
            ),
          ],
        ),
      ),
      Step(
        isActive: _currentStep >= 2,
        title: Text("Sécurité", style: TextStyle(fontSize: 12, color: _currentStep == 2 ? AppColors.primary : AppColors.textGrey)),
        content: Column(
          children: [
            TextFormField(
              controller: passwordController,
              obscureText: _isObscured,
              decoration: _inputStyle("Mot de passe", Icons.lock_outline).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility, color: AppColors.textGrey),
                  onPressed: () => setState(() => _isObscured = !_isObscured),
                ),
              ),
              validator: (v) => v!.length < 4 ? "4 caractères minimum" : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: _isConfirmObscured,
              decoration: _inputStyle("Confirmer mot de passe", Icons.lock_reset).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(_isConfirmObscured ? Icons.visibility_off : Icons.visibility, color: AppColors.textGrey),
                  onPressed: () => setState(() => _isConfirmObscured = !_isConfirmObscured),
                ),
              ),
              validator: (v) => v != passwordController.text ? "Les mots de passe diffèrent" : null,
            ),
            const SizedBox(height: 10),
            const Text(
              "Assurez-vous que les mots de passe correspondent",
              style: TextStyle(fontSize: 11, color: AppColors.textGrey),
            )
          ],
        ),
      ),
    ];
  }

  Widget _buildStepControls(BuildContext context, ControlsDetails details) {
    bool isLastStep = _currentStep == 2;

    // Conserve la logique originale mais adaptée au style
    _isLoading == true ? Future.delayed(const Duration(seconds: 7), () {
      setState(() {
        _isLoading = false;
      });
    }) : null;

    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: details.onStepCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: AppColors.border, width: 1.1),
                  foregroundColor: AppColors.textDark,
                  backgroundColor: AppColors.card,
                ),
                child: const Text("Retour", style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : details.onStepContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(isLastStep ? "Terminer l'inscription" : "Suivant", style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext() {
    bool isStepValid = false;

    if (_currentStep == 0) {
      if (lastnameController.text.isNotEmpty && firstnameController.text.isNotEmpty) {
        isStepValid = true;
      } else {
        _formKey.currentState!.validate();
      }
    } else if (_currentStep == 1) {
      if (usernameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
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
        const SnackBar(
          content: Text("Veuillez remplir tous les champs de cette étape"),
          backgroundColor: AppColors.danger,
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
    bool isCreated = await employerService.createEmployer(employerMap, context);
    if (mounted) setState(() => _isLoading = false);

    if (isCreated == true) {
      showSuccessMessage("Compte creer avec success", context);
      Future.delayed(const Duration(seconds: 3), () => Navigator.pushNamed(context, "/login"));
    }
  }
}