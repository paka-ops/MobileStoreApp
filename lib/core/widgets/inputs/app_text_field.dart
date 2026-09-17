import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../theme/app_colors.dart';

/// ============================================================================
/// APP TEXT FIELD — champ de formulaire premium.
///
/// Design uniquement : la validation et les contrôleurs restent la propriété
/// des écrans (aucune logique ici).
///
///   AppTextField(
///     controller: nameController,
///     label: 'Nom du produit',
///     hint: 'Ex: Sac en cuir',
///     icon: Icons.label_rounded,
///     validator: (v) => ...,
///   )
/// ============================================================================
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool enabled;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final String? initialValue;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.icon,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
    this.maxLines = 1,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.textInputAction,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);

    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      obscureText: obscure,
      keyboardType: keyboardType,
      maxLines: obscure ? 1 : maxLines,
      enabled: enabled,
      validator: validator,
      onChanged: onChanged,
      textInputAction: textInputAction,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14.5,
        color: enabled ? c.textPrimary : c.textSecondary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: c.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 13.5,
        ),
        hintStyle: TextStyle(color: c.textSecondary, fontSize: 13.5),
        filled: true,
        fillColor: c.fill,
        prefixIcon: icon != null
            ? Padding(
                padding: const EdgeInsets.all(13),
                child: Icon(icon, color: c.textSecondary, size: 19),
              )
            : null,
        suffixIcon: suffix,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 17, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: c.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: c.danger, width: 1.3),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: c.danger, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: Colors.transparent),
        ),
      ),
    );
  }
}

/// ============================================================================
/// APP SEARCH FIELD — barre de recherche arrondie avec bouton d'effacement.
/// ============================================================================
class AppSearchField extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const AppSearchField({
    super.key,
    this.hint = 'Rechercher…',
    required this.onChanged,
  });

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);

    return Container(
      decoration: BoxDecoration(
        color: c.fill,
        borderRadius: BorderRadius.circular(AppRadius.search),
      ),
      child: TextField(
        controller: _controller,
        onChanged: (v) {
          setState(() => _hasText = v.isNotEmpty);
          widget.onChanged(v);
        },
        style: TextStyle(
          color: c.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(
            color: c.textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child:
                Icon(Icons.search_rounded, color: c.textSecondary, size: 20),
          ),
          suffixIcon: _hasText
              ? IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    _controller.clear();
                    setState(() => _hasText = false);
                    widget.onChanged('');
                  },
                  icon: Icon(Icons.close_rounded,
                      size: 17, color: c.textSecondary),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
        ),
      ),
    );
  }
}

/// ============================================================================
/// FILTER DATE CHIP — pilule « Date début / Date fin ».
///
/// L'ouverture du datePicker et le rechargement restent dans l'écran
/// (callbacks [onTap] / [onClear]) — aucune logique ici.
/// ============================================================================
class FilterDateChip extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const FilterDateChip({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);
    final bool hasDate = date != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 13),
        decoration: BoxDecoration(
          color: c.fill,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 16,
              color: hasDate ? c.primary : c.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasDate ? _fmt(date!) : label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: hasDate ? c.primary : c.textSecondary,
                ),
              ),
            ),
            if (hasDate)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close_rounded, size: 15, color: c.primary),
              ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year.toString().substring(2)}';
}
