import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/core/widgets/inputs/app_text_field.dart';

/// ============================================================================
/// ÉLÉMENTS PARTAGÉS DES DIALOGUES DE CATÉGORIE
///
/// Reprennent à l'identique les trois helpers privés de l'écran d'origine :
/// titre avec pastille d'icône, champ de texte validé, paire de boutons
/// « Annuler » / action principale.
/// ============================================================================

/// Titre de dialogue : icône dans une pastille + libellé tronqué.
class CategoryDialogTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? iconColor;
  final Color? iconSoftColor;

  const CategoryDialogTitle({
    super.key,
    required this.icon,
    required this.title,
    this.iconColor,
    this.iconSoftColor,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconSoftColor ?? c.primarySoft,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, color: iconColor ?? c.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.heading.copyWith(
              fontSize: 17.5,
              color: c.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Champ de texte de dialogue avec validation par défaut « Champ obligatoire ».
class CategoryFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String hint;
  final bool isNumber;
  final String? Function(String?)? validator;

  const CategoryFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.hint,
    this.isNumber = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      hint: hint.isEmpty ? null : hint,
      icon: icon,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: validator ??
          (v) => (v == null || v.isEmpty) ? "Champ obligatoire" : null,
    );
  }
}

/// Paire de boutons « Annuler » / action principale.
class CategoryDialogActions extends StatelessWidget {
  final bool isLoading;
  final String confirmLabel;
  final Color? confirmColor;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const CategoryDialogActions({
    super.key,
    required this.isLoading,
    required this.confirmLabel,
    required this.onCancel,
    required this.onConfirm,
    this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);
    final Color btnColor = confirmColor ?? c.primary;

    return Row(
      children: [
        Expanded(
          child: AppButton.secondary(
            label: "Annuler",
            height: 48,
            onPressed: isLoading ? null : onCancel,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: AppButton.primary(
            label: confirmLabel,
            height: 48,
            background: btnColor,
            foreground: Colors.white,
            isLoading: isLoading,
            onPressed: isLoading ? null : onConfirm,
          ),
        ),
      ],
    );
  }
}
