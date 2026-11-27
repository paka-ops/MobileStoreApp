import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/widgets/lists/empty_state.dart';
import 'package:mobile_store_app/features/withdrawals/controllers/withdrawals_controller.dart';
import 'package:mobile_store_app/features/withdrawals/widgets/withdrawal_card.dart';
import 'package:mobile_store_app/features/withdrawals/widgets/withdrawal_delete_dialog.dart';
import 'package:mobile_store_app/features/withdrawals/widgets/withdrawal_filter_section.dart';
import 'package:mobile_store_app/features/withdrawals/widgets/withdrawal_form_dialog.dart';
import 'package:mobile_store_app/features/withdrawals/widgets/withdrawal_period_dialog.dart';
import 'package:mobile_store_app/features/withdrawals/widgets/withdrawal_summary_card.dart';
import 'package:mobile_store_app/features/withdrawals/widgets/withdrawal_update_dialog.dart';
import 'package:mobile_store_app/shared/models/withdrawal.dart';
import 'package:mobile_store_app/shared/widgets/loading/boutika_loader.dart';
import 'package:mobile_store_app/utils/message.dart';

/// ============================================================================
/// WITHDRAWAL SCREEN — historique des retraits de la boutique.
///
/// Structure identique à l'écran d'origine :
///   `RefreshIndicator` → `ListView` [filtre, résumé, loader / état vide /
///   cartes de retrait]
///   • mode `embedded` → corps renvoyé tel quel
///   • mode écran     → `AppBar` transparente centrée + « Actualiser »
///
/// Période, chargement, total et suppression vivent dans
/// [WithdrawalsController]. Les trois actions de chaque carte sont conservées :
/// formulaire (soft), dialogue historique « Mettre a jours », suppression.
///
/// Messages identiques : « Retrait introuvable », « Retrait supprimé avec
/// succès », et rechargement après enregistrement du formulaire.
/// ============================================================================
class WithdrawalScreen extends StatefulWidget {
  final String storeId;
  final bool embedded;

  const WithdrawalScreen({
    super.key,
    required this.storeId,
    this.embedded = false,
  });

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  late final WithdrawalsController _controller =
      WithdrawalsController(storeId: widget.storeId);

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
    final WithdrawalPeriod? period = await showWithdrawalPeriodDialog(
      context: context,
      initialStart: _controller.startDate,
      initialEnd: _controller.endDate,
    );

    if (period == null || !mounted) return;
    await _controller.applyPeriod(context, period.start, period.end);
  }

  Future<void> _editWithdrawal(Withdrawal withdrawal) async {
    final bool saved = await showWithdrawalFormDialog(
      context,
      storeId: widget.storeId,
      withdrawal: withdrawal,
    );

    if (saved && mounted) {
      unawaited(_controller.load(context));
    }
  }

  Future<void> _deleteWithdrawal(Withdrawal withdrawal) async {
    final String? id = withdrawal.id;
    if (id == null || id.isEmpty) {
      showErrorMessage("Retrait introuvable", context);
      return;
    }

    final bool? confirmed = await showWithdrawalDeleteDialog(
      context: context,
      withdrawal: withdrawal,
    );

    if (confirmed != true || !mounted) return;

    final bool deleted =
        await _controller.deleteWithdrawal(withdrawal, context);

    if (!mounted) return;
    if (deleted) {
      showSuccessMessage("Retrait supprimé avec succès", context);
    }
  }

  Future<void> _updateWithdrawal(Withdrawal withdrawal) async {
    final String? id = withdrawal.id;
    if (id == null || id.isEmpty) {
      showErrorMessage("Retrait introuvable", context);
      return;
    }

    final bool? confirmed = await showWithdrawalUpdateDialog(
      context: context,
      withdrawal: withdrawal,
      onConfirm: () => _controller.updateWithdrawal(withdrawal, context),
    );

    // Le dialogue historique ne renvoie jamais `true` : aucune action ensuite.
    if (confirmed != true) return;
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
                  WithdrawalFilterSection(
                    isLoading: _controller.isLoading,
                    withdrawalCount: _controller.withdrawals.length,
                    periodLabel: _controller.periodLabel,
                    embedded: widget.embedded,
                    onSelectPeriod: _openPeriodDialog,
                    onRefresh: () => unawaited(_controller.load(context)),
                  ),
                  const SizedBox(height: 10),
                  WithdrawalSummaryCard(
                    totalAmount: _controller.totalAmount,
                    withdrawalCount: _controller.withdrawals.length,
                  ),
                  const SizedBox(height: 12),
                  if (_controller.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: Center(child: BouTikaLoader()),
                    )
                  else if (_controller.withdrawals.isEmpty)
                    _buildEmptyState()
                  else
                    ..._controller.withdrawals.map(_buildWithdrawalCard),
                ],
              ),
            );

            if (widget.embedded) return body;

            return Scaffold(
              appBar: AppBar(
                title: Text(
                  "Historique des retraits",
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

  Widget _buildWithdrawalCard(Withdrawal withdrawal) {
    return WithdrawalCard(
      withdrawal: withdrawal,
      onEdit: () => _editWithdrawal(withdrawal),
      onUpdate: () => _updateWithdrawal(withdrawal),
      onDelete: () => _deleteWithdrawal(withdrawal),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: SizedBox(
        height: 420,
        child: EmptyState(
          icon: Icons.savings_outlined,
          title: "Aucun retrait trouvé",
          message: "Aucun retrait ne correspond à la période sélectionnée.",
          actionLabel: "Actualiser",
          onAction: () => unawaited(_controller.load(context)),
        ),
      ),
    );
  }
}
