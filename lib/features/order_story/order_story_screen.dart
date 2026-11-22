/// ============================================================================
/// ORDER STORY SCREEN — historique des commandes d'une boutique.
///
/// Contenu repris à l'identique de `lib/screens/order_story_screen.dart` ;
/// seules les dépendances d'interface extérieures ont été extraites :
///   • `features/order_story/widgets/order_card.dart` (`OrderCard`)
///   • `features/order_story/widgets/order_verification_dialog.dart`
///     (`OrderVerificationDialog`, `OrderVerificationResult`)
/// ============================================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/core/widgets/inputs/app_text_field.dart';
import 'package:mobile_store_app/core/widgets/lists/empty_state.dart';
import 'package:mobile_store_app/core/widgets/navigation/app_header.dart';
import 'package:mobile_store_app/features/order_story/widgets/order_card.dart';
import 'package:mobile_store_app/features/order_story/widgets/order_verification_dialog.dart';
import 'package:mobile_store_app/features/reports/category_report_screen.dart';
import 'package:mobile_store_app/features/reports/general_report_screen.dart';
import 'package:mobile_store_app/models/category.dart';
import 'package:mobile_store_app/models/enums.dart';
import 'package:mobile_store_app/models/order.dart';
import 'package:mobile_store_app/models/product.dart';
import 'package:mobile_store_app/models/spending.dart';
import 'package:mobile_store_app/models/withdrawal.dart';
import 'package:mobile_store_app/service/order_service.dart';
import 'package:mobile_store_app/service/spending_service.dart';
import 'package:mobile_store_app/service/user_service.dart';
import 'package:mobile_store_app/service/withdrawal_service.dart';
import 'package:mobile_store_app/shared/widgets/loading/boutika_loader.dart';
import 'package:mobile_store_app/utils/message.dart';

class OrderStoryScreen extends StatefulWidget {
  final String storeId;
  final String userType;
  final List<Category> categories;
  final bool embedded;

  const OrderStoryScreen({
    super.key,
    required this.storeId,
    required this.userType,
    required this.categories,
    this.embedded = false,
  });

  @override
  State<OrderStoryScreen> createState() => _OrderStoryScreenState();
}

class _OrderStoryScreenState extends State<OrderStoryScreen> {
  List<Order> allOrders = [];
  List<Order> filteredOrders = [];
  bool isLoading = false;

  DateTime  startDate =  DateTime.now();
  DateTime?  endDate = DateTime.now().add(const Duration(days: 1));

  OrderStatus? selectedStatus;

  @override
  void initState() {
    super.initState();
    _getOrders(storeId: widget.storeId);
  }

  // =====================================================================
  // LOGIQUE MÉTIER (inchangée)
  // =====================================================================
  Future<void> _setContentsToOrders(List<Order> orders) async {
    if (orders.isEmpty) return;
    List<String> ordersIds = orders.map((o) => o.orderId).toList();
    List<Map<String, dynamic>> contents =
    await OrderService().getcontentsByOrdersIds(ordersIds, context);
    Map<String, List<Map<String, dynamic>>> contentOrderIdMap = {};
    for (var content in contents) {
      contentOrderIdMap
          .putIfAbsent(content['orderId'], () => [])
          .add(content);
    }
    for (var order in orders) {
      List<Map<String, dynamic>> products =
          contentOrderIdMap[order.orderId] ?? [];
      order.products.clear();
      for (var productData in products) {
        order.products.putIfAbsent(
          Product.fromJson(productData['productDto']),
              () => productData['quantity'],
        );
      }
    }
  }

  void _getOrders(
      {required String storeId,
        DateTime? startDate,
        DateTime? endDate}) async {
    setState(() => isLoading = true);
    try {
      List<Order> orders =
      await OrderService().getAllOrderBetweenTwoDate(
        widget.storeId,
        startDate ?? DateTime.now(),
        endDate ?? DateTime.now().add(const Duration(days: 1)),
        context,
      );
      if (orders.isNotEmpty) await _setContentsToOrders(orders);
      allOrders = orders;
      _runFilterLogic();
    } catch (e) {
      debugPrint("Erreur: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _runFilterLogic() {
    setState(() {
      filteredOrders = selectedStatus == null
          ? allOrders
          : allOrders
          .where((o) => o.status == selectedStatus)
          .toList();
    });
  }

  void _applyFilters() =>
      _getOrders(storeId: widget.storeId, startDate: startDate, endDate: endDate);

  double _calculateTotal(Order order) {
    double total = 0;
    order.products.forEach((product, quantity) {
      total += (product.stock?.sellingPrice ?? 0) * (quantity ?? 0);
    });
    return total;
  }

  Color _statusColor(DashColors c, OrderStatus status) {
    switch (status) {
      case OrderStatus.VALIDATED:
        return c.success;
      case OrderStatus.CREATED:
        return c.warning;
      case OrderStatus.DELETION_PENDING:
        return c.danger;
      case OrderStatus.UPDATED:
        return c.info;
      case OrderStatus.SCRAPPED:
        return c.textSecondary;
      default:
        return c.textSecondary;
    }
  }

  Color _statusSoftColor(DashColors c, OrderStatus status) {
    switch (status) {
      case OrderStatus.VALIDATED:
        return c.successSoft;
      case OrderStatus.CREATED:
        return c.warningSoft;
      case OrderStatus.DELETION_PENDING:
        return c.dangerSoft;
      case OrderStatus.UPDATED:
        return c.infoSoft;
      case OrderStatus.SCRAPPED:
        return c.border;
      default:
        return c.border;
    }
  }

  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.VALIDATED:
        return "Validé";
      case OrderStatus.CREATED:
        return "Créé";
      case OrderStatus.DELETION_PENDING:
        return "Annulation en attente";
      case OrderStatus.UPDATED:
        return "Modifié";
      case OrderStatus.SCRAPPED:
        return "Annulé";
      default:
        return "Inconnu";
    }
  }

  // =====================================================================
  // BUILD
  // =====================================================================
  @override
  Widget build(BuildContext context) {
    final c = DashColors(context);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
      Theme.of(context).brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
    ));

    final content = Column(
      children: [
        if (!widget.embedded) _buildHeader(c),
        _buildFilterBar(c),
        Expanded(child: _buildBody(c)),
      ],
    );

    if (!widget.embedded) {
      return Scaffold(
        body: SafeArea(child: content),
        // FAB Vérification de caisse (ajout — aucun comportement existant modifié).
        floatingActionButton: _buildVerificationFab(c),
      );
    }

    // Mode embedded : pas de Scaffold propre à cet écran, le même FAB
    // Vérification est donc superposé en bas à droite du contenu.
    return Container(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          content,
          Positioned(
            right: 20,
            bottom: 16,
            child: _buildVerificationFab(c),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // HEADER (mode autonome)
  // =====================================================================
  Widget _buildHeader(DashColors c) {
    return AppScreenHeader(
      title: "Historique des ventes",
      subtitle: "Toutes les commandes",
      actions: [
        AppIconButton(
          icon: Icons.refresh_rounded,
          tooltip: "Actualiser",
          onTap: () => _getOrders(
              storeId: widget.storeId,
              startDate: startDate,
              endDate: endDate),
        ),
      ],
    );
  }

  // =====================================================================
  // FILTER BAR (version compacte : statut réduit + bouton calendrier pop-up)
  // =====================================================================
  Widget _buildFilterBar(DashColors c) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.border),
        boxShadow: c.softShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Menu déroulant des statuts — dimensions fortement réduites
              Expanded(
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: c.cardElevated,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: c.border, width: 1),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<OrderStatus?>(
                      isExpanded: true,
                      isDense: true,
                      value: selectedStatus,
                      dropdownColor: c.card,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: c.textSecondary,
                      ),
                      hint: Row(
                        children: [
                          Icon(Icons.filter_list_rounded,
                              color: c.primary, size: 15),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              "Tous les statuts",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySecondary.copyWith(
                                color: c.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      items: [
                        DropdownMenuItem<OrderStatus?>(
                          value: null,
                          child: Text(
                            "Tous les statuts",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: c.textSecondary,
                            ),
                          ),
                        ),
                        ...OrderStatus.values.map(
                          (s) => DropdownMenuItem<OrderStatus?>(
                            value: s,
                            child: Text(
                              _getStatusLabel(s),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: c.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() => selectedStatus = val);
                        _runFilterLogic();
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Bouton compact calendrier -> Pop-up choix de date
              Tooltip(
                message: "Changer la période",
                child: InkWell(
                  onTap: _showDateFilterDialog,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c.primarySoft,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: c.primary.withValues(alpha: 0.20),
                      ),
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: c.primary,
                      size: 18,
                    ),
                  ),
                ),
              ),

              if (widget.embedded) ...[
                const SizedBox(width: 6),
                Tooltip(
                  message: "Actualiser",
                  child: InkWell(
                    onTap: () => _getOrders(
                      storeId: widget.storeId,
                      startDate: startDate,
                      endDate: endDate,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: c.fill,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(
                        Icons.refresh_rounded,
                        color: c.textPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: c.border, height: 1),
          const SizedBox(height: 8),

          // Shortcuts — logique et affichage inchangés
          _buildShortcuts(c),
        ],
      ),
    );
  }

  Future<DateTime?> _pickSingleDate(DateTime initialDate) async {
    final c = DashColors(context);
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2022),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: c.primary,
              onPrimary: Colors.white,
              surface: c.card,
              onSurface: c.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  Future<void> _showDateFilterDialog() async {
    final c = DashColors(context);
    DateTime tempStart = startDate;
    DateTime? tempEnd = endDate;

    final bool? applied = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
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
                  child: Icon(Icons.calendar_month_rounded,
                      color: c.primary, size: 19),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Filtrer par date",
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 16.5,
                      color: c.textPrimary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      tempStart = DateTime.now();
                      tempEnd = DateTime.now().add(const Duration(days: 1));
                    });
                  },
                  child: Text(
                    "Aujourd'hui",
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
                  label: "Date début",
                  date: tempStart,
                  onTap: () async {
                    final picked = await _pickSingleDate(tempStart);
                    if (picked != null) {
                      setDialogState(() => tempStart = picked);
                    }
                  },
                  onClear: () {
                    setDialogState(() => tempStart = DateTime.now());
                  },
                ),
                const SizedBox(height: 10),
                FilterDateChip(
                  label: "Date fin",
                  date: tempEnd,
                  onTap: () async {
                    final picked =
                        await _pickSingleDate(tempEnd ?? tempStart);
                    if (picked != null) {
                      setDialogState(() => tempEnd = picked);
                    }
                  },
                  onClear: () {
                    setDialogState(() => tempEnd = null);
                  },
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
                      onPressed: () => Navigator.pop(dialogContext, false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: AppButton.primary(
                      label: "Appliquer",
                      height: 44,
                      onPressed: () => Navigator.pop(dialogContext, true),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    if (applied == true && mounted) {
      setState(() {
        startDate = tempStart;
        endDate = tempEnd;
      });
      _applyFilters();
    }
  }

  Widget _buildShortcuts(DashColors c) {
    return Row(
      children: [
        Expanded(
          child: _shortcutBtn(
            c,
            icon: Icons.assessment_rounded,
            label: "Rapport général",
            color: c.success,
            softColor: c.successSoft,
            onTap: _navigateToGeneralReport,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _shortcutBtn(
            c,
            icon: Icons.pie_chart_rounded,
            label: "Par catégorie",
            color: c.primary,
            softColor: c.primarySoft,
            onTap: _navigateToCategoryReport,
          ),
        ),
      ],
    );
  }

  Widget _shortcutBtn(
      DashColors c, {
        required IconData icon,
        required String label,
        required Color color,
        required Color softColor,
        required VoidCallback onTap,
      }) {
    return Material(
      color: softColor,
      borderRadius: BorderRadius.circular(AppRadius.mlg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.mlg),
        child: Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.mlg),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================================
  // BODY
  // =====================================================================
  String _formatPeriodLabel() {
    final DateFormat fullFmt = DateFormat('dd/MM/yyyy');
    final DateFormat shortFmt = DateFormat('dd/MM');
    if (endDate == null ||
        (startDate.year == endDate!.year &&
            startDate.month == endDate!.month &&
            startDate.day == endDate!.day)) {
      return fullFmt.format(startDate);
    }
    return "${shortFmt.format(startDate)} - ${fullFmt.format(endDate!)}";
  }

  Widget _buildDateCornerBar(DashColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 2),
      child: Row(
        children: [
          if (!isLoading)
            Text(
              "${filteredOrders.length} commande(s)",
              style: AppTextStyles.label.copyWith(
                fontSize: 11.5,
                color: c.textSecondary,
              ),
            ),
          const Spacer(),
          GestureDetector(
            onTap: _showDateFilterDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: c.card.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: c.border.withValues(alpha: 0.85)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 11,
                    color: c.primary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _formatPeriodLabel(),
                    style: AppTextStyles.label.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(DashColors c) {
    final Widget mainArea;
    if (isLoading) {
      mainArea = Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const BouTikaLoader(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Chargement des commandes...",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySecondary.copyWith(color: c.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (filteredOrders.isEmpty) {
      mainArea = EmptyState(
        icon: Icons.receipt_long_rounded,
        title: "Aucune commande trouvée",
        message:
        "Modifiez les filtres ou la période pour afficher les commandes.",
        actionLabel: "Rafraîchir",
        onAction: () => _getOrders(storeId: widget.storeId),
      );
    } else {
      mainArea = RefreshIndicator(
        color: c.primary,
        backgroundColor: c.card,
        onRefresh: () async => _getOrders(
          storeId: widget.storeId,
          startDate: startDate,
          endDate: endDate,
        ),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          // Bas de liste dégagé (96) pour ne pas masquer la dernière
          // carte sous le FAB Vérification.
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OrderCard(
              order: filteredOrders[index],
              c: c,
              userType: widget.userType,
              onDelete: () => _confirmDelete(filteredOrders[index]),
              calculateTotal: _calculateTotal,
              getStatusLabel: _getStatusLabel,
              statusColor: (s) => _statusColor(c, s),
              statusSoftColor: (s) => _statusSoftColor(c, s),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildDateCornerBar(c),
        Expanded(child: mainArea),
      ],
    );
  }

  // =====================================================================
  // NAVIGATION
  // =====================================================================
  void _navigateToGeneralReport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GeneralReportScreen(
          storeId: widget.storeId,
          userType: widget.userType,
          orders: allOrders,
        ),
      ),
    );
  }

  void _navigateToCategoryReport() {
    List<Order> valideOrder =
    allOrders.where((o) => o.products.isNotEmpty).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryReportScreen(
          storeId: widget.storeId,
          userType: widget.userType,
          categories: widget.categories,
          orders: valideOrder,
        ),
      ),
    );
  }

  // =====================================================================
  // VÉRIFICATION DE CAISSE (FAB)
  // FAB « Vérification » → formulaire (champ montant, boutons Annuler /
  // Vérifier) → loading BouTika pendant l'opération → pop-up résultat
  // (montant caisse / montant app / Résultat normal ou anormal).
  // Fonctionnalité 100 % additive : aucune logique existante modifiée.
  //
  // Correctif stabilité : les 3 étapes vivent dans UN SEUL dialog
  // (OrderVerificationDialog, en bas de fichier) qui bascule de phase en
  // interne. On n'enchaîne plus 3 showDialog/pop dans la même frame
  // (source des erreurs « Duplicate GlobalKeys » d'Overlay et
  // « TextEditingController used after disposed » : le controller du
  // champ était libéré alors que le formulaire était encore dans
  // l'arbre pendant son animation de sortie).
  // =====================================================================
  Widget _buildVerificationFab(DashColors c) {
    return FloatingActionButton.extended(
      // heroTag unique : évite tout conflit avec le FAB de l'écran parent
      // (store_page) lorsque cet écran est en mode embedded.
      heroTag: "order_story_verification_fab",
      onPressed: _showVerificationForm,
      backgroundColor: c.primary,
      foregroundColor: c.onPrimary,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      icon: Icon(Icons.fact_check_rounded, size: 20, color: c.onPrimary),
      label: Text(
        "Vérification",
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: c.onPrimary,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Ouverture de la vérification : un seul dialog (OrderVerificationDialog)
  // qui gère lui-même ses 3 phases (formulaire → loading BouTika →
  // résultat) et possède son TextEditingController (dispose dans son
  // propre State.dispose, jamais pendant qu'il est encore affiché).
  // ---------------------------------------------------------------------
  Future<void> _showVerificationForm() async {
    final c = DashColors(context);
    final formKey = GlobalKey<FormState>();
    final montantController = TextEditingController();

    final double? montantCaisse = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: c.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            side: BorderSide(color: c.border),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: c.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(Icons.fact_check_rounded,
                    color: c.primary, size: 20),
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
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
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
                    controller: montantController,
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
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: AppButton.secondary(
                    label: "Annuler",
                    height: 48,
                    onPressed: () => Navigator.pop(dialogContext),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: AppButton.primary(
                    label: "Vérifier",
                    icon: Icons.fact_check_rounded,
                    height: 48,
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      final double? montant =
                          _parseMontant(montantController.text);
                      if (montant == null) return;
                      Navigator.pop(dialogContext, montant);
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );


    if (montantCaisse == null || !mounted) return;
    await _runVerification(montantCaisse);
  }

  // ---------------------------------------------------------------------
  // Étape 2 — Loading BouTika pendant l'opération, puis pop-up résultat.
  // Le loading est toujours fermé, même si l'opération lève une erreur.
  // ---------------------------------------------------------------------
  Future<void> _runVerification(double montantCaisse) async {
    final c = DashColors(context);

    showDialog<void>(
      context: context,
      // Fermeture uniquement via Annuler / Fermer : empêche aussi de
      // fermer par le fond pendant la phase de loading.
      barrierDismissible: false,
      builder: (_) => OrderVerificationDialog(
        onVerify: _effectuerOperationVerification,
      ),
    );

    OrderVerificationResult? result;
    Object? erreur;
    try {
      result = await _effectuerOperationVerification(montantCaisse);
    } catch (e) {
      erreur = e;
      debugPrint("Erreur vérification caisse: $e");
    } finally {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    }

    if (!mounted) return;
    if (erreur != null || result == null) {
      showErrorMessage("Échec de la vérification, réessayez", context);
      return;
    }
    await _showVerificationResult(result);
  }

  // ---------------------------------------------------------------------
  // ✏️ TON OPÉRATION DE VÉRIFICATION — LA PLACE EST ICI
  //
  // Cette méthode reçoit [montantCaisse] (le montant saisi dans le
  // formulaire) et doit retourner un OrderVerificationResult avec :
  //   • montantApp : le montant calculé côté application
  //   • isNormal   : true  → « Résultat normal »
  //                  false → « Résultat anormal »
  //
  // Tu as accès à tout l'écran : allOrders, filteredOrders,
  // _calculateTotal(order), widget.storeId, widget.userType,
  // startDate, endDate, context… et tu peux faire des appels async
  // (services) : le loading BouTika reste affiché pendant ce temps.
  //
  // Remplace l'exemple par défaut ci-dessous par TA propre opération.
  // ---------------------------------------------------------------------
  Future<OrderVerificationResult> _effectuerOperationVerification(
      double montantCaisse) async {
    double spendingAmount = 0;
    double withdrawalAmount = 0;
    List<Spending>? spendings = await SpendingServcie().getAllSpending(widget.storeId, startDate, endDate, context);
    List<Withdrawal>? withdrawals = await WithdrawalService().getWithdrawals(storeId: widget.storeId, startDate: startDate!, endDate: endDate!, context: context);
   if(spendings != null) {
     spendings.forEach((spending) {
       if(spending.price != null) {spendingAmount += spending.price!;};
     });
     if(withdrawals != null){
       withdrawals.forEach((withdrawal){
         withdrawalAmount += withdrawal.amount;
       });
     }
   }
    double montantApp = 0;
    for (final order in allOrders) {
      if (order.status == OrderStatus.VALIDATED) {
        montantApp += _calculateTotal(order);
      }
    }
    bool isNormal = (montantCaisse - (montantApp-spendingAmount-withdrawalAmount)).abs() < 0.01;
    return OrderVerificationResult(
      montantCaisse: montantCaisse,
      montantApp: montantApp,
      spendingAmount: spendingAmount,
      withdrawalAmount: withdrawalAmount,
      isNormal: isNormal,
    );
  }

  // ---------------------------------------------------------------------
  // Étape 3 — Pop-up résultat :
  //   Montant dans la caisse = …
  //   Montant sur l'app      = …
  //   « Résultat normal » ou « Résultat anormal »
  // ---------------------------------------------------------------------
  Future<void> _showVerificationResult(OrderVerificationResult result) async {
    final c = DashColors(context);
    final Color resultColor = result.isNormal ? c.success : c.danger;
    final Color resultSoft = result.isNormal ? c.successSoft : c.dangerSoft;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: c.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            side: BorderSide(color: c.border),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          content: SingleChildScrollView(
            child: Column(
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: c.cardElevated,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: c.border),
                  ),
                  child: Column(
                    children: [
                      _buildResultRow(
                          c, "Montant dans la caisse", result.montantCaisse),
                      const SizedBox(height: 10),
                      Container(height: 1, color: c.border),
                      const SizedBox(height: 10),
                      _buildResultRow(
                          c, "Montant sur l'app", result.montantApp),
                      const SizedBox(height: 10),
                      _buildResultRow(c, "Total Dépense", result.spendingAmount),
                      const SizedBox(height: 10,),
                      _buildResultRow(c, "Total Achat", result.withdrawalAmount),
                      Container(height: 1, color: c.border),
                      const SizedBox(height: 10),
                      _buildResultRow(c, result.ecart<=0?"Manquant":"Surplus", result.ecart),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: resultSoft,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                        color: resultColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    result.isNormal
                        ? "Résultat normal"
                        : "Résultat anormal",
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
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: AppButton.primary(
                    label: "Fermer",
                    height: 48,
                    onPressed: () => Navigator.pop(dialogContext),
                  ),
                ),
              ],
            ),
          ],
        );
      },
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
            color: (label == "Manquant" || label == "Surplus")?montant >=0?c.accentGreen:c.badgeRed:c.textSecondary,
            fontWeight: FontWeight.w800,
            fontSize: 13.5,
          ),
        ),
      ],
    );
  }

  // =====================================================================
  // DIALOG — Confirmer suppression
  // =====================================================================
  void _confirmDelete(Order order) {
    final c = DashColors(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isDeleting = false;

        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: c.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                side: BorderSide(color: c.border),
              ),
              contentPadding:
              const EdgeInsets.fromLTRB(24, 24, 24, 0),
              actionsPadding:
              const EdgeInsets.fromLTRB(24, 20, 24, 24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: c.dangerSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.delete_forever_rounded,
                        color: c.danger, size: 30),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.userType == 'employee'
                        ? "Demander l'annulation"
                        : "Supprimer la commande",
                    style: AppTextStyles.heading.copyWith(fontSize: 17, color: c.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.userType == 'employee'
                        ? "Une demande d'annulation sera envoyée pour la commande N°${order.orderId.substring(0, 8)}."
                        : "Voulez-vous vraiment supprimer la commande N°${order.orderId.substring(0, 8)} ? Cette action est irréversible.",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySecondary.copyWith(color: c.textSecondary, fontSize: 13.5, height: 1.5),
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
                        onPressed: isDeleting
                            ? null
                            : () => Navigator.pop(dialogContext),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: AppButton.danger(
                        label: widget.userType == 'employee'
                            ? "Demander l'annulation"
                            : "Supprimer",
                        height: 48,
                        fontSize: 13,
                        isLoading: isDeleting,
                        onPressed: isDeleting
                            ? null
                            : () async {
                          setDialogState(
                                  () => isDeleting = true);

                          if (widget.userType == "employee") {
                            Order? value = await OrderService()
                                .changeOrderStatus(
                                "DELETION_PENDING",
                                order.orderId,
                                context);
                            if (!mounted) return;
                            if (value != null) {
                              final index =
                              allOrders.indexOf(order);
                              if (index != -1) {
                                allOrders[index] = value;
                                setState(() {});
                                showSuccessMessage(
                                    "Demande d'annulation envoyée",
                                    context);
                              }
                            } else {
                              showErrorMessage(
                                  "Opération refusée",
                                  context);
                            }
                          } else {
                            await OrderService().deleteOrder(
                                order.orderId, context);
                            if (!mounted) return;
                            setState(() {
                              allOrders.removeWhere(
                                      (o) => o.orderId == order.orderId);
                              _runFilterLogic();
                            });
                            showSuccessMessage(
                                "Commande supprimée", context);
                          }

                          Navigator.pop(dialogContext);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}

