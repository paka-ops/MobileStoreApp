import 'package:flutter/material.dart';
import 'package:mobile_store_app/models/employer.dart';
import 'package:mobile_store_app/screens/login_screen.dart';
import 'package:mobile_store_app/service/employer_service.dart';
import 'package:mobile_store_app/utils/message.dart';
import 'package:mobile_store_app/utils/app_colors.dart' show DashColors;
import 'package:mobile_store_app/widgets/boutika_loader.dart';

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
    
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
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
                    colorScheme: Theme.of(context).colorScheme.copyWith(primary: colors.primary),
                  ),
                  child: Stepper(
                    type: StepperType.horizontal,
                    elevation: 0,
                    currentStep: _currentStep,
                    onStepContinue: _handleNext,
                    onStepCancel: _handleBack,
                    controlsBuilder: (context, details) => _buildStepControls(context, details, colors),
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

  Widget _buildHeader(DashColors colors) {
    return Column(
      children: [
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
        const SizedBox(height: 15),
        Text(
          "Créer votre compte",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: colors.textPrimary),
        ),
        Text(
          "Complétez les étapes pour commencer",
          style: TextStyle(color: colors.textSecondary, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(DashColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: index <= _currentStep ? colors.primary : colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  List<Step> _buildSteps(DashColors colors) {
    return [
      Step(
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        isActive: _currentStep >= 0,
        title: Text("Identité", style: TextStyle(fontSize: 12, color: _currentStep == 0 ? colors.primary : colors.textSecondary)),
        content: Column(
          children: [
            TextFormField(
              controller: lastnameController,
              decoration: _inputStyle("Nom", Icons.person_outline, colors),
              validator: (v) => v!.isEmpty ? "Champ requis" : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: firstnameController,
              decoration: _inputStyle("Prénom", Icons.person_outline, colors),
              validator: (v) => v!.isEmpty ? "Champ requis" : null,
            ),
          ],
        ),
      ),
      Step(
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        isActive: _currentStep >= 1,
        title: Text("Contact", style: TextStyle(fontSize: 12, color: _currentStep == 1 ? colors.primary : colors.textSecondary)),
        content: Column(
          children: [
            TextFormField(
              controller: usernameController,
              decoration: _inputStyle("Nom d'utilisateur", Icons.alternate_email, colors),
              validator: (v) => v!.isEmpty ? "Champ requis" : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputStyle("Téléphone", Icons.phone_outlined, colors),
              validator: (v) => v!.isEmpty ? "Champ requis" : null,
            ),
          ],
        ),
      ),
      Step(
        isActive: _currentStep >= 2,
        title: Text("Sécurité", style: TextStyle(fontSize: 12, color: _currentStep == 2 ? colors.primary : colors.textSecondary)),
        content: Column(
          children: [
            TextFormField(
              controller: passwordController,
              obscureText: _isObscured,
              decoration: _inputStyle("Mot de passe", Icons.lock_outline, colors).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility, color: colors.textSecondary),
                  onPressed: () => setState(() => _isObscured = !_isObscured),
                ),
              ),
              validator: (v) => v!.length < 4 ? "4 caractères minimum" : null,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: _isConfirmObscured,
              decoration: _inputStyle("Confirmer mot de passe", Icons.lock_reset, colors).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(_isConfirmObscured ? Icons.visibility_off : Icons.visibility, color: colors.textSecondary),
                  onPressed: () => setState(() => _isConfirmObscured = !_isConfirmObscured),
                ),
              ),
              validator: (v) => v != passwordController.text ? "Les mots de passe diffèrent" : null,
            ),
            const SizedBox(height: 10),
            Text(
              "Assurez-vous que les mots de passe correspondent",
              style: TextStyle(fontSize: 11, color: colors.textSecondary),
            )
          ],
        ),
      ),
    ];
  }

  Widget _buildStepControls(BuildContext context, ControlsDetails details, DashColors colors) {
    bool isLastStep = _currentStep == 2;

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
                  side: BorderSide(color: colors.border, width: 1.1),
                  foregroundColor: colors.textPrimary,
                  backgroundColor: colors.card,
                ),
                child: const Text("Retour", style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : details.onStepContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const BouTikaLoader.compact()
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
        SnackBar(
          content: const Text("Veuillez remplir tous les champs de cette étape"),
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
    bool isCreated = await employerService.createEmployer(employerMap, context);
    if (mounted) setState(() => _isLoading = false);

    if (isCreated == true) {
      showSuccessMessage("Compte creer avec success", context);
      Future.delayed(const Duration(seconds: 3), () => Navigator.pushNamed(context, "/login"));
    }
  }
}
