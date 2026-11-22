/// ============================================================================
/// ORDER VERIFICATION DIALOG — vérification de caisse avant une opération.
///
/// Reprise à l'identique des classes privées `_VerificationDialog` et
/// `_VerificationResult` : mêmes phases, mêmes textes, mêmes retours.
/// ============================================================================
import 'package:flutter/material.dart';
import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/core/widgets/inputs/app_text_field.dart';
import 'package:mobile_store_app/shared/widgets/loading/boutika_loader.dart';
import 'package:mobile_store_app/utils/message.dart';

// =====================================================================
// RÉSULTAT DE VÉRIFICATION DE CAISSE
// Valeur retournée par _effectuerOperationVerification() et affichée
// telle quelle dans le pop-up résultat.
// =====================================================================
class OrderVerificationResult {
  /// Montant saisi dans le formulaire (argent compté dans la caisse).
  final double montantCaisse;
  final double spendingAmount;
  final double withdrawalAmount;
  /// Montant calculé côté application par TON opération.
  final double montantApp;

  /// true → « Résultat normal » • false → « Résultat anormal ».
  final bool isNormal;

  const OrderVerificationResult({
    required this.montantCaisse,
    required this.montantApp,
    required this.spendingAmount,
    required this.withdrawalAmount,
    required this.isNormal,
  });


  double get ecart => (montantCaisse + spendingAmount + withdrawalAmount) - montantApp;
}
double? _parseMontant(String value) => double.tryParse(
      value.trim().replaceAll(RegExp(r'\s'), '').replaceAll(',', '.'),
    );

String _formatMontant(double montant) => "${montant.toStringAsFixed(2)} F";

/// Phases du dialog de vérification (un seul dialog, pas d'enchaînement
/// de pop-ups : voir le commentaire « Correctif stabilité » plus haut).
enum _VerificationPhase { form, loading, result }
class OrderVerificationDialog extends StatefulWidget {
  /// TON opération (méthode de l'écran) : reçoit le montant saisi et
  /// retourne le résultat à afficher.
  final Future<OrderVerificationResult> Function(double montantCaisse) onVerify;

  const OrderVerificationDialog({super.key, required this.onVerify});

  @override
  State<OrderVerificationDialog> createState() => _VerificationDialogState();
}

class _VerificationDialogState extends State<OrderVerificationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _montantController = TextEditingController();

  _VerificationPhase _phase = _VerificationPhase.form;
  OrderVerificationResult? _result;

  @override
  void dispose() {
    _montantController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------
  // Clic « Vérifier » : valide, passe en loading (rendu au moins une
  // frame), exécute l'opération, puis affiche le résultat — sans
  // jamais fermer/rouvrir de dialog entre-temps. La garde sur _phase
  // rend le double-clic sans effet.
  // -------------------------------------------------------------------
  Future<void> _submit() async {
    if (_phase != _VerificationPhase.form) return;
    if (!_formKey.currentState!.validate()) return;
    final double? montant = _parseMontant(_montantController.text);
    if (montant == null) return;

    FocusScope.of(context).unfocus();
    setState(() => _phase = _VerificationPhase.loading);

    // Laisse la phase loading être réellement dessinée avant de lancer
    // l'opération (qui peut se terminer de façon quasi synchrone).
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    try {
      final OrderVerificationResult result = await widget.onVerify(montant);
      if (!mounted) return;
      setState(() {
        _result = result;
        _phase = _VerificationPhase.result;
      });
    } catch (e) {
      debugPrint("Erreur vérification caisse: $e");
      if (!mounted) return;
      // Échec : retour au formulaire (montant conservé) pour réessayer.
      setState(() => _phase = _VerificationPhase.form);
      showErrorMessage("Échec de la vérification, réessayez", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    final bool isForm = _phase == _VerificationPhase.form;

    return PopScope(
      // Retour système bloqué pendant le loading uniquement.
      canPop: _phase != _VerificationPhase.loading,
      child: AlertDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: c.border),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: EdgeInsets.fromLTRB(24, isForm ? 16 : 24, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        title: isForm ? _buildTitle(c) : null,
        content: SingleChildScrollView(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: _buildPhaseContent(c),
          ),
        ),
        actions: _buildPhaseActions(),
      ),
    );
  }

  Widget _buildTitle(DashColors c) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: c.primarySoft,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(Icons.fact_check_rounded, color: c.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            "Vérification de caisse",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhaseContent(DashColors c) {
    switch (_phase) {
      case _VerificationPhase.form:
        return _buildForm(c);
      case _VerificationPhase.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: BouTikaLoader(message: "Vérification en cours..."),
        );
      case _VerificationPhase.result:
        return _buildResult(c);
    }
  }

  List<Widget>? _buildPhaseActions() {
    switch (_phase) {
      case _VerificationPhase.form:
        return [
          Row(
            children: [
              Expanded(
                child: AppButton.secondary(
                  label: "Annuler",
                  height: 48,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: AppButton.primary(
                  label: "Vérifier",
                  icon: Icons.fact_check_rounded,
                  height: 48,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ];
      case _VerificationPhase.loading:
        return null;
      case _VerificationPhase.result:
        return [
          Row(
            children: [
              Expanded(
                child: AppButton.primary(
                  label: "Fermer",
                  height: 48,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ];
    }
  }

  // -------------------------------------------------------------------
  // Phase 1 — Formulaire : un champ montant.
  // -------------------------------------------------------------------
  Widget _buildForm(DashColors c) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Saisissez le montant présent dans la caisse pour le "
            "comparer au montant sur l'app.",
            style: AppTextStyles.bodySecondary.copyWith(
                color: c.textSecondary, fontSize: 13.5, height: 1.5),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _montantController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            textInputAction: TextInputAction.done,
            label: "Montant dans la caisse (F)",
            hint: "Ex: 50000",
            icon: Icons.payments_outlined,
            validator: (v) {
              final double? value = _parseMontant(v ?? "");
              if (value == null || value < 0) {
                return "Indiquez un montant valide";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // Phase 3 — Résultat :
  //   Montant dans la caisse = …
  //   Montant sur l'app      = …
  //   « Résultat normal » ou « Résultat anormal »
  // -------------------------------------------------------------------
  Widget _buildResult(DashColors c) {
    final OrderVerificationResult result = _result!;
    final Color resultColor = result.isNormal ? c.success : c.danger;
    final Color resultSoft = result.isNormal ? c.successSoft : c.dangerSoft;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: resultSoft,
            shape: BoxShape.circle,
          ),
          child: Icon(
            result.isNormal
                ? Icons.check_circle_rounded
                : Icons.warning_amber_rounded,
            color: resultColor,
            size: 30,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          "Résultat de la vérification",
          style: AppTextStyles.heading
              .copyWith(fontSize: 17, color: c.textPrimary),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: c.cardElevated,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: c.border),
          ),
          child: Column(
            children: [
              _buildResultRow(c, "Montant dans la caisse", result.montantCaisse),
              const SizedBox(height: 10),
              Container(height: 1, color: c.border),
              const SizedBox(height: 10),
              _buildResultRow(c, "Montant sur l'app", result.montantApp),
              const SizedBox(height: 10),
              Container(height: 1, color: c.border),
              const SizedBox(height: 10),
              _buildResultRow(c, "Écart", result.ecart),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: resultSoft,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: resultColor.withValues(alpha: 0.2)),
          ),
          child: Text(
            result.isNormal ? "Résultat normal" : "Résultat anormal",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: resultColor,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          result.isNormal
              ? "Le montant dans la caisse correspond au montant "
                  "sur l'app."
              : "Le montant dans la caisse ne correspond pas au "
                  "montant sur l'app.",
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySecondary.copyWith(
              color: c.textSecondary, fontSize: 13.5, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildResultRow(DashColors c, String label, double montant) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySecondary.copyWith(
                color: c.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "= ${_formatMontant(montant)}",
          style: TextStyle(
            color: c.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 13.5,
          ),
        ),
      ],
    );
  }
}
