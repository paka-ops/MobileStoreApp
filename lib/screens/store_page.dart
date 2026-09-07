import 'package:flutter/material.dart';
import 'package:mobile_store_app/models/category.dart';
import 'package:mobile_store_app/models/order.dart';
import 'package:mobile_store_app/models/product.dart';
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
import 'package:mobile_store_app/utils/app_colors.dart' show appDarkMode, DashColors;
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
import 'package:mobile_store_app/widgets/boutika_loader.dart';

// ---------------------------------------------------------------------------
// Modèle ligne de vente
// ---------------------------------------------------------------------------
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

// ---------------------------------------------------------------------------
// Couleurs sémantiques fixes (ne changent pas avec le thème)
// ---------------------------------------------------------------------------
class _Fixed {
  static const accent  = Color(0xFFC08552);
  static const danger  = Color(0xFFC96B6B);
  static const success = Color(0xFF6FA687);
}

class _NavItemData {
  final IconData icon;
  final IconData filledIcon;
  final String label;
  _NavItemData(this.icon, this.filledIcon, this.label);
}

// ---------------------------------------------------------------------------
// Widget principal
// ---------------------------------------------------------------------------
class StoreDetailScreen extends StatefulWidget {
  final Store store;
  final String userType;
  final List<Store> otherStores;

  const StoreDetailScreen({
    super.key,
    required this.store,
    required this.userType,
    required this.otherStores,
  });

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreen();
}

class _StoreDetailScreen extends State<StoreDetailScreen> {
  List<Employee> employees        = [];
  List<Category> categories       = [];
  List<Product>  allStoreProducts = [];
  List<Product>  lowStockProducts = [];

  bool isCreatingOrder    = false;
  bool isValidatingSale   = false;
  bool isSavingCategory   = false;
  bool isSavingEmployee   = false;
  bool isDeletingEmployee = false;
  bool isCancelingSale    = false;

  int _currentIndex = 0;

  // Vrai tant que les appels API initiaux ne sont pas terminés :
  // la page affiche alors l'écran d'attente « BouTika ».
  bool _isLoading = true;

  final _firstnameController    = TextEditingController();
  final _secondnameController   = TextEditingController();
  final _usernameController     = TextEditingController();
  final _phoneController        = TextEditingController();
  final _passwordController     = TextEditingController();
  final _categoryNameController = TextEditingController();
  final _categoryDescController = TextEditingController();
  final _expensePriceController = TextEditingController();
  final _expenseDescController  = TextEditingController();

  final _expenseFormKey  = GlobalKey<FormState>();
  final _categoryFormKey = GlobalKey<FormState>();
  final _formKey         = GlobalKey<FormState>();

  List<Store> displayStore = [];

  @override
  void initState() {
    super.initState();
    _fetchAllData();
    displayStore = List.from(widget.otherStores)
      ..removeWhere((e) => e.id == widget.store.id);
  }

  @override
  void dispose() {
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

  // -------------------------------------------------------------------------
  // Chargement des données
  // -------------------------------------------------------------------------
  Future<void> _fetchAllData() async {
    try {
      await _loadEmployeesAndCategories();
      await _loadAllProductsForSale();
    } finally {
      // Les appels API sont terminés (succès ou échec) : on quitte
      // l'écran d'attente « BouTika ».
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadEmployeesAndCategories() async {
    final list = await EmployeeService()
        .getEmployeeOfStore(widget.store.id, context);
    final cats = await CategoryService()
        .getCategoryByStoreId(widget.store.id, context);
    if (mounted) setState(() { employees = list; categories = cats; });
  }

  Future<void> getEmployeeByStoreId(String storeId) =>
      _loadEmployeesAndCategories();

  Future<void> _loadAllProductsForSale() async {
    final products =
    await ProductService().getAllProductByStoreId(widget.store.id);
    if (mounted) {
      setState(() {
        allStoreProducts = products;
        lowStockProducts = getLowStockProduct(allStoreProducts);
      });
    }
  }

  // =========================================================================
  // BUILD PRINCIPAL
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: appDarkMode,
      builder: (context, isDark, __) {
        final colors = DashColors(context);

        // Écran d'attente « BouTika » tant que les appels API
        // de chargement des données ne sont pas terminés.
        if (_isLoading) {
          return Scaffold(
            backgroundColor: colors.background,
            body: Center(
              child: const BouTikaLoader(),
            ),
          );
        }

        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildTopBar(context, colors),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: [
                      _buildDashboardTab(context, colors),
                      _buildSalesTab(context),
                      _buildStockTab(context, colors),
                      _buildMoreTab(context, colors),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: _currentIndex == 0
              ? _buildSaleAndExpenseFab(context, colors)
              : null,
          bottomNavigationBar: _buildBottomNav(context, colors),
        );
      },
    );
  }

  // =========================================================================
  // TOP BAR
  // =========================================================================
  Widget _buildTopBar(BuildContext context, DashColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Avatar boutique
          GestureDetector(
            onTap: () => _showStoreSwitcherSheet(context, colors),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.accent.withOpacity(0.5),
                  width: 2,
                ),
                color: colors.primarySoft,
              ),
              child: Icon(
                Icons.storefront_rounded,
                color: colors.primary,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Pill greeting flexible
          Expanded(
            child: GestureDetector(
              onTap: () => _showStoreSwitcherSheet(context, colors),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colors.greetingPill,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    const Text(
                      "👋 ",
                      style: TextStyle(fontSize: 14),
                    ),

                    const Text(
                      "Hello ",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // Le nom peut maintenant se réduire
                    Flexible(
                      child: Text(
                        widget.store.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Bouton thème
          _topIconButton(
            icon: appDarkMode.value
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            colors: colors,
            onTap: () => appDarkMode.value = !appDarkMode.value,
          ),

          const SizedBox(width: 8),

          // Alerte stock
          _topIconButton(
            icon: Icons.notifications_outlined,
            colors: colors,
            badge: lowStockProducts.isNotEmpty,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LowStockProductDetailsScreen(
                  products: lowStockProducts,
                  userType: widget.userType,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topIconButton({
    required IconData icon,
    required DashColors colors,
    bool badge = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.topBarIconBg,
              shape: BoxShape.circle,
              boxShadow: colors.subtleShadow,
            ),
            child: Icon(icon, size: 20, color: colors.topBarIcon),
          ),
          if (badge)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: colors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // =========================================================================
  // STORE SWITCHER SHEET
  // =========================================================================
  void _showStoreSwitcherSheet(BuildContext context, DashColors colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        final maxHeight = MediaQuery.sizeOf(ctx).height * 0.75;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Mes boutiques",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 16),
                    children: [
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors.primarySoft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.check_circle_rounded,
                              color: colors.primary, size: 20),
                        ),
                        title: Text(
                          widget.store.name,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary),
                        ),
                        subtitle: Text(
                          "Boutique active",
                          style: TextStyle(color: colors.textSecondary),
                        ),
                      ),
                      if (displayStore.isNotEmpty)
                        Divider(
                            height: 1,
                            indent: 20,
                            endIndent: 20,
                            color: colors.border),
                      ...displayStore.map((newStore) => ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors.cardElevated,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.storefront_outlined,
                              color: colors.textSecondary, size: 20),
                        ),
                        title: Text(newStore.name,
                            style:
                            TextStyle(color: colors.textPrimary)),
                        trailing: Icon(Icons.chevron_right_rounded,
                            color: colors.textSecondary),
                        onTap: () {
                          final nextOthers =
                          List<Store>.from(widget.otherStores)
                            ..removeWhere((s) => s.id == newStore.id)
                            ..add(widget.store);
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StoreDetailScreen(
                                store: newStore,
                                userType: widget.userType,
                                otherStores: nextOthers,
                              ),
                            ),
                          );
                        },
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================================================================
  // BOTTOM NAV
  // =========================================================================
  Widget _buildBottomNav(BuildContext context, DashColors colors) {
    final items = [
      _NavItemData(Icons.home_outlined, Icons.home_rounded, "Accueil"),
      _NavItemData(Icons.receipt_long_outlined, Icons.receipt_long_rounded,
          "Ventes"),
      _NavItemData(
          Icons.inventory_2_outlined, Icons.inventory_2_rounded, "Stock"),
      _NavItemData(Icons.settings_outlined, Icons.settings_rounded, "Plus"),
    ];

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        boxShadow: colors.subtleShadow,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final selected  = _currentIndex == index;
              final item      = items[index];
              final showBadge = index == 2 && lowStockProducts.isNotEmpty;

              return Expanded(
                child: InkWell(
                  onTap: () => setState(() => _currentIndex = index),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              selected ? item.filledIcon : item.icon,
                              color: selected
                                  ? colors.primary
                                  : colors.textSecondary,
                              size: 24,
                            ),
                            if (showBadge)
                              Positioned(
                                right: -3,
                                top: -3,
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: colors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: selected
                                ? colors.primary
                                : colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // HELPERS DÉCORATIONS
  // =========================================================================
  BoxDecoration _cardDecoration(DashColors colors, {double radius = 20}) {
    return BoxDecoration(
      color: colors.card,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: colors.cardShadow,
    );
  }

  Widget _sectionCard({
    required String title,
    required DashColors colors,
    String? subtitle,
    IconData? icon,
    required Widget child,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: _cardDecoration(colors),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: colors.textPrimary,
                  ),
                ),
                if (icon != null)
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: colors.primarySoft,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: colors.primary.withOpacity(0.3)),
                    ),
                    child: Icon(icon, color: colors.primary, size: 20),
                  ),
              ],
            ),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
              child: Text(
                subtitle,
                style: TextStyle(
                    fontSize: 13.5,
                    color: colors.textSecondary,
                    height: 1.45),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: child,
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // ONGLET 0 — ACCUEIL
  // =========================================================================
  Widget _buildDashboardTab(BuildContext context, DashColors colors) {
    return RefreshIndicator(
      onRefresh: _fetchAllData,
      color: colors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            _buildEmployeeSection(context, colors),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Inventaire",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),
            _buildCategoryList(context, categories, colors),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // ONGLET 1 — VENTES
  // =========================================================================
  Widget _buildSalesTab(BuildContext context) {
    return OrderStoryScreen(
      storeId: widget.store.id,
      userType: widget.userType,
      categories: categories,
      embedded: true,
    );
  }

  // =========================================================================
  // ONGLET 2 — STOCK
  // =========================================================================
  Widget _buildStockTab(BuildContext context, DashColors colors) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          "Gestion du stock",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          "Suivez votre inventaire en temps réel",
          style: TextStyle(color: colors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 22),
        _buildHubCard(
          icon: Icons.history_edu_rounded,
          color: colors.primary,
          title: "Historique de restockage",
          subtitle: "Consultez les réapprovisionnements passés",
          colors: colors,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  RestockHistoryScreen(products: allStoreProducts),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildHubCard(
          icon: Icons.warning_amber_rounded,
          color: colors.accent,
          title: "Produits en alerte",
          subtitle: lowStockProducts.isEmpty
              ? "Aucune alerte pour le moment"
              : "${lowStockProducts.length} produit(s) sous le seuil",
          badge: lowStockProducts.isNotEmpty
              ? lowStockProducts.length
              : null,
          colors: colors,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LowStockProductDetailsScreen(
                products: lowStockProducts,
                userType: widget.userType,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHubCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required DashColors colors,
    int? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(colors, radius: 16),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
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
                      constraints: const BoxConstraints(
                          minWidth: 17, minHeight: 17),
                      decoration: BoxDecoration(
                          color: colors.accent,
                          shape: BoxShape.circle),
                      child: Text(
                        "$badge",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
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
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                          color: colors.textPrimary)),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: TextStyle(
                          color: colors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: colors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // ONGLET 3 — PLUS
  // =========================================================================
  Widget _buildMoreTab(BuildContext context, DashColors colors) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      children: [
        // Carte profil
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(colors),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colors.primarySoft,
                child: Icon(Icons.person, color: colors.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${UserService.username}",
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: colors.textPrimary),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: colors.primarySoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.userType == 'employee'
                            ? "EMPLOYÉ"
                            : "PROPRIÉTAIRE",
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Actions
        Container(
          decoration: _cardDecoration(colors),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.accentSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.account_balance_wallet_outlined,
                      color: colors.accent, size: 20),
                ),
                title: Text("Mes Dépenses",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: colors.textPrimary)),
                trailing: Icon(Icons.chevron_right_rounded,
                    color: colors.textSecondary),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ExpensesScreen(storeId: widget.store.id),
                  ),
                ),
              ),
              if (widget.store.subscription != null) ...[
                Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: colors.border),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.primarySoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.subscriptions,
                        color: colors.primary, size: 20),
                  ),
                  title: Text("Mon abonnement",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: colors.textPrimary)),
                  trailing: Icon(Icons.chevron_right_rounded,
                      color: colors.textSecondary),
                  onTap: () {
                    final sub = widget.store.subscription!;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SubscriptionScreen(
                          storeName: widget.store.name,
                          planType: sub.plan!,
                          duration: sub.duration!,
                          startDate: sub.startDate!,
                          expiryDate: sub.expirationDate!,
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

        // Déconnexion
        Container(
          decoration: _cardDecoration(colors),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.dangerSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.logout_rounded,
                  color: colors.danger, size: 20),
            ),
            title: Text(
              "Déconnexion",
              style: TextStyle(
                  color: colors.danger,
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
            ),
            trailing: Icon(Icons.chevron_right_rounded,
                color: colors.danger),
            onTap: () => _handleLogout(context, colors),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // FAB
  // =========================================================================
  Widget _buildSaleAndExpenseFab(BuildContext context, DashColors colors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.extended(
          heroTag: "btnExpense",
          onPressed: () => _showExpenseDialog(context, colors),
          backgroundColor: colors.accent,
          elevation: 2,
          icon: const Icon(Icons.money_off, color: Colors.white, size: 20),
          label: const Text("Dépense",
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 12),
        FloatingActionButton.extended(
          heroTag: "btnSale",
          onPressed: () => _showStartSaleDialog(context, colors),
          backgroundColor: colors.primary,
          elevation: 3,
          icon: const Icon(Icons.shopping_cart_checkout,
              color: Colors.white, size: 20),
          label: const Text("Vendre",
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  // =========================================================================
  // SECTION EMPLOYÉS
  // =========================================================================
  Widget _buildEmployeeSection(BuildContext context, DashColors colors) {
    return _sectionCard(
      title: "Équipe de vente",
      subtitle: "${employees.length} membre(s)",
      icon: Icons.groups_rounded,
      colors: colors,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (employees.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_add_alt_1_outlined,
                        color: colors.textSecondary.withOpacity(0.5),
                        size: 32),
                    const SizedBox(height: 8),
                    Text(
                      "Aucun employé pour le moment",
                      style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )
            else
              ...employees.map(
                      (emp) => _buildClickableAvatar(context, emp, colors)),
            if (widget.userType == "employer")
              GestureDetector(
                onTap: () => _showAddEmployeeForm(context, colors),
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: colors.cardElevated,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.border),
                        ),
                        child: Icon(Icons.add_rounded,
                            color: colors.textSecondary, size: 22),
                      ),
                      const SizedBox(height: 5),
                      Text("Ajouter",
                          style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 12)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildClickableAvatar(
      BuildContext context, Employee emp, DashColors colors) {
    return GestureDetector(
      onLongPress: () {
        if (widget.userType == "employer")
          _showEmployeeOptions(context, emp, colors);
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 18),
        child: SizedBox(
          width: 64,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: colors.primarySoft,
                child: Icon(Icons.person,
                    color: colors.primary, size: 20),
              ),
              const SizedBox(height: 5),
              Text(
                emp.username ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: colors.textPrimary, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // LISTE DES CATÉGORIES
  // =========================================================================
  Widget _buildCategoryList(
      BuildContext context, List<Category> cats, DashColors colors) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: cats.length + (widget.userType == "employer" ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < cats.length) {
          return _buildExpandableCategory(context, cats[index], colors);
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () => _showAddCategoryForm(context, null, colors),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border),
                boxShadow: colors.cardShadow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded,
                      color: colors.textSecondary, size: 20),
                  const SizedBox(width: 8),
                  Text("Ajouter une catégorie",
                      style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 13.5)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandableCategory(
      BuildContext context, Category category, DashColors colors) {
    return _CategoryCard(
      category: category,
      userType: widget.userType,
      colors: colors,
      onEdit: () => _showAddCategoryForm(context, category, colors),
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

  // =========================================================================
  // OPTIONS EMPLOYÉ
  // =========================================================================
  void _showEmployeeOptions(
      BuildContext context, Employee emp, DashColors colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.delete, color: colors.danger),
              title: Text("Supprimer l'employé",
                  style: TextStyle(color: colors.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDeleteEmployee(context, emp, colors);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteEmployee(
      BuildContext context, Employee emp, DashColors colors) {
    showDialog(
      context: context,
      builder: (ctx) =>
          StatefulBuilder(builder: (_, setDelState) {
            return AlertDialog(
              backgroundColor: colors.card,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              title: Text("Confirmation",
                  style: TextStyle(color: colors.textPrimary)),
              content: Text(
                "Voulez-vous vraiment supprimer ${emp.username} ?",
                style: TextStyle(color: colors.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setDelState(() => isDeletingEmployee = false);
                    Navigator.pop(ctx);
                  },
                  child: Text("Annuler",
                      style: TextStyle(color: colors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: colors.danger),
                  onPressed: isDeletingEmployee
                      ? null
                      : () async {
                    setDelState(() => isDeletingEmployee = true);
                    final deleted = await EmployeeService()
                        .deleteEmployee(emp, context);
                    if (mounted)
                      setDelState(() => isDeletingEmployee = false);
                    if (deleted) {
                      showSuccessMessage(
                          "employée ${emp.username} supprimé",
                          context);
                    }
                    Navigator.pop(ctx);
                    _fetchAllData();
                  },
                  child: isDeletingEmployee
                      ? const BouTikaLoader.compact()
                      : const Text("Supprimer",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }),
    );
  }

  // =========================================================================
  // LOGIQUE DE VENTE
  // =========================================================================
  void _showStartSaleDialog(
      BuildContext context, DashColors colors) async {
    final orderService = OrderService();
    Order? createdOrder;

    final bool? wantsToCreate = await showDialog<bool>(
      context: context,
      builder: (dialogContext) =>
          StatefulBuilder(builder: (_, setPopupState) {
            return AlertDialog(
              backgroundColor: colors.card,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              title: Text("Nouvelle Vente",
                  style: TextStyle(color: colors.textPrimary)),
              content: Text(
                "Voulez-vous créer un nouvel ordre de vente ?",
                style: TextStyle(color: colors.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                    setPopupState(() => isCreatingOrder = false);
                  },
                  child: Text("Non",
                      style: TextStyle(color: colors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary),
                  onPressed: isCreatingOrder
                      ? null
                      : () async {
                    setPopupState(() => isCreatingOrder = true);
                    createdOrder = await orderService
                        .createOrder(widget.store.id, context);
                    if (mounted)
                      setPopupState(() => isCreatingOrder = false);
                    Navigator.pop(
                        dialogContext, createdOrder != null);
                  },
                  child: isCreatingOrder
                      ? const BouTikaLoader.compact()
                      : const Text("Oui",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }),
    );

    if (wantsToCreate == true && createdOrder != null) {
      _showSaleForm(context, createdOrder!.orderId!, colors);
    } else if (wantsToCreate == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Erreur lors de la création de l'ordre."),
          backgroundColor: colors.danger,
        ),
      );
    }
  }

  void _showSaleForm(
      BuildContext context, String orderId, DashColors colors) {
    final formKey = GlobalKey<FormState>();
    final saleLines = [OrderLine()];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          StatefulBuilder(builder: (_, setPopupState) {
            double calculateTotal() => saleLines.fold<double>(
                0.0,
                    (sum, item) =>
                sum +
                    (item.product?.stock?.sellingPrice ?? 0) *
                        item.quantity);

            return AlertDialog(
              backgroundColor: colors.card,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              title: Text("Choix des produits",
                  style: TextStyle(color: colors.textPrimary)),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 550,
                  maxHeight: MediaQuery.sizeOf(context).height * 0.65,
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Ordre de vente",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: colors.textSecondary)),
                          Divider(color: colors.border),
                          ...saleLines.asMap().entries.map((entry) {
                            final index = entry.key;
                            final line  = entry.value;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: DropdownSearch<Product>(
                                      popupProps:
                                      const PopupProps.modalBottomSheet(
                                        showSearchBox: true,
                                        title: Padding(
                                          padding: EdgeInsets.all(12),
                                          child:
                                          Text("Entrez un produit"),
                                        ),
                                      ),
                                      items: allStoreProducts,
                                      itemAsString: (p) => p.name,
                                      dropdownDecoratorProps:
                                      const DropDownDecoratorProps(
                                        dropdownSearchDecoration:
                                        InputDecoration(
                                          labelText: "Produit",
                                          isDense: true,
                                        ),
                                      ),
                                      onChanged: (Product? product) {
                                        setPopupState(() {
                                          line.product     = product;
                                          line.salingPrice = product
                                              ?.stock?.sellingPrice ??
                                              0;
                                          line.maxStock =
                                              (product?.stock?.baseStock ??
                                                  0.0) -
                                                  (product?.stock
                                                      ?.totalSell ??
                                                      0.0);
                                          formKey.currentState?.validate();
                                        });
                                      },
                                      validator: (item) {
                                        if (item == null) return 'Requis';
                                        for (int i = 0; i < index; i++) {
                                          if (saleLines[i].product?.id ==
                                              item.id)
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
                                      decoration: const InputDecoration(
                                          labelText: "Qté",
                                          isDense: true),
                                      onChanged: (val) {
                                        setPopupState(() {
                                          line.quantity =
                                              double.tryParse(val) ?? 0;
                                          formKey.currentState?.validate();
                                        });
                                      },
                                      validator: (val) {
                                        final qty =
                                        num.tryParse(val ?? '');
                                        if (qty == null || qty <= 0)
                                          return "Min 1";
                                        if (line.maxStock != null &&
                                            qty > line.maxStock!)
                                          return "Stock insuffisant (${line.maxStock})";
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          TextButton.icon(
                            onPressed: () => setPopupState(
                                    () => saleLines.add(OrderLine())),
                            icon: Icon(Icons.add_circle_outline,
                                color: colors.primary, size: 18),
                            label: Text(
                              "Ajouter un produit",
                              style: TextStyle(color: colors.primary),
                            ),
                          ),
                          Divider(color: colors.border),
                          Text(
                            "TOTAL: ${calculateTotal().toStringAsFixed(0)} F",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              color: colors.primary,
                            ),
                          ),
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
                      await OrderService()
                          .deleteOrder(orderId, context);
                      if (mounted)
                        setPopupState(() => isCancelingSale = false);
                      Navigator.pop(dialogContext);
                      showSuccessMessage(
                          "ordre annulée avec succès", context);
                    } catch (e) {
                      showErrorMessage(
                          "Erreur lors de la liaison avec le serveur.",
                          context);
                    }
                  },
                  child: Text("Annuler",
                      style: TextStyle(color: colors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(dialogContext);
                      _showFinalConfirmationDialog(context, orderId,
                          saleLines, calculateTotal(), colors);
                    }
                  },
                  child: isCancelingSale
                      ? const BouTikaLoader.compact()
                      : const Text("Valider",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }),
    );
  }

  void _showFinalConfirmationDialog(
      BuildContext context,
      String orderId,
      List<OrderLine> saleLines,
      double total,
      DashColors colors,
      ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          StatefulBuilder(builder: (_, setConfirmationStat) {
            return AlertDialog(
              backgroundColor: colors.card,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              title: Text("Confirmer la Vente",
                  style: TextStyle(color: colors.textPrimary)),
              content: Text(
                "Valider la vente de ${total.toStringAsFixed(0)} F ?",
                style: TextStyle(color: colors.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setConfirmationStat(() => isValidatingSale = false);
                    Navigator.pop(dialogContext);
                  },
                  child: Text("Non",
                      style: TextStyle(color: colors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: colors.success),
                  onPressed: isValidatingSale
                      ? null
                      : () async {
                    final requestData = saleLines
                        .map((line) => {
                      "orderId": orderId,
                      "productId": line.product!.id,
                      "quantity": line.quantity,
                    })
                        .toList();
                    setConfirmationStat(
                            () => isValidatingSale = true);
                    try {
                      final order = await OrderService()
                          .makeOrder(orderId, requestData, context);
                      if (mounted)
                        setConfirmationStat(
                                () => isValidatingSale = false);
                      Navigator.pop(dialogContext);
                      if (order != null) {
                        showSuccessMessage(
                            "Vente enregistrée !", context);
                        _loadAllProductsForSale();
                      } else {
                        showErrorMessage(
                            "Erreur lors de la validation.",
                            context);
                      }
                    } catch (e) {
                      print(e);
                      showExceptionMessage(context);
                    }
                  },
                  child: isValidatingSale
                      ? const BouTikaLoader.compact()
                      : const Text("Oui, Valider",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }),
    );
  }

  // =========================================================================
  // FORMULAIRE CATÉGORIE
  // =========================================================================
  void _showAddCategoryForm(
      BuildContext context, Category? category, DashColors colors) {
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
      builder: (ctx) =>
          StatefulBuilder(builder: (_, setCatState) {
            return AlertDialog(
              backgroundColor: colors.card,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              title: Row(
                children: [
                  Icon(Icons.category, color: colors.primary, size: 20),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      category == null
                          ? "Nouvelle Catégorie"
                          : "Modifier Catégorie",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.textPrimary),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _categoryFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _categoryNameController,
                        style: TextStyle(color: colors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: "Nom de la catégorie",
                          prefixIcon: Icon(Icons.label),
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Le nom est obligatoire'
                            : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _categoryDescController,
                        maxLines: 2,
                        style: TextStyle(color: colors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: "Description",
                          prefixIcon: Icon(Icons.description),
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Veuillez ajouter une description'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setCatState(() => isSavingCategory = false);
                    _categoryNameController.clear();
                    _categoryDescController.clear();
                    Navigator.pop(ctx);
                  },
                  child: Text("Annuler",
                      style: TextStyle(color: colors.danger)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary),
                  onPressed: isSavingCategory
                      ? null
                      : () async {
                    if (_categoryFormKey.currentState!.validate()) {
                      setCatState(() => isSavingCategory = true);
                      final data = {
                        "name": _categoryNameController.text,
                        "description":
                        _categoryDescController.text,
                      };
                      final cs = CategoryService();
                      try {
                        if (category != null) {
                          final cat = await cs.update(
                              category.id, data, context);
                          if (mounted)
                            setCatState(
                                    () => isSavingCategory = false);
                          if (cat == null) {
                            showErrorMessage(
                                "mise à jour a échoué", context);
                          } else {
                            final i = categories.indexOf(category);
                            if (i != -1)
                              setState(() => categories[i] = cat);
                          }
                          showSuccessMessage(
                              "catégorie mise à jour", context);
                        } else {
                          await cs.create(
                              data, widget.store.id, context);
                          showSuccessMessage(
                              "catégorie ajoutée", context);
                          _fetchAllData();
                        }
                        Navigator.pop(ctx);
                      } catch (e) {
                        showExceptionMessage(context);
                      }
                    }
                  },
                  child: isSavingCategory
                      ? const BouTikaLoader.compact()
                      : Text(
                    category == null ? "Créer" : "Enregistrer",
                    style:
                    const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          }),
    );
  }

  // =========================================================================
  // FORMULAIRE EMPLOYÉ
  // =========================================================================
  void _showAddEmployeeForm(BuildContext context, DashColors colors,
      {Employee? employee}) {
    _firstnameController.clear();
    _secondnameController.clear();
    _usernameController.clear();
    _phoneController.clear();
    _passwordController.clear();

    showDialog(
      context: context,
      builder: (ctx) =>
          StatefulBuilder(builder: (_, setSaveEmpState) {
            return AlertDialog(
              backgroundColor: colors.card,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              title: Text(
                employee == null
                    ? "Ajouter un employé"
                    : "Modifier ${employee.username}",
                style: TextStyle(color: colors.textPrimary),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _firstnameController,
                        style: TextStyle(color: colors.textPrimary),
                        decoration: const InputDecoration(
                            labelText: "Prénom"),
                      ),
                      TextFormField(
                        controller: _secondnameController,
                        style: TextStyle(color: colors.textPrimary),
                        decoration:
                        const InputDecoration(labelText: "Nom"),
                      ),
                      TextFormField(
                        controller: _usernameController,
                        style: TextStyle(color: colors.textPrimary),
                        decoration: const InputDecoration(
                            labelText: "Nom d'utilisateur"),
                      ),
                      TextFormField(
                        controller: _phoneController,
                        style: TextStyle(color: colors.textPrimary),
                        decoration: const InputDecoration(
                            labelText: "Téléphone"),
                      ),
                      TextFormField(
                        controller: _passwordController,
                        style: TextStyle(color: colors.textPrimary),
                        decoration: const InputDecoration(
                            labelText: "Mot de passe"),
                        obscureText: true,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    setSaveEmpState(() => isSavingEmployee = false);
                  },
                  child: Text("Annuler",
                      style: TextStyle(color: colors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary),
                  onPressed: isSavingEmployee
                      ? null
                      : () async {
                    setSaveEmpState(() => isSavingEmployee = true);
                    if (_formKey.currentState!.validate()) {
                      final employeeMap = {
                        "firstname": _firstnameController.text,
                        "secondName": _secondnameController.text,
                        "username": _usernameController.text,
                        "post": "SALESPERSON",
                        "password": _passwordController.text,
                        "phone": _phoneController.text,
                      };
                      try {
                        await EmployeeService().addEmployee(
                            employeeMap, widget.store.id, context);
                        if (mounted)
                          setSaveEmpState(
                                  () => isSavingEmployee = false);
                        Navigator.pop(ctx);
                        showSuccessMessage(
                            "employé ajouté", context);
                        _fetchAllData();
                      } catch (e) {
                        showExceptionMessage(context);
                      }
                    }
                  },
                  child: isSavingEmployee
                      ? const BouTikaLoader.compact()
                      : Text(
                    employee == null ? "Ajouter" : "Enregistrer",
                    style:
                    const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          }),
    );
  }

  // =========================================================================
  // DÉCONNEXION
  // =========================================================================
  void _handleLogout(BuildContext context, DashColors colors) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
        title: Text("Déconnexion",
            style: TextStyle(color: colors.textPrimary)),
        content: Text(
          "Voulez-vous vraiment quitter BouTiKa ?",
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Annuler",
                style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: colors.danger),
            onPressed: () async {
              await UserService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
                    (route) => false,
              );
            },
            child: const Text("Se déconnecter",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // FORMULAIRE DÉPENSE
  // =========================================================================
  void _showExpenseDialog(BuildContext context, DashColors colors) {
    bool isSavingExpense = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          StatefulBuilder(builder: (_, setPopupState) {
            return AlertDialog(
              backgroundColor: colors.card,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              title: Row(
                children: [
                  Icon(Icons.remove_circle_outline,
                      color: colors.accent, size: 20),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text("Nouvelle Dépense",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colors.textPrimary)),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _expenseFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _expensePriceController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: colors.textPrimary),
                        decoration: InputDecoration(
                          labelText: "Montant (F)",
                          prefixIcon:
                          const Icon(Icons.payments_outlined),
                          filled: true,
                          fillColor: colors.cardElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? "Indiquez le montant"
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _expenseDescController,
                        maxLines: 2,
                        style: TextStyle(color: colors.textPrimary),
                        decoration: InputDecoration(
                          labelText: "Description / Motif",
                          prefixIcon:
                          const Icon(Icons.description_outlined),
                          filled: true,
                          fillColor: colors.cardElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? "Indiquez le motif"
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _expensePriceController.clear();
                    _expenseDescController.clear();
                    Navigator.pop(ctx);
                  },
                  child: Text("Annuler",
                      style: TextStyle(color: colors.danger)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.accent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: isSavingExpense
                      ? null
                      : () async {
                    if (_expenseFormKey.currentState!.validate()) {
                      setPopupState(() => isSavingExpense = true);
                      try {
                        await SpendingServcie().saveSpending(
                          Spending(
                            price: double.parse(
                                _expensePriceController.text),
                            description:
                            _expenseDescController.text,
                            storeId: widget.store.id,
                          ),
                          context,
                        );
                        if (mounted) {
                          _expensePriceController.clear();
                          _expenseDescController.clear();
                          Navigator.pop(ctx);
                        }
                      } catch (e) {
                        print(e);
                        showErrorMessage(
                            "Erreur lors de l'enregistrement",
                            context);
                      } finally {
                        if (mounted)
                          setPopupState(
                                  () => isSavingExpense = false);
                      }
                    }
                  },
                  child: isSavingExpense
                      ? const BouTikaLoader.compact()
                      : const Text("Enregistrer",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }),
    );
  }
}

// ===========================================================================
// CATEGORY CARD
// ===========================================================================
class _CategoryCard extends StatefulWidget {
  final Category category;
  final String userType;
  final DashColors colors;
  final VoidCallback onEdit;
  final VoidCallback onManage;

  const _CategoryCard({
    required this.category,
    required this.userType,
    required this.colors,
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
    final colors   = widget.colors;
    final category = widget.category;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _expanded
              ? colors.primary.withOpacity(0.30)
              : colors.border,
          width: 1.1,
        ),
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                      color: _expanded
                          ? colors.primary.withOpacity(0.14)
                          : colors.primarySoft,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(Icons.category_rounded,
                        color: colors.primary, size: 21),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.5,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text("Gérer le stock et les prix",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colors.cardElevated,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: colors.textSecondary,
                        size: 19,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenu extensible
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            sizeCurve: Curves.easeOut,
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 1, color: colors.border),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.cardElevated,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "DESCRIPTION",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.description ??
                        "Aucune description fournie.",
                    style: TextStyle(
                        color: colors.textPrimary,
                        height: 1.4,
                        fontSize: 13),
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
                            colors: colors,
                            onTap: widget.onEdit,
                          ),
                        ),
                      if (widget.userType == "employer")
                        const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _CategoryActionButton(
                          icon: Icons.inventory_2_outlined,
                          label: "Gérer les produits",
                          filled: true,
                          colors: colors,
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

// ===========================================================================
// BOUTON D'ACTION CATÉGORIE
// ===========================================================================
class _CategoryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final DashColors colors;
  final VoidCallback onTap;

  const _CategoryActionButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? colors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              vertical: 11, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: filled
                ? null
                : Border.all(color: colors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: filled ? Colors.white : colors.textPrimary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color:
                    filled ? Colors.white : colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
