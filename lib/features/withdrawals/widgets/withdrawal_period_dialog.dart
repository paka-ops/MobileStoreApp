import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/utils/date_utils.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/core/widgets/inputs/app_text_field.dart';

/// Période choisie dans le dialogue de filtre des retraits.
class WithdrawalPeriod {
  final DateTime start;
  final DateTime end;

  const WithdrawalPeriod({required this.start, required this.end});
}

/// Sélecteur de date unique, thémé avec la palette de l'application.
Future<DateTime?> pickWithdrawalDate(
  BuildContext context,
  DateTime initialDate,
) async {
  final DashColors colors = DashColors(context);

  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(2022),
    lastDate: DateTime(2100),
    builder: (context, child) => Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: colors.primary,
              onPrimary: Colors.white,
              surface: colors.card,
              onSurface: colors.textPrimary,
            ),
      ),
      child: child!,
    ),
  );
}

/// Ouvre le dialogue « Filtrer par période » des retraits.
Future<WithdrawalPeriod?> showWithdrawalPeriodDialog({
  required BuildContext context,
  required DateTime initialStart,
  required DateTime initialEnd,
}) {
  return showDialog<WithdrawalPeriod>(
    context: context,
    builder: (_) => WithdrawalPeriodDialog(
      initialStart: initialStart,
      initialEnd: initialEnd,
    ),
  );
}

/// ============================================================================
/// WITHDRAWAL PERIOD DIALOG — bornes de la période des retraits.
///
/// Rendue à l'identique du dialogue des dépenses (paddings 20, pastille 9,
/// raccourci « Aujourd'hui », deux `FilterDateChip`, actions 44 px), avec les
/// mêmes règles de cohérence entre les bornes.
/// ============================================================================
class WithdrawalPeriodDialog extends StatefulWidget {
  final DateTime initialStart;
  final DateTime initialEnd;

  const WithdrawalPeriodDialog({
    super.key,
    required this.initialStart,
    required this.initialEnd,
  });

  @override
  State<WithdrawalPeriodDialog> createState() => _WithdrawalPeriodDialogState();
}

class _WithdrawalPeriodDialogState extends State<WithdrawalPeriodDialog> {
  late DateTime _tempStart = widget.initialStart;
  late DateTime _tempEnd = widget.initialEnd;

  @override
  Widget build(BuildContext context) {
    final DashColors colors = DashColors(context);

    return AlertDialog(
      backgroundColor: colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(color: colors.border),
      ),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: colors.primarySoft,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              color: colors.primary,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Filtrer par période",
              style: AppTextStyles.heading.copyWith(
                fontSize: 16.5,
                color: colors.textPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final DateTime today = AppDateUtils.today();
              setState(() {
                _tempStart = today;
                _tempEnd = today;
              });
            },
            child: Text(
              "Aujourd'hui",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.primary,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilterDateChip(
            label: "Date début",
            date: _tempStart,
            onTap: () async {
              final DateTime? picked =
                  await pickWithdrawalDate(context, _tempStart);
              if (picked != null) {
                setState(() {
                  _tempStart = AppDateUtils.startOfDay(picked);
                  if (_tempEnd.isBefore(_tempStart)) {
                    _tempEnd = _tempStart;
                  }
                });
              }
            },
            onClear: () =>
                setState(() => _tempStart = AppDateUtils.today()),
          ),
          const SizedBox(height: 10),
          FilterDateChip(
            label: "Date fin",
            date: _tempEnd,
            onTap: () async {
              final DateTime? picked =
                  await pickWithdrawalDate(context, _tempEnd);
              if (picked != null) {
                setState(() {
                  _tempEnd = AppDateUtils.startOfDay(picked);
                  if (_tempStart.isAfter(_tempEnd)) {
                    _tempStart = _tempEnd;
                  }
                });
              }
            },
            onClear: () => setState(() => _tempEnd = AppDateUtils.today()),
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
                  WithdrawalPeriod(start: _tempStart, end: _tempEnd),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
