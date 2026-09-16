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
import 'package:mobile_store_app/utils/app_colors.dart';
import 'package:mobile_store_app/utils/message.dart';
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
// Modèle ligne de vente — logique métier inchangée
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
// Couleurs sémantiques fixes — mises à jour vers palette sobre premium
// ---------------------------------------------------------------------------
class _Fixed {
  // Désormais sobre, plus d'orange saturé
  static const accent = Color(0xFF64748B);
  static const accentSoft = Color(0xFFF1F5F9);
  static const danger = Color(0xFF9F6B6B);
  static const dangerSoft = Color(0xFFFDF2F2);
  static const success = Color(0xFF5A8A7A);
  static const successSoft = Color(0xFFEEF5F2);
}

class _NavItemData {
  final IconData icon;
  final IconData filledIcon;
  final String label;
  _NavItemData(this.icon, this.filledIcon, this.label);
}

// ---------------------------------------------------------------------------
// Widget principal — logique métier strictement préservée
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
  bool _isLoading = true;

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
  // Chargement des données — inchangé
  // -------------------------------------------------------------------------
  Future<void> _fetchAllData() async {
    try {
      await _loadEmployeesAndCategories();
      await _loadAllProductsForSale();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadEmployeesAndCategories() async {
    final list = await EmployeeService().getEmployeeOfStore(widget.store.id, context);
    final cats = await CategoryService().getCategoryByStoreId(widget.store.id, context);
    if (mounted) setState(() { employees = list; categories = cats; });
  }

  Future<void> getEmployeeByStoreId(String storeId) => _loadEmployeesAndCategories();

  Future<void> _loadAllProductsForSale() async {
    final products = await ProductService().getAllProductByStoreId(widget.store.id);
    if (mounted) {
      setState(() {
        allStoreProducts = products;
        lowStockProducts = getLowStockProduct(allStoreProducts);
      });
    }
  }

  // =========================================================================
  // BUILD PRINCIPAL — sobre, hiérarchie lumineuse maîtrisée
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: appDarkMode,
      builder: (context, isDark, __) {
        final colors = DashColors(context);
        final ext = colors.ext;

        if (_isLoading) {
          return Scaffold(
            backgroundColor: ext.background,
            body: const Center(child: BouTikaLoader()),
          );
        }

        return Scaffold(
          backgroundColor: ext.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildTopBar(context, colors),
                Container(height: 1, color: ext.border.withOpacity(0.6)),
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
          floatingActionButton: _currentIndex == 0 ? _buildSaleAndExpenseFab(context, colors) : null,
          bottomNavigationBar: _buildBottomNav(context, colors),
        );
      },
    );
  }

  // =========================================================================
  // TOP BAR — minimal premium, plus de pill orange agressif
  // =========================================================================
  Widget _buildTopBar(BuildContext context, DashColors colors) {
    final ext = colors.ext;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          // Sélecteur boutique — avatar + nom sobre
          Expanded(
            child: GestureDetector(
              onTap: () => _showStoreSwitcherSheet(context, colors),
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: ext.surfaceMuted,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: ext.border, width: 1),
                    ),
                    child: Icon(Icons.storefront_rounded, color: ext.mutedForeground, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.store.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: ext.foreground, letterSpacing: -0.1),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(color: ext.success, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Text("Boutique active", style: TextStyle(fontSize: 11.5, color: ext.mutedForeground, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: ext.surfaceMuted, borderRadius: BorderRadius.circular(6)),
                    child: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: ext.mutedForeground),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          _topIconButton(
            icon: appDarkMode.value ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            colors: colors,
            onTap: () => appDarkMode.value = !appDarkMode.value,
          ),
          const SizedBox(width: 8),
          _topIconButton(
            icon: Icons.notifications_outlined,
            colors: colors,
            badge: lowStockProducts.isNotEmpty,
            badgeCount: lowStockProducts.length,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LowStockProductDetailsScreen(products: lowStockProducts, userType: widget.userType)),
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
    int badgeCount = 0,
    required VoidCallback onTap,
  }) {
    final ext = colors.ext;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: ext.card,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: ext.border, width: 1),
            ),
            child: Icon(icon, size: 18, color: ext.mutedForeground),
          ),
          if (badge)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                decoration: BoxDecoration(
                  color: ext.danger,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: ext.background, width: 1.5),
                ),
                child: badgeCount > 0
                    ? Text("$badgeCount", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))
                    : const SizedBox(width: 8, height: 8),
              ),
            ),
        ],
      ),
    );
  }

  // =========================================================================
  // STORE SWITCHER SHEET — sobre, lisible, hiérarchie claire
  // =========================================================================
  void _showStoreSwitcherSheet(BuildContext context, DashColors colors) {
    final ext = colors.ext;
    showModalBottomSheet(
      context: context,
      backgroundColor: ext.card,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl2))),
      builder: (ctx) {
        final maxHeight = MediaQuery.sizeOf(ctx).height * 0.72;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(width: 32, height: 4, decoration: BoxDecoration(color: ext.border, borderRadius: BorderRadius.circular(4))),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Mes boutiques", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: ext.foreground, letterSpacing: -0.2)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: ext.surfaceMuted, borderRadius: BorderRadius.circular(20)),
                        child: Text("${displayStore.length + 1}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ext.mutedForeground)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text("Sélectionnez la boutique à gérer", style: TextStyle(fontSize: 13, color: ext.mutedForeground)),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                    children: [
                      // Boutique active
                      Container(
                        decoration: BoxDecoration(
                          color: ext.primarySoft,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: ext.primary.withOpacity(0.12), width: 1),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: ext.card, borderRadius: BorderRadius.circular(AppRadius.sm), border: Border.all(color: ext.border)),
                            child: Icon(Icons.check_rounded, color: ext.primary, size: 18),
                          ),
                          title: Text(widget.store.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: ext.foreground)),
                          subtitle: Text("Boutique active • ${categories.length} catégories", style: TextStyle(fontSize: 12, color: ext.mutedForeground)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: ext.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: ext.border)),
                            child: Text("ACTIF", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: ext.primary)),
                          ),
                        ),
                      ),
                      if (displayStore.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text("AUTRES BOUTIQUES", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: ext.mutedForeground)),
                        ),
                        const SizedBox(height: 8),
                        ...displayStore.map((newStore) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: ext.card,
                                  borderRadius: BorderRadius.circular(AppRadius.lg),
                                  border: Border.all(color: ext.border, width: 1),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: ext.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.sm)),
                                    child: Icon(Icons.storefront_outlined, color: ext.mutedForeground, size: 18),
                                  ),
                                  title: Text(newStore.name, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: ext.foreground)),
                                  subtitle: Text("Appuyer pour ouvrir", style: TextStyle(fontSize: 12, color: ext.mutedForeground)),
                                  trailing: Icon(Icons.chevron_right_rounded, color: ext.mutedForeground, size: 20),
                                  onTap: () {
                                    final nextOthers = List<Store>.from(widget.otherStores)
                                      ..removeWhere((s) => s.id == newStore.id)
                                      ..add(widget.store);
                                    Navigator.pop(ctx);
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => StoreDetailScreen(store: newStore, userType: widget.userType, otherStores: nextOthers)));
                                  },
                                ),
                              ),
                            )),
                      ],
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
  // BOTTOM NAV — minimal, bordure subtile, pas d'ombre agressive
  // =========================================================================
  Widget _buildBottomNav(BuildContext context, DashColors colors) {
    final ext = colors.ext;
    final items = [
      _NavItemData(Icons.home_outlined, Icons.home_rounded, "Accueil"),
      _NavItemData(Icons.receipt_long_outlined, Icons.receipt_long_rounded, "Ventes"),
      _NavItemData(Icons.inventory_2_outlined, Icons.inventory_2_rounded, "Stock"),
      _NavItemData(Icons.settings_outlined, Icons.settings_rounded, "Plus"),
    ];

    return Container(
      decoration: BoxDecoration(
        color: ext.card,
        border: Border(top: BorderSide(color: ext.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: List.generate(items.length, (index) {
              final selected = _currentIndex == index;
              final item = items[index];
              final showBadge = index == 2 && lowStockProducts.isNotEmpty;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _currentIndex = index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: AppDurations.normal,
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? ext.surfaceMuted : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AnimatedContainer(
                              duration: AppDurations.normal,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: selected ? ext.card : Colors.transparent,
                                borderRadius: BorderRadius.circular(AppRadius.full),
                                border: Border.all(color: selected ? ext.border : Colors.transparent, width: 1),
                              ),
                              child: Icon(selected ? item.filledIcon : item.icon, color: selected ? ext.foreground : ext.mutedForeground, size: 20),
                            ),
                            if (showBadge)
                              Positioned(
                                right: 6,
                                top: 2,
                                child: Container(width: 6, height: 6, decoration: BoxDecoration(color: ext.danger, shape: BoxShape.circle)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.w600 : FontWeight.w400, color: selected ? ext.foreground : ext.mutedForeground, letterSpacing: 0.1),
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
  // HELPERS DÉCORATIONS — cohérence totale, ombres ultra subtiles
  // =========================================================================
  BoxDecoration _cardDecoration(DashColors colors, {double radius = 16}) {
    final ext = colors.ext;
    return BoxDecoration(
      color: ext.card,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: ext.border, width: 1),
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
    final ext = colors.ext;
    return Container(
      margin: margin ?? const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: _cardDecoration(colors, radius: AppRadius.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: ext.foreground, letterSpacing: -0.2)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(subtitle, style: TextStyle(fontSize: 13, color: ext.mutedForeground, height: 1.3)),
                      ],
                    ],
                  ),
                ),
                if (icon != null)
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: ext.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.sm), border: Border.all(color: ext.border)),
                    child: Icon(icon, color: ext.mutedForeground, size: 18),
                  ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(20), child: child),
        ],
      ),
    );
  }

  // =========================================================================
  // ONGLET 0 — ACCUEIL
  // =========================================================================
  Widget _buildDashboardTab(BuildContext context, DashColors colors) {
    final ext = colors.ext;
    return RefreshIndicator(
      onRefresh: _fetchAllData,
      color: ext.foreground,
      backgroundColor: ext.card,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEmployeeSection(context, colors),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Inventaire", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ext.foreground, letterSpacing: -0.1)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: ext.surfaceMuted, borderRadius: BorderRadius.circular(20), border: Border.all(color: ext.border)),
                    child: Text("${categories.length} catégories", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: ext.mutedForeground)),
                  ),
                ],
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
    return OrderStoryScreen(storeId: widget.store.id, userType: widget.userType, categories: categories, embedded: true);
  }

  // =========================================================================
  // ONGLET 2 — STOCK — hub sobre
  // =========================================================================
  Widget _buildStockTab(BuildContext context, DashColors colors) {
    final ext = colors.ext;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text("Gestion du stock", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: ext.foreground, letterSpacing: -0.3)),
        const SizedBox(height: 6),
        Text("Suivez votre inventaire en temps réel", style: TextStyle(color: ext.mutedForeground, fontSize: 13, height: 1.4)),
        const SizedBox(height: 24),
        _buildHubCard(
          icon: Icons.history_rounded,
          color: ext.foreground,
          title: "Historique de restockage",
          subtitle: "Consultez les réapprovisionnements passés",
          colors: colors,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RestockHistoryScreen(products: allStoreProducts))),
        ),
        const SizedBox(height: 12),
        _buildHubCard(
          icon: Icons.warning_amber_rounded,
          color: ext.danger,
          title: "Produits en alerte",
          subtitle: lowStockProducts.isEmpty ? "Aucune alerte pour le moment" : "${lowStockProducts.length} produit(s) sous le seuil",
          badge: lowStockProducts.isNotEmpty ? lowStockProducts.length : null,
          colors: colors,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LowStockProductDetailsScreen(products: lowStockProducts, userType: widget.userType))),
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
    final ext = colors.ext;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(colors, radius: AppRadius.lg),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: ext.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: ext.border)),
              child: Icon(icon, color: color == ext.danger ? ext.danger : ext.mutedForeground, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: ext.foreground))),
                      if (badge != null)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(color: ext.dangerSoft, borderRadius: BorderRadius.circular(20), border: Border.all(color: ext.danger.withOpacity(0.15))),
                          child: Text("$badge", style: TextStyle(color: ext.danger, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(subtitle, style: TextStyle(color: ext.mutedForeground, fontSize: 12.5, height: 1.3)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: ext.mutedForeground, size: 20),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // ONGLET 3 — PLUS — profil et actions sobres
  // =========================================================================
  Widget _buildMoreTab(BuildContext context, DashColors colors) {
    final ext = colors.ext;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      children: [
        // Carte profil
        Container(
          padding: const EdgeInsets.all(18),
          decoration: _cardDecoration(colors, radius: AppRadius.lg),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: ext.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.full), border: Border.all(color: ext.border)),
                child: Icon(Icons.person_rounded, color: ext.mutedForeground, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${UserService.username}", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: ext.foreground, letterSpacing: -0.1)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(color: ext.surfaceMuted, borderRadius: BorderRadius.circular(20), border: Border.all(color: ext.border)),
                      child: Text(
                        widget.userType == 'employee' ? "EMPLOYÉ" : "PROPRIÉTAIRE",
                        style: TextStyle(color: ext.mutedForeground, fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.6),
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
          decoration: _cardDecoration(colors, radius: AppRadius.lg),
          child: Column(
            children: [
              _buildMoreActionTile(
                icon: Icons.account_balance_wallet_outlined,
                title: "Mes Dépenses",
                subtitle: "Suivi des sorties de caisse",
                colors: colors,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExpensesScreen(storeId: widget.store.id))),
              ),
              if (widget.store.subscription != null) ...[
                Divider(height: 1, color: ext.border),
                _buildMoreActionTile(
                  icon: Icons.workspace_premium_outlined,
                  title: "Mon abonnement",
                  subtitle: "Gérer votre plan",
                  colors: colors,
                  onTap: () {
                    final sub = widget.store.subscription!;
                    Navigator.push(context, MaterialPageRoute(builder: (_) => SubscriptionScreen(storeName: widget.store.name, planType: sub.plan!, duration: sub.duration!, startDate: sub.startDate!, expiryDate: sub.expirationDate!)));
                  },
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: _cardDecoration(colors, radius: AppRadius.lg),
          child: _buildMoreActionTile(
            icon: Icons.logout_rounded,
            title: "Déconnexion",
            subtitle: "Quitter la session",
            colors: colors,
            isDestructive: true,
            onTap: () => _handleLogout(context, colors),
          ),
        ),
        const SizedBox(height: 24),
        Center(child: Text("BouTika • v1.0.0", style: TextStyle(fontSize: 11, color: ext.mutedForeground.withOpacity(0.6), letterSpacing: 0.2))),
      ],
    );
  }

  Widget _buildMoreActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required DashColors colors,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final ext = colors.ext;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDestructive ? ext.dangerSoft : ext.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: isDestructive ? ext.danger.withOpacity(0.15) : ext.border),
        ),
        child: Icon(icon, color: isDestructive ? ext.danger : ext.mutedForeground, size: 18),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: isDestructive ? ext.danger : ext.foreground)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 12, color: ext.mutedForeground)) : null,
      trailing: Icon(Icons.chevron_right_rounded, color: ext.mutedForeground.withOpacity(0.6), size: 20),
      onTap: onTap,
    );
  }

  // =========================================================================
  // FAB — deux actions hiérarchisées, plus de couleurs agressives
  // =========================================================================
  Widget _buildSaleAndExpenseFab(BuildContext context, DashColors colors) {
    final ext = colors.ext;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Dépense — secondaire, outline
        Material(
          color: ext.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          elevation: 0,
          child: InkWell(
            onTap: () => _showExpenseDialog(context, colors),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: ext.border, width: 1)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.remove_circle_outline_rounded, color: ext.mutedForeground, size: 18),
                  const SizedBox(width: 8),
                  Text("Dépense", style: TextStyle(color: ext.foreground, fontWeight: FontWeight.w600, fontSize: 13.5)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Vendre — primaire sobre
        Material(
          color: ext.foreground,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          elevation: 0,
          child: InkWell(
            onTap: () => _showStartSaleDialog(context, colors),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.lg)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_bag_outlined, color: ext.background, size: 18),
                  const SizedBox(width: 8),
                  Text("Vendre", style: TextStyle(color: ext.background, fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.1)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // SECTION EMPLOYÉS — avatars épurés
  // =========================================================================
  Widget _buildEmployeeSection(BuildContext context, DashColors colors) {
    final ext = colors.ext;
    return _sectionCard(
      title: "Équipe de vente",
      subtitle: "${employees.length} membre(s) actif(s)",
      icon: Icons.groups_outlined,
      colors: colors,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (employees.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: ext.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.full), border: Border.all(color: ext.border)),
                      child: Icon(Icons.person_add_alt_1_outlined, color: ext.mutedForeground.withOpacity(0.6), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text("Aucun employé pour le moment", style: TextStyle(color: ext.mutedForeground, fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
              )
            else
              ...employees.map((emp) => _buildClickableAvatar(context, emp, colors)),
            if (widget.userType == "employer")
              GestureDetector(
                onTap: () => _showAddEmployeeForm(context, colors),
                child: Padding(
                  padding: const EdgeInsets.only(right: 8, left: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(color: ext.card, shape: BoxShape.circle, border: Border.all(color: ext.border, width: 1)),
                        child: Icon(Icons.add_rounded, color: ext.mutedForeground, size: 20),
                      ),
                      const SizedBox(height: 6),
                      Text("Ajouter", style: TextStyle(color: ext.mutedForeground, fontSize: 11, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildClickableAvatar(BuildContext context, Employee emp, DashColors colors) {
    final ext = colors.ext;
    return GestureDetector(
      onLongPress: () {
        if (widget.userType == "employer") _showEmployeeOptions(context, emp, colors);
      },
      onTap: () {
        if (widget.userType == "employer") _showEmployeeOptions(context, emp, colors);
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: SizedBox(
          width: 64,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: ext.surfaceMuted, shape: BoxShape.circle, border: Border.all(color: ext.border, width: 1)),
                child: Icon(Icons.person_rounded, color: ext.mutedForeground, size: 20),
              ),
              const SizedBox(height: 6),
              Text(emp.username ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: ext.foreground, fontSize: 11.5, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // LISTE DES CATÉGORIES
  // =========================================================================
  Widget _buildCategoryList(BuildContext context, List<Category> cats, DashColors colors) {
    final ext = colors.ext;
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
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(color: ext.card, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: ext.border, style: BorderStyle.solid, width: 1)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: ext.surfaceMuted, borderRadius: BorderRadius.circular(6)),
                    child: Icon(Icons.add_rounded, color: ext.mutedForeground, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text("Nouvelle catégorie", style: TextStyle(color: ext.mutedForeground, fontSize: 13.5, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandableCategory(BuildContext context, Category category, DashColors colors) {
    return _CategoryCard(
      category: category,
      userType: widget.userType,
      colors: colors,
      onEdit: () => _showAddCategoryForm(context, category, colors),
      onManage: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => EmployerCategoryDetailScreen(category: category, userType: widget.userType))).then((_) => _fetchAllData());
      },
    );
  }

  // =========================================================================
  // OPTIONS EMPLOYÉ — bottom sheet sobre
  // =========================================================================
  void _showEmployeeOptions(BuildContext context, Employee emp, DashColors colors) {
    final ext = colors.ext;
    showModalBottomSheet(
      context: context,
      backgroundColor: ext.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl2))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 32, height: 4, decoration: BoxDecoration(color: ext.border, borderRadius: BorderRadius.circular(4)))),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: ext.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.full), border: Border.all(color: ext.border)),
                    child: Icon(Icons.person_rounded, color: ext.mutedForeground, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(emp.username ?? '', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: ext.foreground)),
                        Text("Appuyez pour gérer", style: TextStyle(fontSize: 12.5, color: ext.mutedForeground)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(height: 1, color: ext.border),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: ext.dangerSoft, borderRadius: BorderRadius.circular(AppRadius.sm), border: Border.all(color: ext.danger.withOpacity(0.15))),
                  child: Icon(Icons.delete_outline_rounded, color: ext.danger, size: 18),
                ),
                title: Text("Supprimer l'employé", style: TextStyle(color: ext.danger, fontWeight: FontWeight.w500, fontSize: 14)),
                subtitle: Text("Action irréversible", style: TextStyle(color: ext.mutedForeground, fontSize: 12)),
                trailing: Icon(Icons.chevron_right_rounded, color: ext.mutedForeground.withOpacity(0.5), size: 20),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDeleteEmployee(context, emp, colors);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteEmployee(BuildContext context, Employee emp, DashColors colors) {
    final ext = colors.ext;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (_, setDelState) {
        return AlertDialog(
          backgroundColor: ext.card,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
          title: Text("Supprimer l'employé ?", style: TextStyle(color: ext.foreground, fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: -0.2)),
          content: Text("Voulez-vous vraiment supprimer ${emp.username} ? Cette action est irréversible.", style: TextStyle(color: ext.mutedForeground, fontSize: 14, height: 1.4)),
          actions: [
            TextButton(
              onPressed: () {
                setDelState(() => isDeletingEmployee = false);
                Navigator.pop(ctx);
              },
              child: Text("Annuler", style: TextStyle(color: ext.mutedForeground, fontWeight: FontWeight.w500)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: ext.danger, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)), elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
              onPressed: isDeletingEmployee
                  ? null
                  : () async {
                      setDelState(() => isDeletingEmployee = true);
                      final deleted = await EmployeeService().deleteEmployee(emp, context);
                      if (mounted) setDelState(() => isDeletingEmployee = false);
                      if (deleted) showSuccessMessage("employée ${emp.username} supprimé", context);
                      Navigator.pop(ctx);
                      _fetchAllData();
                    },
              child: isDeletingEmployee ? const BouTikaLoader.compact() : const Text("Supprimer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      }),
    );
  }

  // =========================================================================
  // LOGIQUE DE VENTE — inchangée, UI refondue
  // =========================================================================
  void _showStartSaleDialog(BuildContext context, DashColors colors) async {
    final ext = colors.ext;
    final orderService = OrderService();
    Order? createdOrder;

    final bool? wantsToCreate = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(builder: (_, setPopupState) {
        return AlertDialog(
          backgroundColor: ext.card,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
          title: Text("Nouvelle vente", style: TextStyle(color: ext.foreground, fontWeight: FontWeight.w600, fontSize: 16)),
          content: Text("Voulez-vous créer un nouvel ordre de vente ?", style: TextStyle(color: ext.mutedForeground, fontSize: 14, height: 1.4)),
          actions: [
            TextButton(onPressed: () { Navigator.pop(dialogContext, false); setPopupState(() => isCreatingOrder = false); }, child: Text("Non", style: TextStyle(color: ext.mutedForeground))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: ext.foreground, foregroundColor: ext.background, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)), elevation: 0),
              onPressed: isCreatingOrder ? null : () async {
                setPopupState(() => isCreatingOrder = true);
                createdOrder = await orderService.createOrder(widget.store.id, context);
                if (mounted) setPopupState(() => isCreatingOrder = false);
                Navigator.pop(dialogContext, createdOrder != null);
              },
              child: isCreatingOrder ? const BouTikaLoader.compact() : Text("Oui, créer", style: TextStyle(color: ext.background, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      }),
    );

    if (wantsToCreate == true && createdOrder != null) {
      _showSaleForm(context, createdOrder!.orderId!, colors);
    } else if (wantsToCreate == true) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Erreur lors de la création de l'ordre."), backgroundColor: ext.danger));
    }
  }

  void _showSaleForm(BuildContext context, String orderId, DashColors colors) {
    final ext = colors.ext;
    final formKey = GlobalKey<FormState>();
    final saleLines = [OrderLine()];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(builder: (_, setPopupState) {
        double calculateTotal() => saleLines.fold<double>(0.0, (sum, item) => sum + (item.product?.stock?.sellingPrice ?? 0) * item.quantity);

        return AlertDialog(
          backgroundColor: ext.card,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
          title: Row(
            children: [
              Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: ext.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.sm), border: Border.all(color: ext.border)), child: Icon(Icons.shopping_bag_outlined, size: 16, color: ext.mutedForeground)),
              const SizedBox(width: 10),
              Text("Choix des produits", style: TextStyle(color: ext.foreground, fontWeight: FontWeight.w600, fontSize: 15)),
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 520, maxHeight: MediaQuery.sizeOf(context).height * 0.62),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.88,
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: ext.surfaceMuted, borderRadius: BorderRadius.circular(20), border: Border.all(color: ext.border)),
                        child: Text("ORDRE #${orderId.substring(0, 8)}", style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: ext.mutedForeground)),
                      ),
                      const SizedBox(height: 16),
                      ...saleLines.asMap().entries.map((entry) {
                        final index = entry.key;
                        final line = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: DropdownSearch<Product>(
                                  popupProps: const PopupProps.modalBottomSheet(
                                    showSearchBox: true,
                                    title: Padding(padding: EdgeInsets.all(14), child: Text("Sélectionner un produit")),
                                  ),
                                  items: allStoreProducts,
                                  itemAsString: (p) => p.name,
                                  dropdownDecoratorProps: DropDownDecoratorProps(
                                    dropdownSearchDecoration: InputDecoration(labelText: "Produit", isDense: true, filled: true, fillColor: ext.surfaceMuted, border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: ext.border))),
                                  ),
                                  onChanged: (Product? product) {
                                    setPopupState(() {
                                      line.product = product;
                                      line.salingPrice = product?.stock?.sellingPrice ?? 0;
                                      line.maxStock = (product?.stock?.baseStock ?? 0.0) - (product?.stock?.totalSell ?? 0.0);
                                      formKey.currentState?.validate();
                                    });
                                  },
                                  validator: (item) {
                                    if (item == null) return 'Requis';
                                    for (int i = 0; i < index; i++) {
                                      if (saleLines[i].product?.id == item.id) return "Déjà ajouté";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: "1",
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(color: ext.foreground, fontSize: 14),
                                  decoration: InputDecoration(labelText: "Qté", isDense: true, filled: true, fillColor: ext.surfaceMuted, border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: ext.border))),
                                  onChanged: (val) {
                                    setPopupState(() {
                                      line.quantity = double.tryParse(val) ?? 0;
                                      formKey.currentState?.validate();
                                    });
                                  },
                                  validator: (val) {
                                    final qty = num.tryParse(val ?? '');
                                    if (qty == null || qty <= 0) return "Min 1";
                                    if (line.maxStock != null && qty > line.maxStock!) return "Stock ${line.maxStock!.toStringAsFixed(0)}";
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => setPopupState(() => saleLines.add(OrderLine())),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(border: Border.all(color: ext.border), borderRadius: BorderRadius.circular(AppRadius.md)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_rounded, color: ext.mutedForeground, size: 16),
                              const SizedBox(width: 6),
                              Text("Ajouter un produit", style: TextStyle(color: ext.mutedForeground, fontSize: 13, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: ext.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: ext.border)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("TOTAL", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: ext.mutedForeground)),
                            Text("${calculateTotal().toStringAsFixed(0)} F", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: ext.foreground, letterSpacing: -0.2)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: isCancelingSale ? null : () async { try { setPopupState(() => isCancelingSale = true); await OrderService().deleteOrder(orderId, context); if (mounted) setPopupState(() => isCancelingSale = false); Navigator.pop(dialogContext); showSuccessMessage("ordre annulée avec succès", context); } catch (e) { showErrorMessage("Erreur lors de la liaison avec le serveur.", context); } }, child: Text("Annuler", style: TextStyle(color: ext.mutedForeground))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: ext.foreground, foregroundColor: ext.background, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)), elevation: 0),
              onPressed: () { if (formKey.currentState!.validate()) { Navigator.pop(dialogContext); _showFinalConfirmationDialog(context, orderId, saleLines, calculateTotal(), colors); } },
              child: isCancelingSale ? const BouTikaLoader.compact() : Text("Valider", style: TextStyle(color: ext.background, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      }),
    );
  }

  void _showFinalConfirmationDialog(BuildContext context, String orderId, List<OrderLine> saleLines, double total, DashColors colors) {
    final ext = colors.ext;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(builder: (_, setConfirmationStat) {
        return AlertDialog(
          backgroundColor: ext.card,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
          title: Text("Confirmer la vente ?", style: TextStyle(color: ext.foreground, fontWeight: FontWeight.w600, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Valider la vente de", style: TextStyle(color: ext.mutedForeground, fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: ext.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: ext.border)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Montant total", style: TextStyle(fontSize: 12, color: ext.mutedForeground)),
                    Text("${total.toStringAsFixed(0)} F", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: ext.foreground)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () { setConfirmationStat(() => isValidatingSale = false); Navigator.pop(dialogContext); }, child: Text("Non", style: TextStyle(color: ext.mutedForeground))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: ext.success, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)), elevation: 0),
              onPressed: isValidatingSale ? null : () async {
                final requestData = saleLines.map((line) => {"orderId": orderId, "productId": line.product!.id, "quantity": line.quantity}).toList();
                setConfirmationStat(() => isValidatingSale = true);
                try {
                  final order = await OrderService().makeOrder(orderId, requestData, context);
                  if (mounted) setConfirmationStat(() => isValidatingSale = false);
                  Navigator.pop(dialogContext);
                  if (order != null) { showSuccessMessage("Vente enregistrée !", context); _loadAllProductsForSale(); } else { showErrorMessage("Erreur lors de la validation.", context); }
                } catch (e) { print(e); showExceptionMessage(context); }
              },
              child: isValidatingSale ? const BouTikaLoader.compact() : const Text("Oui, valider", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      }),
    );
  }

  // =========================================================================
  // FORMULAIRE CATÉGORIE — sobre
  // =========================================================================
  void _showAddCategoryForm(BuildContext context, Category? category, DashColors colors) {
    final ext = colors.ext;
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
      builder: (ctx) => StatefulBuilder(builder: (_, setCatState) {
        return AlertDialog(
          backgroundColor: ext.card,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
          title: Row(
            children: [
              Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: ext.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.sm), border: Border.all(color: ext.border)), child: Icon(Icons.category_outlined, color: ext.mutedForeground, size: 16)),
              const SizedBox(width: 10),
              Flexible(child: Text(category == null ? "Nouvelle catégorie" : "Modifier catégorie", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: ext.foreground, fontWeight: FontWeight.w600, fontSize: 15))),
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
                    style: TextStyle(color: ext.foreground, fontSize: 14),
                    decoration: InputDecoration(labelText: "Nom de la catégorie", hintText: "Ex: Téléphones, Accessoires", prefixIcon: Icon(Icons.label_outline_rounded, size: 18, color: ext.mutedForeground), filled: true, fillColor: ext.surfaceMuted, border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: ext.border))),
                    validator: (v) => (v == null || v.isEmpty) ? 'Le nom est obligatoire' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _categoryDescController,
                    maxLines: 3,
                    style: TextStyle(color: ext.foreground, fontSize: 14),
                    decoration: InputDecoration(labelText: "Description", hintText: "Décrivez cette catégorie", prefixIcon: Icon(Icons.description_outlined, size: 18, color: ext.mutedForeground), filled: true, fillColor: ext.surfaceMuted, border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: ext.border))),
                    validator: (v) => (v == null || v.isEmpty) ? 'Veuillez ajouter une description' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () { setCatState(() => isSavingCategory = false); _categoryNameController.clear(); _categoryDescController.clear(); Navigator.pop(ctx); }, child: Text("Annuler", style: TextStyle(color: ext.mutedForeground))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: ext.foreground, foregroundColor: ext.background, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)), elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
              onPressed: isSavingCategory ? null : () async {
                if (_categoryFormKey.currentState!.validate()) {
                  setCatState(() => isSavingCategory = true);
                  final data = {"name": _categoryNameController.text, "description": _categoryDescController.text};
                  final cs = CategoryService();
                  try {
                    if (category != null) {
                      final cat = await cs.update(category.id, data, context);
                      if (mounted) setCatState(() => isSavingCategory = false);
                      if (cat == null) { showErrorMessage("mise à jour a échoué", context); } else { final i = categories.indexOf(category); if (i != -1) setState(() => categories[i] = cat); }
                      showSuccessMessage("catégorie mise à jour", context);
                    } else {
                      await cs.create(data, widget.store.id, context);
                      showSuccessMessage("catégorie ajoutée", context);
                      _fetchAllData();
                    }
                    Navigator.pop(ctx);
                  } catch (e) { showExceptionMessage(context); }
                }
              },
              child: isSavingCategory ? const BouTikaLoader.compact() : Text(category == null ? "Créer" : "Enregistrer", style: TextStyle(color: ext.background, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      }),
    );
  }

  // =========================================================================
  // FORMULAIRE EMPLOYÉ — sobre
  // =========================================================================
  void _showAddEmployeeForm(BuildContext context, DashColors colors, {Employee? employee}) {
    final ext = colors.ext;
    _firstnameController.clear();
    _secondnameController.clear();
    _usernameController.clear();
    _phoneController.clear();
    _passwordController.clear();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (_, setSaveEmpState) {
        return AlertDialog(
          backgroundColor: ext.card,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
          title: Text(employee == null ? "Ajouter un employé" : "Modifier ${employee.username}", style: TextStyle(color: ext.foreground, fontWeight: FontWeight.w600, fontSize: 15)),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPremiumTextField(controller: _firstnameController, label: "Prénom", hint: "Ex: Jean", icon: Icons.person_outline_rounded, colors: colors),
                  const SizedBox(height: 12),
                  _buildPremiumTextField(controller: _secondnameController, label: "Nom", hint: "Ex: Dupont", icon: Icons.person_outline_rounded, colors: colors),
                  const SizedBox(height: 12),
                  _buildPremiumTextField(controller: _usernameController, label: "Nom d'utilisateur", hint: "Ex: jean.d", icon: Icons.alternate_email_rounded, colors: colors),
                  const SizedBox(height: 12),
                  _buildPremiumTextField(controller: _phoneController, label: "Téléphone", hint: "Ex: 6XX XXX XXX", icon: Icons.phone_outlined, colors: colors),
                  const SizedBox(height: 12),
                  _buildPremiumTextField(controller: _passwordController, label: "Mot de passe", hint: "••••••••", icon: Icons.lock_outline_rounded, colors: colors, obscure: true),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () { Navigator.pop(ctx); setSaveEmpState(() => isSavingEmployee = false); }, child: Text("Annuler", style: TextStyle(color: ext.mutedForeground))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: ext.foreground, foregroundColor: ext.background, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)), elevation: 0),
              onPressed: isSavingEmployee ? null : () async {
                setSaveEmpState(() => isSavingEmployee = true);
                if (_formKey.currentState!.validate()) {
                  final employeeMap = {"firstname": _firstnameController.text, "secondName": _secondnameController.text, "username": _usernameController.text, "post": "SALESPERSON", "password": _passwordController.text, "phone": _phoneController.text};
                  try {
                    await EmployeeService().addEmployee(employeeMap, widget.store.id, context);
                    if (mounted) setSaveEmpState(() => isSavingEmployee = false);
                    Navigator.pop(ctx);
                    showSuccessMessage("employé ajouté", context);
                    _fetchAllData();
                  } catch (e) { showExceptionMessage(context); }
                }
              },
              child: isSavingEmployee ? const BouTikaLoader.compact() : Text(employee == null ? "Ajouter" : "Enregistrer", style: TextStyle(color: ext.background, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPremiumTextField({required TextEditingController controller, required String label, String? hint, required IconData icon, required DashColors colors, bool obscure = false}) {
    final ext = colors.ext;
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: ext.foreground, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: ext.mutedForeground),
        filled: true,
        fillColor: ext.surfaceMuted,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: ext.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: ext.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: ext.foreground.withOpacity(0.4), width: 1.2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  // =========================================================================
  // DÉCONNEXION — sobre
  // =========================================================================
  void _handleLogout(BuildContext context, DashColors colors) {
    final ext = colors.ext;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ext.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: Text("Déconnexion", style: TextStyle(color: ext.foreground, fontWeight: FontWeight.w600, fontSize: 16)),
        content: Text("Voulez-vous vraiment quitter BouTiKa ?", style: TextStyle(color: ext.mutedForeground, fontSize: 14, height: 1.4)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Annuler", style: TextStyle(color: ext.mutedForeground))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ext.danger, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)), elevation: 0),
            onPressed: () async {
              await UserService.logout();
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => LoginScreen()), (route) => false);
            },
            child: const Text("Se déconnecter", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // FORMULAIRE DÉPENSE — sobre
  // =========================================================================
  void _showExpenseDialog(BuildContext context, DashColors colors) {
    final ext = colors.ext;
    bool isSavingExpense = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(builder: (_, setPopupState) {
        return AlertDialog(
          backgroundColor: ext.card,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
          title: Row(
            children: [
              Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: ext.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.sm), border: Border.all(color: ext.border)), child: Icon(Icons.remove_circle_outline_rounded, color: ext.mutedForeground, size: 16)),
              const SizedBox(width: 10),
              Flexible(child: Text("Nouvelle dépense", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: ext.foreground, fontWeight: FontWeight.w600, fontSize: 15))),
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
                    style: TextStyle(color: ext.foreground, fontSize: 14),
                    decoration: InputDecoration(labelText: "Montant (F)", hintText: "Ex: 5000", prefixIcon: Icon(Icons.payments_outlined, size: 18, color: ext.mutedForeground), filled: true, fillColor: ext.surfaceMuted, border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: ext.border))),
                    validator: (v) => (v == null || v.isEmpty) ? "Indiquez le montant" : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _expenseDescController,
                    maxLines: 3,
                    style: TextStyle(color: ext.foreground, fontSize: 14),
                    decoration: InputDecoration(labelText: "Description / Motif", hintText: "Ex: Achat de fournitures", prefixIcon: Icon(Icons.description_outlined, size: 18, color: ext.mutedForeground), filled: true, fillColor: ext.surfaceMuted, border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: ext.border))),
                    validator: (v) => (v == null || v.isEmpty) ? "Indiquez le motif" : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () { _expensePriceController.clear(); _expenseDescController.clear(); Navigator.pop(ctx); }, child: Text("Annuler", style: TextStyle(color: ext.mutedForeground))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: ext.foreground, foregroundColor: ext.background, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)), elevation: 0),
              onPressed: isSavingExpense ? null : () async {
                if (_expenseFormKey.currentState!.validate()) {
                  setPopupState(() => isSavingExpense = true);
                  try {
                    await SpendingServcie().saveSpending(Spending(price: double.parse(_expensePriceController.text), description: _expenseDescController.text, storeId: widget.store.id), context);
                    if (mounted) { _expensePriceController.clear(); _expenseDescController.clear(); Navigator.pop(ctx); }
                  } catch (e) { print(e); showErrorMessage("Erreur lors de l'enregistrement", context); } finally { if (mounted) setPopupState(() => isSavingExpense = false); }
                }
              },
              child: isSavingExpense ? const BouTikaLoader.compact() : Text("Enregistrer", style: TextStyle(color: ext.background, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      }),
    );
  }
}

// ===========================================================================
// CATEGORY CARD — premium minimal, hiérarchie lumineuse
// ===========================================================================
class _CategoryCard extends StatefulWidget {
  final Category category;
  final String userType;
  final DashColors colors;
  final VoidCallback onEdit;
  final VoidCallback onManage;

  const _CategoryCard({required this.category, required this.userType, required this.colors, required this.onEdit, required this.onManage});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final ext = widget.colors.ext;
    final category = widget.category;

    return AnimatedContainer(
      duration: AppDurations.normal,
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ext.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: _expanded ? ext.foreground.withOpacity(0.15) : ext.border, width: 1),
        boxShadow: widget.colors.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: AppDurations.normal,
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: _expanded ? ext.surfaceMuted : ext.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: ext.border)),
                    child: Icon(Icons.category_outlined, color: _expanded ? ext.foreground : ext.mutedForeground, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(category.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: ext.foreground, letterSpacing: -0.1)),
                        const SizedBox(height: 2),
                        Text("Gérer le stock et les prix", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: ext.mutedForeground, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: AppDurations.normal,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(color: ext.surfaceMuted, shape: BoxShape.circle, border: Border.all(color: ext.border)),
                      child: Icon(Icons.keyboard_arrow_down_rounded, color: ext.mutedForeground, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: AppDurations.normal,
            sizeCurve: Curves.easeOut,
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 1, color: ext.border),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: ext.surfaceMuted, borderRadius: BorderRadius.circular(6), border: Border.all(color: ext.border)),
                    child: Text("DESCRIPTION", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: ext.mutedForeground, letterSpacing: 0.8)),
                  ),
                  const SizedBox(height: 8),
                  Text(category.description ?? "Aucune description fournie.", style: TextStyle(color: ext.foreground, height: 1.5, fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (widget.userType == "employer")
                        Expanded(child: _CategoryActionButton(icon: Icons.edit_outlined, label: "Modifier", filled: false, colors: widget.colors, onTap: widget.onEdit)),
                      if (widget.userType == "employer") const SizedBox(width: 10),
                      Expanded(flex: 2, child: _CategoryActionButton(icon: Icons.inventory_2_outlined, label: "Gérer les produits", filled: true, colors: widget.colors, onTap: widget.onManage)),
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
// BOUTON D'ACTION CATÉGORIE — sobre
// ===========================================================================
class _CategoryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final DashColors colors;
  final VoidCallback onTap;

  const _CategoryActionButton({required this.icon, required this.label, required this.filled, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ext = colors.ext;
    return Material(
      color: filled ? ext.foreground : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.md), border: filled ? null : Border.all(color: ext.border, width: 1)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: filled ? ext.background : ext.mutedForeground),
              const SizedBox(width: 6),
              Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: filled ? ext.background : ext.foreground))),
            ],
          ),
        ),
      ),
    );
  }
}
