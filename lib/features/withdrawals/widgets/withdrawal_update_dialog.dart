import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/models/withdrawal.dart';

/// ============================================================================
/// WITHDRAWAL UPDATE DIALOG — dialogue historique « Mettre a jours ».
///
/// **Rendu et comportement conservés à l'identique**, y compris ses étrangetés :
///   • icône `delete_forever_rounded` (l'original réutilisait le pictogramme de
///     suppression), cercles et couleurs de la suppression
///   • titre « Mettre a jours » et phrase « Cette action est irréversible. »
///   • bouton primaire libellé « Modifier » en style danger
///   • le bouton **n'appelle pas `Navigator.pop`** : il déclenche la mise à
///     jour puis laisse le dialogue ouvert, exactement comme avant
///
/// Retourne `true` uniquement si la boîte est refermée avec cette valeur, ce
/// qui n'arrive pas dans le flux normal : l'appelant ignore donc la suite,
/// comme l'original (branche de suppression inatteignable, retirée).
/// ============================================================================
Future<bool?> showWithdrawalUpdateDialog({
  required BuildContext context,
  required Withdrawal withdrawal,
  required Future<void> Function() onConfirm,
}) {
  final DashColors colors = DashColors(context);

  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(color: colors.border),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.dangerSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.delete_forever_rounded,
              color: colors.danger,
              size: 30,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            "Mettre a jours",
            style: AppTextStyles.heading.copyWith(
              fontSize: 17,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Voulez-vous vraiment mettre a jour le retrait de "
            "${withdrawal.amount.toStringAsFixed(0)} F ? Cette action est irréversible.",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary.copyWith(
              color: colors.textSecondary,
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: AppButton.secondary(
                label: "Annuler",
                height: 48,
                onPressed: () => Navigator.pop(dialogContext, false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: AppButton.danger(
                label: "Modifier",
                height: 48,
                fontSize: 13,
                onPressed: () async {
                  await onConfirm();
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
