import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/widgets/lists/empty_state.dart';
import 'package:mobile_store_app/features/spending/controllers/expenses_controller.dart';
import 'package:mobile_store_app/features/spending/widgets/expense_card.dart';
import 'package:mobile_store_app/features/spending/widgets/expense_delete_dialog.dart';
import 'package:mobile_store_app/features/spending/widgets/expense_edit_dialog.dart';
import 'package:mobile_store_app/features/spending/widgets/expense_filter_section.dart';
import 'package:mobile_store_app/features/spending/widgets/expense_period_dialog.dart';
import 'package:mobile_store_app/features/spending/widgets/expense_summary_card.dart';
import 'package:mobile_store_app/shared/models/spending.dart';
import 'package:mobile_store_app/shared/widgets/loading/boutika_loader.dart';
import 'package:mobile_store_app/utils/message.dart';

/// ============================================================================
/// EXPENSES SCREEN — historique des dépenses de la boutique.
///
/// Structure identique à l'écran d'origine :
///   `RefreshIndicator` → `ListView` [filtre, résumé, loader / état vide /
///   cartes de dépense]
///   • mode `embedded` → le corps est renvoyé tel quel
///   • mode écran     → `AppBar` transparente centrée + action « Actualiser »
///
/// Période, chargement concurrent, filtrage et total vivent dans
/// [ExpensesController] ; chaque carte est un composant dédié.
///
/// Messages conservés : « Dépense introuvable », « Dépense supprimée avec
/// succès », et le rafraîchissement après modification.
/// ============================================================================
class ExpensesScreen extends StatefulWidget {
  final String storeId;
  final bool embedded;

  const ExpensesScreen({
    super.key,
    required this.storeId,
    this.embedded = false,
  });

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  late final ExpensesController _controller =
      ExpensesController(storeId: widget.storeId);

  @override
  void initState() {
    super.initState();
    unawaited(_controller.load(context));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openPeriodDialog() async {
    final ExpensePeriod? period = await showExpensePeriodDialog(
      context: context,
      initialStart: _controller.startDate,
      initialEnd: _controller.endDate,
    );

    if (period == null || !mounted) return;
    await _controller.applyPeriod(context, period.start, period.end);
  }

  Future<void> _editExpense(Spending spending) async {
    final bool? saved = await showExpenseEditDialog(
      context: context,
      spending: spending,
      storeId: widget.storeId,
      controller: _controller,
    );

    if (saved == true && mounted) {
      unawaited(_controller.load(context));
    }
  }

  Future<void> _confirmDelete(Spending spending) async {
    final String? id = spending.id;
    if (id == null || id.isEmpty) {
      showErrorMessage("Dépense introuvable", context);
      return;
    }

    final bool? confirmed = await showExpenseDeleteDialog(
      context: context,
      spending: spending,
    );

    if (confirmed != true || !mounted) return;

    final bool deleted = await _controller.deleteExpense(spending, context);

    if (!mounted) return;
    if (deleted) {
      showSuccessMessage("Dépense supprimée avec succès", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: appDarkMode,
      builder: (context, _, __) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final DashColors colors = DashColors(context);

            final Widget body = RefreshIndicator(
              onRefresh: () => _controller.load(context),
              color: colors.primary,
              backgroundColor: colors.card,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                children: [
                  ExpenseFilterSection(
                    isLoading: _controller.isLoading,
                    expenseCount: _controller.expenses.length,
                    periodLabel: _controller.periodLabel,
                    embedded: widget.embedded,
                    onSelectPeriod: _openPeriodDialog,
                    onRefresh: () => unawaited(_controller.load(context)),
                  ),
                  const SizedBox(height: 10),
                  ExpenseSummaryCard(
                    totalAmount: _controller.totalAmount,
                    expenseCount: _controller.expenses.length,
                  ),
                  const SizedBox(height: 12),
                  if (_controller.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: Center(child: BouTikaLoader()),
                    )
                  else if (_controller.expenses.isEmpty)
                    _buildEmptyState()
                  else
                    ..._controller.expenses.map(_buildExpenseCard),
                ],
              ),
            );

            if (widget.embedded) return body;

            return Scaffold(
              appBar: AppBar(
                title: Text(
                  "Historique des Dépenses",
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 17,
                    color: colors.textPrimary,
                  ),
                ),
                backgroundColor: Colors.transparent,
                foregroundColor: colors.textPrimary,
                elevation: 0,
                scrolledUnderElevation: 0,
                centerTitle: true,
                actions: [
                  IconButton(
                    tooltip: "Actualiser",
                    onPressed: () => unawaited(_controller.load(context)),
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              body: SafeArea(child: body),
            );
          },
        );
      },
    );
  }

  Widget _buildExpenseCard(Spending spending) {
    return ExpenseCard(
      spending: spending,
      onEdit: () => _editExpense(spending),
      onDelete: () => _confirmDelete(spending),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: SizedBox(
        height: 420,
        child: EmptyState(
          icon: Icons.receipt_long_outlined,
          title: "Aucune dépense trouvée",
          message: "Aucune dépense ne correspond à la période sélectionnée.",
          actionLabel: "Actualiser",
          onAction: () => unawaited(_controller.load(context)),
        ),
      ),
    );
  }
}
