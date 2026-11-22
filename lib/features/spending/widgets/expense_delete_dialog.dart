import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/shared/models/spending.dart';

/// Ouvre la confirmation de suppression d'une dépense.
///
/// Retourne `true` si l'utilisateur confirme.
Future<bool?> showExpenseDeleteDialog({
  required BuildContext context,
  required Spending spending,
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
              color: AppColors.badgeRed.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delete_forever_rounded,
              color: AppColors.badgeRed,
              size: 30,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            "Supprimer la dépense",
            style: AppTextStyles.heading.copyWith(
              fontSize: 17,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Voulez-vous vraiment supprimer cette dépense de "
            "${(spending.price ?? 0).toStringAsFixed(0)} F ? Cette action est irréversible.",
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
                label: "Supprimer",
                height: 48,
                fontSize: 13,
                onPressed: () => Navigator.pop(dialogContext, true),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
