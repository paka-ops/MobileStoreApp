import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/core/widgets/inputs/app_text_field.dart';
import 'package:mobile_store_app/features/stock/controllers/restock_history_controller.dart';

/// Ouvre le dialogue de sélection de période des mouvements de stock.
///
/// Retourne la période appliquée, ou `null` si l'utilisateur annule.
Future<RestockPeriod?> showRestockPeriodDialog({
  required BuildContext context,
  required DateTime? initialStart,
  required DateTime? initialEnd,
}) {
  return showDialog<RestockPeriod>(
    context: context,
    builder: (_) => RestockPeriodDialog(
      initialStart: initialStart,
      initialEnd: initialEnd,
    ),
  );
}

/// Sélecteur de date unique, thémé avec la palette de l'application.
Future<DateTime?> pickStockDate(
  BuildContext context,
  DateTime initialDate,
) async {
  final DashColors c = DashColors(context);

  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(2022),
    lastDate: DateTime(2100),
    builder: (context, child) => Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: c.primary,
              onPrimary: Colors.white,
              surface: c.card,
              onSurface: c.textPrimary,
            ),
      ),
      child: child!,
    ),
  );
}

/// ============================================================================
/// RESTOCK PERIOD DIALOG — choix des bornes de la période analysée.
///
///   • `AlertDialog` surface carte, rayon 20, bordure 1 px
///   • paddings 20 (titre, contenu, actions comme dans l'original)
///   • titre : pastille 9 px + icône calendrier 19 + « Période d'analyse »
///     + raccourci « 30 jours » (12 / w600 violet)
///   • deux `FilterDateChip` (« Début », « Fin ») espacés de 10 px
///   • « Annuler » (flex 1) + « Appliquer » (flex 2), gap 10, hauteur 44
/// ============================================================================
class RestockPeriodDialog extends StatefulWidget {
  final DateTime? initialStart;
  final DateTime? initialEnd;

  const RestockPeriodDialog({
    super.key,
    required this.initialStart,
    required this.initialEnd,
  });

  @override
  State<RestockPeriodDialog> createState() => _RestockPeriodDialogState();
}

class _RestockPeriodDialogState extends State<RestockPeriodDialog> {
  late DateTime? _tempStart = widget.initialStart;
  late DateTime? _tempEnd = widget.initialEnd;

  @override
  Widget build(BuildContext context) {
    final DashColors c = DashColors(context);

    return AlertDialog(
      backgroundColor: c.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(color: c.border),
      ),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: c.primarySoft,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              color: c.primary,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Période d'analyse",
              style: AppTextStyles.heading.copyWith(
                fontSize: 16.5,
                color: c.textPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _tempStart = DateTime.now().add(const Duration(days: -30));
                _tempEnd = DateTime.now().add(const Duration(days: 1));
              });
            },
            child: Text(
              "30 jours",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: c.primary,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilterDateChip(
            label: "Début",
            date: _tempStart,
            onTap: () async {
              final DateTime? picked =
                  await pickStockDate(context, _tempStart ?? DateTime.now());
              if (picked != null) {
                setState(() => _tempStart = picked);
              }
            },
            onClear: () => setState(() => _tempStart = null),
          ),
          const SizedBox(height: 10),
          FilterDateChip(
            label: "Fin",
            date: _tempEnd,
            onTap: () async {
              final DateTime? picked = await pickStockDate(
                context,
                _tempEnd ?? _tempStart ?? DateTime.now(),
              );
              if (picked != null) {
                setState(() => _tempEnd = picked);
              }
            },
            onClear: () => setState(() => _tempEnd = null),
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: AppButton.secondary(
                label: "Annuler",
                height: 44,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: AppButton.primary(
                label: "Appliquer",
                height: 44,
                onPressed: () => Navigator.pop(
                  context,
                  RestockPeriod(start: _tempStart, end: _tempEnd),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
