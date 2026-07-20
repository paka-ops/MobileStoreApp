import 'package:flutter/material.dart';
import 'package:mobile_store_app/models/category.dart';
import 'package:mobile_store_app/models/order.dart';
import 'package:mobile_store_app/models/product.dart';
import 'package:mobile_store_app/models/subscription.dart';
import 'package:mobile_store_app/screens/category_detail_screen.dart';
import 'package:mobile_store_app/screens/low_stock_product.dart';
import 'package:mobile_store_app/screens/order_story_screen.dart';
import 'package:mobile_store_app/screens/spending_page.dart';
import 'package:mobile_store_app/screens/stock_history_screen.dart';
import 'package:mobile_store_app/screens/subscription_screen_page.dart';
import 'package:mobile_store_app/service/category_service.dart';
import 'package:mobile_store_app/service/employee_service.dart';
import 'package:mobile_store_app/service/order_service.dart';
import 'package:mobile_store_app/service/spending_service.dart';
import 'package:mobile_store_app/utils/message.dart';
import 'package:mobile_store_app/widgets/store_page/widgets/drawer_item.dart';
import '../models/Store.dart';
import '../models/employee.dart';
import '../models/spending.dart';
import '../service/product_service.dart';
import '../service/user_service.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../widgets/store_page/functions/get_low_stock_product.dart';
import 'login_screen.dart';

// Modèle de données pour une ligne de vente
class OrderLine {
  Product? product;
  double quantity;
  double salingPrice;
  double? maxStock;

  OrderLine({
    this.product,
    this.quantity = 1,
    this.salingPrice = 0,
    this.maxStock,
  });
}

// ---------------------------------------------------------------------
// PALETTE — désaturée, confortable pour de longues sessions de travail
// ---------------------------------------------------------------------
class AppColors {
  static const primary = Color(0xFF4A7C82);       // teal désaturé, doux
  static const primarySoft = Color(0xFFEBF2F2);
  static const accent = Color(0xFFC08552);         // terracotta doux (dépenses/alertes)
  static const accentSoft = Color(0xFFF6ECE3);
  static const danger = Color(0xFFC96B6B);
  static const success = Color(0xFF6FA687);

  static const background = Color(0xFFF7F8FA);
  static const card = Colors.white;
  static const border = Color(0xFFEDEEF2);

  static const textDark = Color(0xFF2E333D);
  static const textGrey = Color(0xFF8A8F95); // Légèrement assombri pour un meilleur contraste WCAG
}

class _NavItemData {
  final IconData icon;
  final IconData filledIcon;
  final String label;
  _NavItemData(this.icon, this.filledIcon, this.label);
}

class StoreDetailScreen extends StatefulWidget {
  final Store store;
  final String userType;
  final List<Store> otherStores;
  StoreDetailScreen({super.key, required this.store, required this.userType, required this.otherStores});
  @override
  State createState() => _StoreDetailScreen();
}

class _StoreDetailScreen extends State<StoreDetailScreen> {
  // Listes de données
  List<Employee> employees = [];
  List<Category> categories = [];
  List<Product> allStoreProducts = [];
  List<Product> lowStockProducts = [];
  bool isCreatingOrder = false;
  bool isValidatingSale = false;
  bool isSavingCategory = false;
  bool isSavingEmployee = false;
  bool isDeletingEmployee = false;
  bool isCancelingSale = false;

  int _currentIndex = 0;

  final _firstnameController = TextEditingController();
  final _secondnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _categoryNameController = TextEditingController();
  final _categoryDescController = TextEditingController();
  final _expensePriceController = TextEditingController();
  final _expenseDescController = TextEditingController();
  final _expenseFormKey = GlobalKey<FormState>();

  final _categoryFormKey = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();
  List<Store> displayStore = [];

  @override
  void initState() {
    super.initState();
    _fetchAllData();
    displayStore = List.from(widget.otherStores);
    displayStore.removeWhere((e) => e.id == widget.store.id);
  }

  @override
  void dispose() {
    // Libération des contrôleurs pour éviter les fuites de mémoire
    _firstnameController.dispose();
    _secondnameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _categoryNameController.dispose();
    _categoryDescController.dispose();
    _expensePriceController.dispose();
    _expenseDescController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllData() async {
    await getEmployeeByStoreId(widget.store.id);
    await _loadAllProductsForSale();
  }

  Future<void> getEmployeeByStoreId(String storeId) async {
    EmployeeService em = EmployeeService();
    CategoryService categoryService = CategoryService();
    List<Employee> list = await em.getEmployeeOfStore(storeId, context);
    List<Category> cats = await categoryService.getCategoryByStoreId(storeId, context);
    if (mounted) {
      setState(() {
        employees = list;
        categories = cats;
      });
    }
  }

  Future<void> _loadAllProductsForSale() async {
    List<Product> products = await ProductService().getAllProductByStoreId(widget.store.id);
    if (mounted) {
      setState(() {
        allStoreProducts = products;
        lowStockProducts = getLowStockProduct(allStoreProducts);
      });
    }
  }

  // =====================================================================
  // BUILD PRINCIPAL
  // =====================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildTopAppBar(context),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardTab(context),
          _buildSalesTab(context),
          _buildStockTab(context),
          _buildMoreTab(context),
        ],
      ),
      floatingActionButton: _currentIndex == 0 ? _buildSaleAndExpenseFab(context) : null,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // ---------------------------------------------------------------------
  // APP BAR + STORE SWITCHER
  // ---------------------------------------------------------------------
  PreferredSizeWidget _buildTopAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showStoreSwitcherSheet(context),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primarySoft,
                child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Bienvenue",
                      style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.store.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.unfold_more_rounded, size: 16, color: AppColors.textGrey),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          _circleIconButton(
            icon: Icons.warning_amber_rounded,
            color: lowStockProducts.isEmpty ? AppColors.textGrey : AppColors.accent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LowStockProductDetailsScreen(
                    products: lowStockProducts,
                    userType: widget.userType,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _circleIconButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  void _showStoreSwitcherSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 18, 20, 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Mes boutiques",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark),
                  ),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                ),
                title: Text(widget.store.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text("Boutique active", style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
              ),
              if (displayStore.isNotEmpty) const Divider(height: 1, indent: 20, endIndent: 20, color: AppColors.border),
              ...displayStore.map((store) => ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.storefront_outlined, color: AppColors.textGrey, size: 20),
                ),
                title: Text(store.name, style: const TextStyle(fontSize: 14)),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StoreDetailScreen(
                        store: store,
                        userType: widget.userType,
                        otherStores: widget.otherStores,
                      ),
                    ),
                  );
                },
              )),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------
  // BOTTOM NAVIGATION — sobre, accent teal discret
  // ---------------------------------------------------------------------
  Widget _buildBottomNav(BuildContext context) {
    final items = [
      _NavItemData(Icons.home_outlined, Icons.home_rounded, "Accueil"),
      _NavItemData(Icons.receipt_long_outlined, Icons.receipt_long_rounded, "Ventes"),
      _NavItemData(Icons.inventory_2_outlined, Icons.inventory_2_rounded, "Stock"),
      _NavItemData(Icons.settings_outlined, Icons.settings_rounded, "Plus"),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final selected = _currentIndex == index;
              final item = items[index];
              final showBadge = index == 2 && lowStockProducts.isNotEmpty;
              return InkWell(
                onTap: () => setState(() => _currentIndex = index),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            selected ? item.filledIcon : item.icon,
                            color: selected ? AppColors.primary : AppColors.textGrey,
                            size: 23,
                          ),
                          if (showBadge)
                            Positioned(
                              right: -3,
                              top: -3,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 12, // Augmenté de 11 à 12 pour la lisibilité
                          color: selected ? AppColors.primary : AppColors.textGrey,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // CARD GÉNÉRIQUE — bordure fine, pas d'ombre agressive
  // ---------------------------------------------------------------------
  BoxDecoration _cardDecoration({double radius = 18}) {
    return BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.border, width: 1),
    );
  }

  Widget _sectionCard({
    required String title,
    String? subtitle,
    IconData? icon,
    required Widget child,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5, color: AppColors.textDark),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(subtitle, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // ONGLET 0 : ACCUEIL
  // ---------------------------------------------------------------------
  Widget _buildDashboardTab(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchAllData,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 4),
              _buildEmployeeSection(context),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Inventaire",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
                  ),
                ),
              ),
              _buildCategoryList(context, categories),
              const SizedBox(height: 120), // Marge augmentée pour éviter le chevauchement avec FAB
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // ONGLET 1 : VENTES
  // ---------------------------------------------------------------------
  Widget _buildSalesTab(BuildContext context) {
    return OrderStoryScreen(
      storeId: widget.store.id,
      userType: widget.userType,
      categories: categories,
      embedded: true,
    );
  }

  // ---------------------------------------------------------------------
  // ONGLET 2 : STOCK
  // ---------------------------------------------------------------------
  Widget _buildStockTab(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Gestion du stock",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
          ),
          const SizedBox(height: 4),
          const Text(
            "Suivez votre inventaire en temps réel",
            style: TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          const SizedBox(height: 22),
          _buildHubCard(
            icon: Icons.history_edu_rounded,
            color: AppColors.primary,
            title: "Historique de restockage",
            subtitle: "Consultez les réapprovisionnements passés",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RestockHistoryScreen(products: allStoreProducts),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildHubCard(
            icon: Icons.warning_amber_rounded,
            color: AppColors.accent,
            title: "Produits en alerte",
            subtitle: lowStockProducts.isEmpty
                ? "Aucune alerte pour le moment"
                : "${lowStockProducts.length} produit(s) sous le seuil",
            badge: lowStockProducts.isNotEmpty ? lowStockProducts.length : null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LowStockProductDetailsScreen(
                    products: lowStockProducts,
                    userType: widget.userType,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHubCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    int? badge,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(radius: 16),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  if (badge != null)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                        decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                        child: Text(
                          "$badge",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), // Augmenté à 10
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5, color: AppColors.textDark)),
                    const SizedBox(height: 3),
                    Text(subtitle, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // ONGLET 3 : PLUS
  // ---------------------------------------------------------------------
  Widget _buildMoreTab(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primarySoft,
                  child: const Icon(Icons.person, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${UserService.username}",
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          (widget.userType == 'employee') ? "EMPLOYÉ" : "PROPRIÉTAIRE",
                          style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700), // Augmenté à 12
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: _cardDecoration(),
            child: Column(
              children: [
                DrawerItem(
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppColors.accent,
                  title: "Mes Dépenses",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ExpensesScreen(storeId: widget.store.id)),
                    );
                  },
                ),
                if (widget.store.subscription != null) ...[
                  const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.border),
                  DrawerItem(
                    icon: Icons.subscriptions,
                    color: AppColors.primary,
                    title: "Mon abonnement",
                    onTap: () {
                      Subscription subscription = widget.store.subscription!;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubscriptionScreen(
                            storeName: widget.store.name,
                            planType: subscription.plan!,
                            duration: subscription.duration!,
                            startDate: subscription.startDate!,
                            expiryDate: subscription.expirationDate!,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: _cardDecoration(),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 3),
              leading: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 20),
              title: const Text(
                "Déconnexion",
                style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600, fontSize: 14),
              ),
              onTap: () {
                _handleLogout(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // FAB
  // ---------------------------------------------------------------------
  Widget _buildSaleAndExpenseFab(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.extended(
          heroTag: "btnExpense",
          onPressed: () => _showExpenseDialog(context),
          backgroundColor: AppColors.accent,
          elevation: 2,
          icon: const Icon(Icons.money_off, color: Colors.white, size: 20),
          label: const Text("Dépense", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 12),
        FloatingActionButton.extended(
          heroTag: "btnSale",
          onPressed: () => _showStartSaleDialog(context),
          backgroundColor: AppColors.primary,
          elevation: 3,
          icon: const Icon(Icons.shopping_cart_checkout, color: Colors.white, size: 20),
          label: const Text("Vendre", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  // --- LOGIQUE DE VENTE (INCHANGÉE) ---
  void _showStartSaleDialog(BuildContext context) async {
    OrderService orderService = OrderService();
    Order? createdOrder;

    final bool? wantsToCreate = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (stfBuilder, setPopupState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: const Text("Nouvelle Vente"),
            content: const Text("Voulez-vous créer un nouvel ordre de vente ?"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                    setPopupState(() => isCreatingOrder = false);
                  },
                  child: const Text("Non")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: isCreatingOrder
                    ? null
                    : () async {
                  setPopupState(() {
                    isCreatingOrder = true;
                  });
                  createdOrder = await orderService.createOrder(widget.store.id, context);
                  if (mounted) setPopupState(() => isCreatingOrder = false);
                  Navigator.pop(dialogContext, createdOrder != null);
                },
                child: isCreatingOrder
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Oui", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
      },
    );

    if (wantsToCreate == true && createdOrder != null) {
      _showSaleForm(context, createdOrder!.orderId!);
    } else if (wantsToCreate == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la création de l'ordre."), backgroundColor: AppColors.danger),
      );
    }
  }

  void _showSaleForm(BuildContext context, String orderId) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    List<OrderLine> saleLines = [OrderLine()];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (stfContext, setPopupState) {
          // Typage strict du fold pour éviter les erreurs de typage
          double calculateTotal() {
            return saleLines.fold<double>(0.0, (sum, item) => sum + ((item.product?.stock?.sellingPrice ?? 0) * item.quantity));
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: const Text("Choix des produits"),
            // Utilisation de ConstrainedBox pour le responsive sur tablette
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 550),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Ordre de vente", style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                        const Divider(color: AppColors.border),
                        ...saleLines.asMap().entries.map((entry) {
                          int index = entry.key;
                          OrderLine line = entry.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: DropdownSearch<Product>(
                                    popupProps: const PopupProps.modalBottomSheet(
                                      showSearchBox: true,
                                      title: Padding(padding: EdgeInsets.all(12), child: Text("Entrez un produit")),
                                    ),
                                    items: allStoreProducts,
                                    itemAsString: (Product p) => p.name,
                                    dropdownDecoratorProps: const DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(labelText: "Produit", isDense: true),
                                    ),
                                    onChanged: (Product? product) {
                                      setPopupState(() {
                                        line.product = product;
                                        line.salingPrice = product?.stock?.sellingPrice ?? 0;
                                        line.maxStock = ((product?.stock?.baseStock ?? 0.0) - (product?.stock?.totalSell ?? 0.0));
                                        formKey.currentState?.validate();
                                      });
                                    },
                                    validator: (item) {
                                      if (item == null) return 'Requis';

                                      bool isDuplicateBefore = false;
                                      for (int i = 0; i < index; i++) {
                                        if (saleLines[i].product?.id == item.id) {
                                          isDuplicateBefore = true;
                                          break;
                                        }
                                      }

                                      if (isDuplicateBefore) {
                                        return "Déjà ajouté plus haut";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    initialValue: "1",
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: "Qté", isDense: true),
                                    onChanged: (val) {
                                      setPopupState(() {
                                        line.quantity = double.tryParse(val) ?? 0;
                                        formKey.currentState?.validate();
                                      });
                                    },
                                    validator: (val) {
                                      final num? qty = num.tryParse(val ?? '');
                                      if (qty == null || qty <= 0) return "Min 1";

                                      if (line.maxStock != null && qty > line.maxStock!) {
                                        return "Stock insuffisant (${line.maxStock})";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        TextButton.icon(
                          onPressed: () => setPopupState(() => saleLines.add(OrderLine())),
                          icon: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 18),
                          label: const Text("Ajouter un produit a la commande", style: TextStyle(color: AppColors.primary)),
                        ),
                        const Divider(color: AppColors.border),
                        Text("TOTAL: ${calculateTotal().toStringAsFixed(0)} F",
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: AppColors.primary)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: isCancelingSale
                      ? null
                      : () async {
                    try {
                      setPopupState(() => isCancelingSale = true);
                      await OrderService().deleteOrder(orderId, context);
                      if (mounted) setPopupState(() => isCancelingSale = false);
                      Navigator.pop(dialogContext);
                      showSuccessMessage("ordre annulée avec success", context);
                    } catch (e) {
                      showErrorMessage("Erreur lors de la liaison avec le serveur.", context);
                    }
                  },
                  child: const Text("Annuler")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(dialogContext);
                    _showFinalConfirmationDialog(context, orderId, saleLines, calculateTotal());
                  }
                },
                child: isCancelingSale
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Valider", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
      },
    );
  }

  void _showFinalConfirmationDialog(BuildContext context, String orderId, List<OrderLine> saleLines, double total) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(builder: (stfContext, setConfirmationStat) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text("Confirmer la Vente"),
          content: Text("Valider la vente de ${total.toStringAsFixed(0)} F ?"),
          actions: [
            TextButton(
                onPressed: () {
                  setConfirmationStat(() => isValidatingSale = false);
                  Navigator.pop(dialogContext);
                },
                child: const Text("Non")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
              onPressed: isValidatingSale
                  ? null
                  : () async {
                List<Map<String, dynamic>> requestData = saleLines
                    .map((line) => {
                  "orderId": orderId,
                  "productId": line.product!.id,
                  "quantity": line.quantity,
                })
                    .toList();
                setConfirmationStat(() => isValidatingSale = true);
                try {
                  Order? order = await OrderService().makeOrder(orderId, requestData, context);
                  if (mounted) setConfirmationStat(() => isValidatingSale = false);
                  Navigator.pop(dialogContext);
                  if (order != null) {
                    showSuccessMessage("Vente enregistrée !", context);
                    _loadAllProductsForSale();
                  } else {
                    showErrorMessage("Erreur lors de la validation.", context);
                  }
                } catch (e) {
                  print(e);
                  showExceptionMessage(context);
                }
              },
              child: isValidatingSale
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Oui, Valider", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      }),
    );
  }

  // --- ÉQUIPE DE VENTE ---
  Widget _buildEmployeeSection(BuildContext context) {
    return _sectionCard(
      title: "Équipe de vente",
      subtitle: "${employees.length} membre(s)",
      icon: Icons.groups_rounded,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (employees.isEmpty)
            // Empty State amélioré
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Column(
                  children: [
                    Icon(Icons.person_add_alt_1_outlined, color: AppColors.textGrey.withOpacity(0.5), size: 32),
                    const SizedBox(height: 8),
                    const Text(
                      "Aucun employé pour le moment",
                      style: TextStyle(color: AppColors.textGrey, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )
            else
              ...employees.map((emp) => _buildClickableAvatar(context, emp)),
            if (widget.userType == "employer")
              GestureDetector(
                onTap: () => _showAddEmployeeForm(context),
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Column(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.add_rounded, color: AppColors.textGrey, size: 22),
                      ),
                      const SizedBox(height: 5),
                      const Text("Ajouter", style: TextStyle(color: AppColors.textGrey, fontSize: 12)), // Augmenté à 12
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildClickableAvatar(BuildContext context, Employee emp) {
    return GestureDetector(
      onLongPress: () {
        if (widget.userType == "employer") {
          _showEmployeeOptions(context, emp);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 18),
        child: Column(
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: AppColors.primarySoft,
              child: const Icon(Icons.person, color: AppColors.primary, size: 20),
            ),
            const SizedBox(height: 5),
            Text(
              emp.username ?? '',
              style: const TextStyle(color: AppColors.textDark, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmployeeOptions(BuildContext context, Employee emp) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.delete, color: AppColors.danger),
            title: const Text("Supprimer l'employé"),
            onTap: () {
              Navigator.pop(context);
              _confirmDeleteEmployee(context, emp);
            },
          ),
        ],
      ),
    );
  }

  void _confirmDeleteEmployee(BuildContext context, Employee emp) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (stContext, setDelEmployeeState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text("Confirmation"),
          content: Text("Voulez-vous vraiment supprimer ${emp.username} ?"),
          actions: [
            TextButton(
                onPressed: () {
                  setDelEmployeeState(() => isDeletingEmployee = false);
                  Navigator.pop(context);
                },
                child: const Text("Annuler")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: isDeletingEmployee
                  ? null
                  : () async {
                setDelEmployeeState(() => isDeletingEmployee = true);
                EmployeeService empService = EmployeeService();
                bool deleted = await empService.deleteEmployee(emp, context);
                if (mounted) setDelEmployeeState(() => isDeletingEmployee = false);
                if (deleted == true) {
                  showSuccessMessage("employée ${emp.username} est supprimé de votre boutique", context);
                }
                Navigator.pop(context);
                _fetchAllData();
              },
              child: isDeletingEmployee
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Supprimer", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      }),
    );
  }

  // --- LISTE DES CATEGORIES ---
  Widget _buildCategoryList(BuildContext context, List<Category> cats) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: cats.length + (widget.userType == "employer" ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < cats.length) {
          return _buildExpandableCategory(context, cats[index]);
        } else {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showAddCategoryForm(context, null),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, color: AppColors.textGrey, size: 20),
                    SizedBox(width: 8),
                    Text("Ajouter une catégorie", style: TextStyle(color: AppColors.textGrey, fontSize: 13.5)),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildExpandableCategory(BuildContext context, Category category) {
    return _CategoryCard(
      category: category,
      userType: widget.userType,
      onEdit: () => _showAddCategoryForm(context, category),
      onManage: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EmployerCategoryDetailScreen(
              category: category,
              userType: widget.userType,
            ),
          ),
        ).then((_) => _fetchAllData());
      },
    );
  }

  // --- FORMULAIRES AJOUT ---
  void _showAddCategoryForm(BuildContext context, Category? category) {
    if (category != null) {
      _categoryNameController.text = category.name;
      _categoryDescController.text = category.description ?? "";
    } else {
      _categoryNameController.clear();
      _categoryDescController.clear();
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(builder: (stContext, setCatState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.category, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(category == null ? "Nouvelle Catégorie" : "Modifier Catégorie"),
            ],
          ),
          content: Form(
            key: _categoryFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _categoryNameController,
                  decoration: const InputDecoration(
                    labelText: "Nom de la catégorie",
                    prefixIcon: Icon(Icons.label),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'Le nom est obligatoire' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _categoryDescController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    prefixIcon: Icon(Icons.description),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'Veuillez ajouter une description' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setCatState(() => isSavingCategory = false);
                _categoryNameController.clear();
                _categoryDescController.clear();
                Navigator.pop(context);
              },
              child: const Text("Annuler", style: TextStyle(color: AppColors.danger)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: isSavingCategory
                  ? null
                  : () async {
                if (_categoryFormKey.currentState!.validate()) {
                  setCatState(() => isSavingCategory = true);
                  Map<String, dynamic> categoryData = {
                    "name": _categoryNameController.text,
                    "description": _categoryDescController.text,
                  };
                  CategoryService cs = CategoryService();
                  try {
                    if (category != null) {
                      Category? cat = await cs.update(category.id, categoryData, context);
                      if (mounted) setCatState(() => isSavingCategory = false);
                      if (cat == null) {
                        showErrorMessage("mise a jour a echouer", context);
                      } else {
                        int index = categories.indexOf(category);
                        if (index != -1) {
                          setState(() {
                            categories[index] = cat;
                          });
                        }
                      }
                      showSuccessMessage("category mise a jour", context);
                    } else {
                      await cs.create(categoryData, widget.store.id, context);
                      showSuccessMessage("category ajouté", context);
                      _fetchAllData();
                    }
                    Navigator.pop(context);
                  } catch (e) {
                    showExceptionMessage(context);
                  }
                }
              },
              child: isSavingCategory
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(category == null ? "Créer" : "Enregistrer", style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      }),
    );
  }

  void _showAddEmployeeForm(BuildContext context, {Employee? employee}) {
    _firstnameController.clear();
    _secondnameController.clear();
    _usernameController.clear();
    _phoneController.clear();
    _passwordController.clear();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (stContext, setSaveEmpState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(employee == null ? "Ajouter un employé" : "Modifier ${employee.username}"),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(controller: _firstnameController, decoration: const InputDecoration(labelText: "Prénom")),
                  TextFormField(controller: _secondnameController, decoration: const InputDecoration(labelText: "Nom")),
                  TextFormField(controller: _usernameController, decoration: const InputDecoration(labelText: "Nom d'utilisateur")),
                  TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: "Téléphone")),
                  TextFormField(controller: _passwordController, decoration: const InputDecoration(labelText: "Mot de passe"), obscureText: true),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setSaveEmpState(() => isSavingEmployee = false);
                },
                child: const Text("Annuler")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: isSavingEmployee
                  ? null
                  : () async {
                setSaveEmpState(() => isSavingEmployee = true);
                if (_formKey.currentState!.validate()) {
                  Map<String, dynamic> employeeMap = {};
                  employeeMap.putIfAbsent("firstname", () => _firstnameController.text);
                  employeeMap.putIfAbsent("secondName", () => _secondnameController.text);
                  employeeMap.putIfAbsent("username", () => _usernameController.text);
                  employeeMap.putIfAbsent("post", () => "SALESPERSON");
                  employeeMap.putIfAbsent("password", () => _passwordController.text);
                  employeeMap.putIfAbsent("phone", () => _phoneController.text);
                  try {
                    await EmployeeService().addEmployee(employeeMap, widget.store.id, context);
                    if (mounted) setSaveEmpState(() => isSavingEmployee = false);
                    Navigator.pop(context);
                    showSuccessMessage("employée ajouté", context);
                    _fetchAllData();
                  } catch (e) {
                    showExceptionMessage(context);
                  }
                }
              },
              child: isSavingEmployee
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(employee == null ? "Ajouter" : "Enregistrer", style: const TextStyle(color: Colors.white)),
            ),
          ],
        );
      }),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("Déconnexion"),
        content: const Text("Voulez-vous vraiment quitter BouTiKa ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              await UserService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false,
              );
            },
            child: const Text("Se déconnecter", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showExpenseDialog(BuildContext context) {
    bool isSavingExpense = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (stContext, setPopupState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Row(
              children: [
                const Icon(Icons.remove_circle_outline, color: AppColors.accent, size: 20),
                const SizedBox(width: 10),
                const Text("Nouvelle Dépense"),
              ],
            ),
            content: Form(
              key: _expenseFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _expensePriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Montant (F)",
                      prefixIcon: const Icon(Icons.payments_outlined),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? "Indiquez le montant" : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _expenseDescController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: "Description / Motif",
                      prefixIcon: const Icon(Icons.description_outlined),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? "Indiquez le motif" : null,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _expensePriceController.clear();
                  _expenseDescController.clear();
                  Navigator.pop(context);
                },
                child: const Text("Annuler", style: TextStyle(color: AppColors.danger)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: isSavingExpense
                    ? null
                    : () async {
                  if (_expenseFormKey.currentState!.validate()) {
                    setPopupState(() => isSavingExpense = true);

                    try {
                      SpendingServcie spendingService = SpendingServcie();
                      Spending spending = Spending(
                          price: double.parse(_expensePriceController.text),
                          description: _expenseDescController.text,
                          storeId: widget.store.id);
                      await spendingService.saveSpending(spending, context);

                      if (mounted) {
                        _expensePriceController.clear();
                        _expenseDescController.clear();
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      print(e);
                      showErrorMessage("Erreur lors de l'enregistrement", context);
                    } finally {
                      if (mounted) setPopupState(() => isSavingExpense = false);
                    }
                  }
                },
                child: isSavingExpense
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Enregistrer", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
      },
    );
  }
}

// =========================================================================
// CATEGORY CARD — carte extensible custom, esthétique moderne et épurée
// =========================================================================
class _CategoryCard extends StatefulWidget {
  final Category category;
  final String userType;
  final VoidCallback onEdit;
  final VoidCallback onManage;

  const _CategoryCard({
    required this.category,
    required this.userType,
    required this.onEdit,
    required this.onManage,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final category = widget.category;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _expanded ? AppColors.primary.withOpacity(0.30) : AppColors.border,
          width: 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER (toujours visible) ---
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _expanded ? AppColors.primary.withOpacity(0.14) : AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.category_rounded, color: AppColors.primary, size: 21),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.5,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "Gérer le stock et les prix",
                          style: TextStyle(color: AppColors.textGrey, fontSize: 12), // Augmenté de 11.5 à 12
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textGrey,
                        size: 19,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- CONTENU EXTENSIBLE ---
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            sizeCurve: Curves.easeOut,
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 1, color: AppColors.border),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "DESCRIPTION",
                      style: TextStyle(
                        fontSize: 11, // Augmenté de 10 à 11
                        fontWeight: FontWeight.w700,
                        color: AppColors.textGrey,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.description ?? "Aucune description fournie pour cette catégorie.",
                    style: const TextStyle(color: AppColors.textDark, height: 1.4, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (widget.userType == "employer")
                        Expanded(
                          child: _CategoryActionButton(
                            icon: Icons.edit_outlined,
                            label: "Modifier",
                            filled: false,
                            onTap: widget.onEdit,
                          ),
                        ),
                      if (widget.userType == "employer") const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _CategoryActionButton(
                          icon: Icons.inventory_2_outlined,
                          label: "Gérer les produits",
                          filled: true,
                          onTap: widget.onManage,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Bouton d'action réutilisable — style cohérent, pas de Material par défaut
class _CategoryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _CategoryActionButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: filled ? null : Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: filled ? Colors.white : AppColors.textDark),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: filled ? Colors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}