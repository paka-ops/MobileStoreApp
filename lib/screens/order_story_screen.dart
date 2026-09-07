import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile_store_app/models/category.dart';
import 'package:mobile_store_app/models/enums.dart';
import 'package:mobile_store_app/models/order.dart';
import 'package:mobile_store_app/models/product.dart';
import 'package:mobile_store_app/service/user_service.dart';
import 'package:mobile_store_app/utils/app_colors.dart';
import 'package:mobile_store_app/utils/message.dart';
import '../service/order_service.dart';
import 'category_report_screen.dart';
import 'general_report_screen.dart';

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

  DateTime? startDate;
  DateTime? endDate;
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
        startDate ?? DateTime.now().add(const Duration(days: -1)),
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
        backgroundColor: c.background,
        body: SafeArea(child: content),
      );
    }

    return Container(
      color: c.background,
      child: content,
    );
  }

  // =====================================================================
  // HEADER (mode autonome)
  // =====================================================================
  Widget _buildHeader(DashColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.border),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: c.textPrimary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Historique des ventes",
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Toutes les commandes",
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _getOrders(
                storeId: widget.storeId,
                startDate: startDate,
                endDate: endDate),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.border),
              ),
              child: Icon(Icons.refresh_rounded,
                  size: 20, color: c.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // FILTER BAR
  // =====================================================================
  Widget _buildFilterBar(DashColors c) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre + refresh (mode embedded)
          if (widget.embedded)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: c.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.receipt_long_rounded,
                      color: c.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Historique des ventes",
                    style: TextStyle(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _getOrders(
                      storeId: widget.storeId,
                      startDate: startDate,
                      endDate: endDate),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: c.primarySoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.refresh_rounded,
                        color: c.primary, size: 18),
                  ),
                ),
              ],
            ),
          if (widget.embedded) const SizedBox(height: 14),

          // Dates
          Row(
            children: [
              Expanded(
                  child: _dateChip(c, "Date début", startDate, true)),
              const SizedBox(width: 8),
              Expanded(
                  child: _dateChip(c, "Date fin", endDate, false)),
            ],
          ),
          const SizedBox(height: 12),

          // Dropdown statut
          Container(
            decoration: BoxDecoration(
              color: c.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.border, width: 1.2),
            ),
            child: DropdownButtonFormField<OrderStatus>(
              decoration: InputDecoration(
                filled: false,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(Icons.filter_list_rounded,
                      color: c.primary, size: 20),
                ),
                border: InputBorder.none,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              ),
              hint: Text(
                "Tous les statuts",
                style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
              style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
              dropdownColor: c.card,
              value: selectedStatus,
              items: OrderStatus.values
                  .map(
                    (s) => DropdownMenuItem(
                  value: s,
                  child: Text(_getStatusLabel(s)),
                ),
              )
                  .toList(),
              onChanged: (val) {
                setState(() => selectedStatus = val);
                _runFilterLogic();
              },
            ),
          ),
          const SizedBox(height: 14),

          Divider(color: c.border, height: 1),
          const SizedBox(height: 14),

          // Shortcuts
          _buildShortcuts(c),
        ],
      ),
    );
  }

  Widget _dateChip(
      DashColors c, String label, DateTime? date, bool isStart) {
    final bool hasDate = date != null;
    return GestureDetector(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
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
        if (picked != null) {
          setState(() {
            if (isStart) {
              startDate = picked;
            } else {
              endDate = picked;
            }
          });
          _applyFilters();
        }
      },
      child: Container(
        padding:
        const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: hasDate ? c.primarySoft : c.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasDate
                ? c.primary.withOpacity(0.3)
                : c.border,
            width: 1.2,
          ),
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
                hasDate
                    ? DateFormat('dd/MM/yy').format(date!)
                    : label,
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
                onTap: () {
                  setState(() {
                    if (isStart) startDate = null;
                    else endDate = null;
                  });
                  _applyFilters();
                },
                child: Icon(Icons.close_rounded,
                    size: 14, color: c.primary),
              ),
          ],
        ),
      ),
    );
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: softColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
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
    );
  }

  // =====================================================================
  // BODY
  // =====================================================================
  Widget _buildBody(DashColors c) {
    if (isLoading) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,           // <-- au lieu de max
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(strokeWidth: 2.5, color: c.primary),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Chargement des commandes...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: c.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredOrders.isEmpty) {
      return _buildEmptyState(c);
    }

    return RefreshIndicator(
      color: c.primary,
      backgroundColor: c.card,
      onRefresh: () async => _getOrders(
        storeId: widget.storeId,
        startDate: startDate,
        endDate: endDate,
      ),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _OrderCard(
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

  Widget _buildEmptyState(DashColors c) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Si la hauteur dispo est faible, on réduit l'illustration
        final bool compact = constraints.maxHeight < 320;
        final double circle = compact ? 64 : 120;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: compact ? 12 : 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,           // <-- clé
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: circle,
                      height: circle,
                      decoration: BoxDecoration(
                        color: c.primarySoft,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.border),
                      ),
                      child: Icon(Icons.receipt_long_rounded,
                          size: compact ? 28 : 50, color: c.primary),
                    ),
                    SizedBox(height: compact ? 12 : 28),
                    Text(
                      "Aucune commande trouvée",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: compact ? 16 : 20,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                      ),
                    ),
                    SizedBox(height: compact ? 6 : 10),
                    Text(
                      "Modifiez les filtres ou la période pour afficher les commandes.",
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: c.textSecondary,
                        fontSize: compact ? 12.5 : 14,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: compact ? 14 : 24),
                    OutlinedButton.icon(
                      onPressed: () => _getOrders(storeId: widget.storeId),
                      icon: Icon(Icons.refresh_rounded, color: c.primary, size: 18),
                      label: Text("Rafraîchir",
                          style: TextStyle(
                              color: c.primary, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 24, vertical: compact ? 10 : 14),
                        side: BorderSide(color: c.primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: c.border, width: 1.2),
              ),
              contentPadding:
              const EdgeInsets.fromLTRB(24, 24, 24, 0),
              actionsPadding:
              const EdgeInsets.fromLTRB(24, 24, 24, 24),
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
                        color: c.danger, size: 32),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.userType == 'employee'
                        ? "Demander l'annulation"
                        : "Supprimer la commande",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.userType == 'employee'
                        ? "Une demande d'annulation sera envoyée pour la commande N°${order.orderId.substring(0, 8)}."
                        : "Voulez-vous vraiment supprimer la commande N°${order.orderId.substring(0, 8)} ? Cette action est irréversible.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 13.5,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          foregroundColor: c.textPrimary,
                          side: BorderSide(
                              color: c.border, width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: isDeleting
                            ? null
                            : () =>
                            Navigator.pop(dialogContext),
                        child: const Text("Annuler",
                            style: TextStyle(
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          backgroundColor: c.danger,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
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
                        child: isDeleting
                            ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white),
                        )
                            : Text(
                          widget.userType == 'employee'
                              ? "Demander l'annulation"
                              : "Supprimer",
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
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

// =====================================================================
// ORDER CARD — Widget extrait
// =====================================================================
class _OrderCard extends StatelessWidget {
  final Order order;
  final DashColors c;
  final String userType;
  final VoidCallback onDelete;
  final double Function(Order) calculateTotal;
  final String Function(OrderStatus) getStatusLabel;
  final Color Function(OrderStatus) statusColor;
  final Color Function(OrderStatus) statusSoftColor;

  const _OrderCard({
    required this.order,
    required this.c,
    required this.userType,
    required this.onDelete,
    required this.calculateTotal,
    required this.getStatusLabel,
    required this.statusColor,
    required this.statusSoftColor,
  });



  @override
  Widget build(BuildContext context) {
    final Color sColor = statusColor(order.status);
    final Color sSoft = statusSoftColor(order.status);
    final double totalAmount = calculateTotal(order);
    final String? username = UserService.username;
    final bool canAct = username == order.maker['username'] ||
        (userType == 'employer' &&
            order.status == OrderStatus.DELETION_PENDING);

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context)
            .copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: sSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: sColor.withOpacity(0.2)),
            ),
            child: Icon(Icons.receipt_rounded,
                color: sColor, size: 22),
          ),
          title: Text(
            "N°${order.orderId.substring(0, 8)}",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: c.textPrimary,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 12, color: c.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd MMM yyyy • HH:mm')
                        .format(order.createdAt),
                    style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: sSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  getStatusLabel(order.status),
                  style: TextStyle(
                    color: sColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "$totalAmount F",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: c.primary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Icon(Icons.expand_more_rounded,
                  size: 18, color: c.textSecondary),
            ],
          ),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: c.border, height: 1),
                  const SizedBox(height: 16),

                  // Titre section produits
                  Text(
                    "DÉTAILS PRODUITS",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: c.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Produits
                  if (order.products.isNotEmpty)
                    ...order.products.entries.map((entry) {
                      final product = entry.key;
                      final quantity = entry.value;
                      final double lineTotal =
                          (quantity ?? 0) *
                              (product.stock?.sellingPrice ?? 0);

                      return Padding(
                        padding:
                        const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: c.background,
                            borderRadius:
                            BorderRadius.circular(12),
                            border:
                            Border.all(color: c.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: c.primarySoft,
                                  borderRadius:
                                  BorderRadius.circular(8),
                                ),
                                child: Icon(
                                    Icons
                                        .shopping_bag_outlined,
                                    color: c.primary,
                                    size: 14),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "${product.name} × ${quantity}",
                                  style: TextStyle(
                                    color: c.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Text(
                                "$lineTotal F",
                                style: TextStyle(
                                  color: c.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),

                  const SizedBox(height: 12),
                  Divider(color: c.border, height: 1),
                  const SizedBox(height: 12),

                  // Vendeur
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: c.infoSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.person_rounded,
                            size: 14, color: c.info),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Vendeur : ",
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        order.maker?['username'] ?? 'N/A',
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  // Total
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: c.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: c.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total commande",
                          style: TextStyle(
                            color: c.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                        Text(
                          "$totalAmount F",
                          style: TextStyle(
                            color: c.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  if (canAct) ...[
                    const SizedBox(height: 12),
                    Divider(color: c.border, height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.edit_rounded,
                                size: 16, color: c.warning),
                            label: Text("Modifier",
                                style: TextStyle(
                                    color: c.warning,
                                    fontWeight:
                                    FontWeight.w600)),
                            style: OutlinedButton.styleFrom(
                              padding:
                              const EdgeInsets.symmetric(
                                  vertical: 12),
                              side: BorderSide(
                                  color: c.warning
                                      .withOpacity(0.4)),
                              backgroundColor: c.warningSoft,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onDelete,
                            icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 16),
                            label: Text(
                              userType == 'employee'
                                  ? "Annuler"
                                  : "Supprimer",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding:
                              const EdgeInsets.symmetric(
                                  vertical: 12),
                              backgroundColor: c.danger,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}