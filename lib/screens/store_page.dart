import 'package:flutter/material.dart';
import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';
import 'package:mobile_store_app/core/widgets/cards/app_card.dart';
import 'package:mobile_store_app/widgets/boutika_loader.dart';
import 'package:mobile_store_app/core/widgets/common/primitives.dart';
import 'package:mobile_store_app/core/widgets/dialogs/app_dialog.dart';
import 'package:mobile_store_app/core/widgets/inputs/app_text_field.dart';
import 'package:mobile_store_app/models/category.dart';
import 'package:mobile_store_app/models/order.dart';
import 'package:mobile_store_app/models/product.dart';
import 'package:mobile_store_app/screens/category_detail_screen.dart';
import 'package:mobile_store_app/screens/low_stock_product.dart';
import 'package:mobile_store_app/screens/order_story_screen.dart';
import 'package:mobile_store_app/screens/spending_page.dart';
import 'package:mobile_store_app/screens/stock_history_screen.dart';
import 'package:mobile_store_app/screens/subscription_screen_page.dart';
import 'package:mobile_store_app/screens/withdrawal_page.dart';
import 'package:mobile_store_app/service/category_service.dart';
import 'package:mobile_store_app/service/employee_service.dart';
import 'package:mobile_store_app/service/order_service.dart';
import 'package:mobile_store_app/service/spending_service.dart';
import 'package:mobile_store_app/core/constants/app_spacing.dart';
import 'package:mobile_store_app/core/theme/app_dimensions.dart';
import 'package:mobile_store_app/core/theme/app_text_styles.dart';
import 'package:mobile_store_app/utils/app_colors.dart'
    show appDarkMode, AppColors, DashColors;
import 'package:mobile_store_app/utils/message.dart';
import 'package:mobile_store_app/widgets/design_system.dart';
import '../models/Store.dart';
import '../models/employee.dart';
import '../models/spending.dart';
import '../service/product_service.dart';
import '../service/user_service.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../widgets/store_page/functions/get_low_stock_product.dart';
import 'login_screen.dart';

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
  static const accent  = AppColors.accentPink;
  static const danger  = AppColors.badgeRed;
  static const success = AppColors.accentGreen;
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

  /// Vue de l'inventaire : 0 = grille de catégories, 1 = gestion.
  int _inventoryTab = 0;

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
          // Le dégradé lavande vient d'AppBackground (main.dart).
          return const Scaffold(
            body: Center(
              child: BouTikaLoader(
                message: "Préparation de votre boutique…",
              ),
            ),
          );
        }

        return Scaffold(
          body: SafeArea(
            bottom: false,
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
    final String? location = widget.store.location;

    return AppGreetingHeader(
      greeting: "Bonjour, ${UserService.username} 👋",
      title: widget.store.name,
      subtitle: (location != null && location.trim().isNotEmpty)
          ? location.trim()
          : (widget.userType == "employer"
              ? "Propriétaire"
              : "Boutique active"),
      subtitleIcon: Icons.location_on_outlined,
      // Sélecteur de boutique (logique inchangée)
      onTapTitle: () => _showStoreSwitcherSheet(context, colors),
      onTapSubtitle: () => _showStoreSwitcherSheet(context, colors),
      showSubtitleChevron: true,
      // Alertes stock (logique inchangée)
      notificationCount: lowStockProducts.length,
      onTapNotifications: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LowStockProductDetailsScreen(
            products: lowStockProducts,
            userType: widget.userType,
          ),
        ),
      ),
      avatarIcon: Icons.storefront_rounded,
      onTapAvatar: () => _showStoreSwitcherSheet(context, colors),
    );
  }

  // =========================================================================
  // STORE SWITCHER SHEET (logique de navigation inchangée)
  // =========================================================================
  void _showStoreSwitcherSheet(BuildContext context, DashColors colors) {
    AppSheet.show(
      context,
      title: "Mes boutiques",
      builder: (ctx) {
        return Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
            children: [
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(Spacing.sm),
                  decoration: BoxDecoration(
                    color: colors.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(Icons.check_circle_rounded,
                      color: colors.primary, size: 20),
                ),
                title: Text(
                  widget.store.name,
                  style: AppTextStyles.cardTitle
                      .copyWith(color: colors.textPrimary),
                ),
                subtitle: Text(
                  "Boutique active",
                  style: AppTextStyles.bodySecondary,
                ),
              ),
              if (displayStore.isNotEmpty)
                Divider(
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                    color: colors.border),
              ...displayStore.map((newStore) => ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(Spacing.sm),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(Icons.storefront_outlined,
                      color: colors.textSecondary, size: 20),
                ),
                title: Text(newStore.name,
                    style: AppTextStyles.productTitle
                        .copyWith(color: colors.textPrimary)),
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
        );
      },
    );
  }

  // =========================================================================
  // BOTTOM NAV
  // =========================================================================
  Widget _buildBottomNav(BuildContext context, DashColors colors) {
    final items = [
      const FloatingNavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home_rounded,
          label: "Accueil"),
      const FloatingNavItem(
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long_rounded,
          label: "Ventes"),
      const FloatingNavItem(
          icon: Icons.inventory_2_outlined,
          activeIcon: Icons.inventory_2_rounded,
          label: "Stock"),
      const FloatingNavItem(
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings_rounded,
          label: "Plus"),
    ];

    return FloatingBottomNavBar(
      items: items,
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      badges: [0, 0, lowStockProducts.length, 0],
    );
  }

  // =========================================================================
  // SECTION CARD générique
  // =========================================================================
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
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: colors.softShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              Spacing.md,
              Spacing.md,
              0,
            ),
            child: SectionHeader(
              title: title,
              subtitle: subtitle,
              trailing: icon != null
                  ? Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colors.primarySoft,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(icon, color: colors.primary, size: 21),
                    )
                  : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Spacing.md),
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
      backgroundColor: colors.card,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            _buildEmployeeSection(context, colors),
            _buildKpiRow(context, colors),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SectionHeader(
                  title: "Inventaire",
                  subtitle: "${categories.length} catégorie(s)",
                ),
              ),
            ),
            CustomTabBar(
              tabs: const ["Catégories", "Gérer"],
              currentIndex: _inventoryTab,
              onTap: (i) => setState(() => _inventoryTab = i),
            ),
            const SizedBox(height: 16),
            if (_inventoryTab == 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CategoryGrid(
                  itemCount: categories.length,
                  itemBuilder: (i) => CategoryCard(
                    label: categories[i].name,
                    icon: Icons.category_rounded,
                    index: i,
                    onTap: () => _openCategoryProducts(context, categories[i]),
                  ),
                ),
              )
            else
              _buildCategoryList(context, categories, colors),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // KPI — cartes à dégradé du design system (données réelles, aucun calcul)
  // =========================================================================
  Widget _buildKpiRow(BuildContext context, DashColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: SizedBox(
        height: 140, // Donnez une hauteur fixe
        child: Row(
          children: [
            Expanded(
              child: GradientInfoCard(
                icon: Icons.inventory_2_outlined,
                label: "Produits",
                value: "${allStoreProducts.length}",
                caption: "en catalogue",
                tint: colors.pastelAt(1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GradientInfoCard(
                icon: Icons.warning_amber_rounded,
                label: "Alertes",
                value: "${lowStockProducts.length}",
                caption: "sous le seuil",
                tint: colors.pastelAt(3),
                iconColor: colors.starYellow,
                showChevron: true,
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
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // OUVERTURE DES PRODUITS D'UNE CATÉGORIE (même destination qu'avant)
  // =========================================================================
  void _openCategoryProducts(BuildContext context, Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmployerCategoryDetailScreen(
          category: category,
          userType: widget.userType,
        ),
      ),
    ).then((_) => _fetchAllData());
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
        SectionHeader(
          title: "Gestion du stock",
          subtitle: "Suivez votre inventaire en temps réel",
        ),
        const SizedBox(height: 20),
        ActionTile(
          icon: Icons.history_edu_rounded,
          color: colors.primary,
          softColor: colors.primarySoft,
          title: "Historique de restockage",
          subtitle: "Consultez les réapprovisionnements passés",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  RestockHistoryScreen(products: allStoreProducts),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ActionTile(
          icon: Icons.warning_amber_rounded,
          color: colors.accent,
          softColor: colors.accentSoft,
          title: "Produits en alerte",
          subtitle: lowStockProducts.isEmpty
              ? "Aucune alerte pour le moment"
              : "${lowStockProducts.length} produit(s) sous le seuil",
          badge: lowStockProducts.isNotEmpty
              ? lowStockProducts.length
              : null,
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

  // =========================================================================
  // ONGLET 3 — PLUS
  // =========================================================================
  Widget _buildMoreTab(BuildContext context, DashColors colors) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      children: [
        // Carte profil
        AppCard(
          padding: AppDimensions.paddingAllM,
          radius: AppRadius.lg,
          shadow: colors.softShadow,
          borderColor: Colors.transparent,
          child: Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: colors.fill,
                child:
                    Icon(Icons.person, color: colors.textSecondary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${UserService.username}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.sectionTitle
                          .copyWith(color: colors.textPrimary),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: colors.fill,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                      child: Text(
                        widget.userType == 'employee'
                            ? "EMPLOYÉ"
                            : "PROPRIÉTAIRE",
                        style: AppTextStyles.chip.copyWith(
                          color: colors.textSecondary,
                          fontSize: 10.5,
                          letterSpacing: 0.4,
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
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: 6),
          radius: AppRadius.lg,
          shadow: colors.softShadow,
          borderColor: Colors.transparent,
          child: Column(
            children: [
              // Bascule de thème (même logique qu'avant, simplement
              // déplacée du header vers « Plus » pour alléger l'en-tête).
              ServiceListTile(
                icon: Icons.dark_mode_outlined,
                title: "Thème sombre",
                subtitle: appDarkMode.value
                    ? "Activé"
                    : "Désactivé",
                pastel: colors.fill,
                iconColor: colors.textSecondary,
                showChevron: false,
                trailing: Switch(
                  value: appDarkMode.value,
                  onChanged: (value) => appDarkMode.value = value,
                ),
                onTap: () => appDarkMode.value = !appDarkMode.value,
              ),
              Divider(height: 1, color: colors.hairline),
              ServiceListTile(
                icon: Icons.account_balance_wallet_outlined,
                title: "Mes Dépenses",
                subtitle: "Suivre les dépenses de la boutique",
                pastel: colors.accentSoft,
                iconColor: colors.accent,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ExpensesScreen(storeId: widget.store.id),
                  ),
                ),
              ),
              Divider(height: 1, color: colors.hairline),
              ServiceListTile(
                icon: Icons.savings_outlined,
                title: "Mes Retraits",
                subtitle: "Historique des retraits d'argent",
                pastel: colors.primarySoft,
                iconColor: colors.primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        WithdrawalScreen(storeId: widget.store.id),
                  ),
                ),
              ),
              if (widget.store.subscription != null) ...[
                Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: colors.border),
                ServiceListTile(
                  icon: Icons.subscriptions_rounded,
                  title: "Mon abonnement",
                  subtitle: "Gérer la formule de la boutique",
                  pastel: colors.primarySoft,
                  iconColor: colors.primary,
                  onTap: () {
                    final sub = widget.store.subscription!;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SubscriptionScreenPage(
                          subscription: sub,
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
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: 6),
          radius: AppRadius.lg,
          shadow: colors.softShadow,
          borderColor: Colors.transparent,
          child: ServiceListTile(
            icon: Icons.logout_rounded,
            title: "Déconnexion",
            subtitle: "Quitter la session en cours",
            pastel: colors.dangerSoft,
            iconColor: colors.danger,
            showChevron: false,
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
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        RoundActionButton(
          icon: Icons.money_off_rounded,
          tooltip: "Dépense",
          size: 50,
          iconColor: colors.accent,
          onTap: () => _showExpenseDialog(context, colors),
        ),
        const SizedBox(height: 12),
        // Bouton d'ajout d'un retrait — page d'accueil uniquement.
        RoundActionButton(
          icon: Icons.savings_outlined,
          tooltip: "Retrait",
          size: 50,
          iconColor: colors.primary,
          onTap: () => showWithdrawalFormDialog(
            context,
            storeId: widget.store.id,
          ),
        ),
        const SizedBox(height: 12),
        ChatFab.labeled(
          label: "Vendre",
          icon: Icons.shopping_cart_checkout_rounded,
          margin: EdgeInsets.zero,
          onTap: () => _showStartSaleDialog(context, colors),
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
                        color: colors.textSecondary
                            .withValues(alpha: 0.5),
                        size: 32),
                    const SizedBox(height: 8),
                    Text(
                      "Aucun employé pour le moment",
                      style: AppTextStyles.bodySecondary
                          .copyWith(fontWeight: FontWeight.w500),
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
                          // Bouton circulaire d'action : encre + icône claire.
                          color: colors.ink,
                          shape: BoxShape.circle,
                          boxShadow: colors.softShadow,
                        ),
                        child: Icon(Icons.add_rounded,
                            color: colors.onInk, size: 21),
                      ),
                      const SizedBox(height: 5),
                      Text("Ajouter",
                          style: AppTextStyles.chip
                              .copyWith(color: colors.textSecondary)),
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
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.pastelAt(emp.username?.length ?? 0),
                ),
                child: Icon(Icons.person,
                    color: colors.textSecondary, size: 20),
              ),
              const SizedBox(height: 5),
              Text(
                emp.username ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.chip
                    .copyWith(color: colors.textPrimary),
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
              height: 44,
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
              ),
              decoration: BoxDecoration(
                // Bouton d'action « + » : pilule encre, icône et texte clairs.
                color: colors.ink,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                boxShadow: colors.softShadow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: colors.onInk, size: 20),
                  const SizedBox(width: Spacing.sm),
                  Text("Ajouter une catégorie",
                      style: AppTextStyles.cardTitle.copyWith(
                          fontSize: 13.5, color: colors.onInk)),
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
    return _StoreCategoryCard(
      category: category,
      userType: widget.userType,
      colors: colors,
      onEdit: () => _showAddCategoryForm(context, category, colors),
      onManage: () => _openCategoryProducts(context, category),
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
      barrierColor: colors.barrier,
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(AppRadius.xxl))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 14),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              leading: Container(
                padding: const EdgeInsets.all(Spacing.sm),
                decoration: BoxDecoration(
                  color: colors.dangerSoft,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(Icons.delete_outline_rounded,
                    color: colors.danger, size: 20),
              ),
              title: Text("Supprimer l'employé",
                  style: AppTextStyles.cardTitle
                      .copyWith(color: colors.danger)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDeleteEmployee(context, emp, colors);
              },
            ),
            const SizedBox(height: 12),
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
                borderRadius: BorderRadius.circular(AppRadius.xl),
                side: BorderSide(color: colors.border),
              ),
              contentPadding:
              const EdgeInsets.fromLTRB(24, 24, 24, 0),
              actionsPadding:
              const EdgeInsets.fromLTRB(24, 20, 24, 24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: AppDimensions.paddingAllM,
                    decoration: BoxDecoration(
                      color: colors.dangerSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person_remove_rounded,
                        color: colors.danger, size: 30),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "Confirmation",
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 17,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Voulez-vous vraiment supprimer ${emp.username} ?",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySecondary.copyWith(color: colors.textSecondary, fontSize: 13.5, height: 1.5),
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
                        onPressed: () {
                          setDelState(
                              () => isDeletingEmployee = false);
                          Navigator.pop(ctx);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton.danger(
                        label: "Supprimer",
                        height: 48,
                        isLoading: isDeletingEmployee,
                        onPressed: isDeletingEmployee
                            ? null
                            : () async {
                          setDelState(
                              () => isDeletingEmployee = true);
                          final deleted = await EmployeeService()
                              .deleteEmployee(emp, context);
                          if (mounted)
                            setDelState(() =>
                            isDeletingEmployee = false);
                          if (deleted) {
                            showSuccessMessage(
                                "employée ${emp.username} supprimé",
                                context);
                          }
                          Navigator.pop(ctx);
                          _fetchAllData();
                        },
                      ),
                    ),
                  ],
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

    final bool? wantsToCreate = await AppDialog.show<bool>(
      context,
      barrierDismissible: false,
      icon: Icons.point_of_sale_rounded,
      iconColor: colors.primary,
      iconSoftColor: colors.primarySoft,
      title: "Nouvelle Vente",
      message: "Voulez-vous créer un nouvel ordre de vente ?",
      actions: [
        AppButton.secondary(
          label: "Non",
          height: 48,
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        StatefulBuilder(
          builder: (_, setPopupState) => AppButton.primary(
            label: "Oui, créer",
            height: 48,
            isLoading: isCreatingOrder,
            onPressed: isCreatingOrder
                ? null
                : () async {
              setPopupState(() => isCreatingOrder = true);
              createdOrder = await orderService
                  .createOrder(widget.store.id, context);
              if (mounted) {
                setPopupState(() => isCreatingOrder = false);
              }
              Navigator.pop(context, createdOrder != null);
            },
          ),
        ),
      ],
    );

    if (wantsToCreate == true && createdOrder != null) {
      _showSaleForm(context, createdOrder!.orderId!, colors);
    } else if (wantsToCreate == true) {
      showErrorMessage("Erreur lors de la création de l'ordre.", context);
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

            return Dialog(
              backgroundColor: colors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                side: BorderSide(color: colors.border),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 550,
                  maxHeight: MediaQuery.sizeOf(context).height * 0.8,
                ),
                child: Padding(
                  padding: AppDimensions.paddingAllL,
                  child: Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: colors.primarySoft,
                                  borderRadius:
                                  BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Icon(
                                    Icons.shopping_cart_checkout_rounded,
                                    color: colors.primary,
                                    size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Choix des produits",
                                  style: AppTextStyles.heading.copyWith(
                                    fontSize: 17,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                              Text("Ordre n°${orderId.substring(0, 8)}",
                                  style: AppTextStyles.caption.copyWith(
                                      color: colors.textSecondary)),
                            ],
                          ),
                          const SizedBox(height: 18),
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
                                      DropDownDecoratorProps(
                                        dropdownSearchDecoration:
                                        InputDecoration(
                                          labelText: "Produit",
                                          helperText:
                                          index == 0
                                              ? null
                                              : "Ligne ${index + 1}",
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
                              style: AppTextStyles.button
                                  .copyWith(color: colors.primary),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 13),
                            decoration: BoxDecoration(
                              color: colors.primarySoft,
                              borderRadius:
                              BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "TOTAL",
                                  style: AppTextStyles.overline.copyWith(
                                    letterSpacing: 1.1,
                                    color: colors.textSecondary,
                                  ),
                                ),
                                Text(
                                  "${calculateTotal().toStringAsFixed(0)} F",
                                  style: AppTextStyles.price.copyWith(
                                    fontSize: 17,
                                    color: colors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: AppButton.secondary(
                                  label: "Annuler",
                                  height: 48,
                                  onPressed: isCancelingSale
                                      ? null
                                      : () async {
                                    try {
                                      setPopupState(() =>
                                      isCancelingSale = true);
                                      await OrderService()
                                          .deleteOrder(
                                          orderId, context);
                                      if (mounted) {
                                        setPopupState(() =>
                                        isCancelingSale =
                                        false);
                                      }
                                      Navigator.pop(dialogContext);
                                      showSuccessMessage(
                                          "ordre annulée avec succès",
                                          context);
                                    } catch (e) {
                                      showErrorMessage(
                                          "Erreur lors de la liaison avec le serveur.",
                                          context);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: AppButton.primary(
                                  label: "Valider",
                                  height: 48,
                                  onPressed: () {
                                    if (formKey.currentState!
                                        .validate()) {
                                      Navigator.pop(dialogContext);
                                      _showFinalConfirmationDialog(
                                          context,
                                          orderId,
                                          saleLines,
                                          calculateTotal(),
                                          colors);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
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
                borderRadius: BorderRadius.circular(AppRadius.xl),
                side: BorderSide(color: colors.border),
              ),
              contentPadding:
              const EdgeInsets.fromLTRB(24, 24, 24, 0),
              actionsPadding:
              const EdgeInsets.fromLTRB(24, 20, 24, 24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: AppDimensions.paddingAllM,
                    decoration: BoxDecoration(
                      color: colors.successSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_rounded,
                        color: colors.success, size: 32),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "Confirmer la Vente",
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 17,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Valider la vente de ${total.toStringAsFixed(0)} F ?",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySecondary.copyWith(color: colors.textSecondary, fontSize: 13.5, height: 1.5),
                  ),
                ],
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: AppButton.secondary(
                        label: "Non",
                        height: 48,
                        onPressed: () {
                          setConfirmationStat(
                              () => isValidatingSale = false);
                          Navigator.pop(dialogContext);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: AppButton.primary(
                        label: "Oui, Valider",
                        height: 48,
                        background: colors.success,
                        foreground: Colors.white,
                        isLoading: isValidatingSale,
                        onPressed: isValidatingSale
                            ? null
                            : () async {
                          final requestData = saleLines
                              .map((line) => {
                            "orderId": orderId,
                            "productId":
                            line.product!.id,
                            "quantity": line.quantity,
                          })
                              .toList();
                          setConfirmationStat(
                                  () => isValidatingSale = true);
                          try {
                            final order = await OrderService()
                                .makeOrder(
                                orderId, requestData, context);
                            if (mounted) {
                              setConfirmationStat(() =>
                              isValidatingSale = false);
                            }
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
                      ),
                    ),
                  ],
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
                borderRadius: BorderRadius.circular(AppRadius.xl),
                side: BorderSide(color: colors.border),
              ),
              titlePadding:   const EdgeInsets.fromLTRB(24, 24, 24, 0),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              actionsPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.primarySoft,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(Icons.category_rounded,
                        color: colors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      category == null
                          ? "Nouvelle Catégorie"
                          : "Modifier Catégorie",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.heading.copyWith(
                        color: colors.textPrimary,
                        fontSize: 17.5,
                      ),
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
                      AppTextField(
                        controller: _categoryNameController,
                        label: "Nom de la catégorie",
                        icon: Icons.label_rounded,
                        hint: "Ex: Boissons",
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Le nom est obligatoire'
                            : null,
                      ),
                      const SizedBox(height: 15),
                      AppTextField(
                        controller: _categoryDescController,
                        maxLines: 2,
                        label: "Description",
                        icon: Icons.description_outlined,
                        hint: "Décrivez cette catégorie",
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Veuillez ajouter une description'
                            : null,
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
                        onPressed: () {
                          setCatState(
                              () => isSavingCategory = false);
                          _categoryNameController.clear();
                          _categoryDescController.clear();
                          Navigator.pop(ctx);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: AppButton.primary(
                        label: category == null ? "Créer" : "Enregistrer",
                        height: 48,
                        isLoading: isSavingCategory,
                        onPressed: isSavingCategory
                            ? null
                            : () async {
                          if (_categoryFormKey.currentState!
                              .validate()) {
                            setCatState(
                                () => isSavingCategory = true);
                            final data = {
                              "name":
                              _categoryNameController.text,
                              "description":
                              _categoryDescController.text,
                            };
                            final cs = CategoryService();
                            try {
                              if (category != null) {
                                final cat = await cs.update(
                                    category.id, data, context);
                                if (mounted) {
                                  setCatState(() =>
                                  isSavingCategory = false);
                                }
                                if (cat == null) {
                                  showErrorMessage(
                                      "mise à jour a échoué",
                                      context);
                                } else {
                                  final i =
                                  categories.indexOf(category);
                                  if (i != -1) {
                                    setState(() =>
                                    categories[i] = cat);
                                  }
                                }
                                showSuccessMessage(
                                    "catégorie mise à jour",
                                    context);
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
                      ),
                    ),
                  ],
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
                borderRadius: BorderRadius.circular(AppRadius.xl),
                side: BorderSide(color: colors.border),
              ),
              titlePadding:   const EdgeInsets.fromLTRB(24, 24, 24, 0),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              actionsPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.primarySoft,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(Icons.person_add_alt_rounded,
                        color: colors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      employee == null
                          ? "Ajouter un employé"
                          : "Modifier ${employee.username}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.heading.copyWith(
                        color: colors.textPrimary,
                        fontSize: 17.5,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppTextField(
                        controller: _firstnameController,
                        label: "Prénom",
                        icon: Icons.person_outline,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 13),
                      AppTextField(
                        controller: _secondnameController,
                        label: "Nom",
                        icon: Icons.person_outline,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 13),
                      AppTextField(
                        controller: _usernameController,
                        label: "Nom d'utilisateur",
                        icon: Icons.alternate_email_rounded,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 13),
                      AppTextField(
                        controller: _phoneController,
                        label: "Téléphone",
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 13),
                      AppTextField(
                        controller: _passwordController,
                        label: "Mot de passe",
                        icon: Icons.lock_outline,
                        obscure: true,
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
                        onPressed: () {
                          Navigator.pop(ctx);
                          setSaveEmpState(
                              () => isSavingEmployee = false);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: AppButton.primary(
                        label:
                        employee == null ? "Ajouter" : "Enregistrer",
                        height: 48,
                        isLoading: isSavingEmployee,
                        onPressed: isSavingEmployee
                            ? null
                            : () async {
                          setSaveEmpState(
                              () => isSavingEmployee = true);
                          if (_formKey.currentState!.validate()) {
                            final employeeMap = {
                              "firstname":
                              _firstnameController.text,
                              "secondName":
                              _secondnameController.text,
                              "username":
                              _usernameController.text,
                              "post": "SALESPERSON",
                              "password":
                              _passwordController.text,
                              "phone": _phoneController.text,
                            };
                            try {
                              await EmployeeService().addEmployee(
                                  employeeMap,
                                  widget.store.id,
                                  context);
                              if (mounted) {
                                setSaveEmpState(() =>
                                isSavingEmployee = false);
                              }
                              Navigator.pop(ctx);
                              showSuccessMessage(
                                  "employé ajouté", context);
                              _fetchAllData();
                            } catch (e) {
                              showExceptionMessage(context);
                            }
                          }
                        },
                      ),
                    ),
                  ],
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
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: colors.border),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: AppDimensions.paddingAllM,
              decoration: BoxDecoration(
                color: colors.dangerSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.logout_rounded,
                  color: colors.danger, size: 30),
            ),
            const SizedBox(height: 18),
            Text(
              "Déconnexion",
              style: AppTextStyles.heading.copyWith(
                fontSize: 17,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Voulez-vous vraiment quitter BouTiKa ?",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary.copyWith(color: colors.textSecondary, fontSize: 13.5,
              ),
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
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton.danger(
                  label: "Se déconnecter",
                  height: 48,
                  onPressed: () async {
                    await UserService.logout();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                          (route) => false,
                    );
                  },
                ),
              ),
            ],
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
                borderRadius: BorderRadius.circular(AppRadius.xl),
                side: BorderSide(color: colors.border),
              ),
              titlePadding:   const EdgeInsets.fromLTRB(24, 24, 24, 0),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              actionsPadding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.accentSoft,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(Icons.remove_circle_outline,
                        color: colors.accent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      "Nouvelle Dépense",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.heading.copyWith(
                        color: colors.textPrimary,
                        fontSize: 17.5,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _expenseFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppTextField(
                        controller: _expensePriceController,
                        keyboardType: TextInputType.number,
                        label: "Montant (F)",
                        icon: Icons.payments_outlined,
                        hint: "Ex: 2500",
                        validator: (v) => (v == null || v.isEmpty)
                            ? "Indiquez le montant"
                            : null,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _expenseDescController,
                        maxLines: 2,
                        label: "Description / Motif",
                        icon: Icons.description_outlined,
                        hint: "Ex: Transport marchandises",
                        validator: (v) => (v == null || v.isEmpty)
                            ? "Indiquez le motif"
                            : null,
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
                        onPressed: () {
                          _expensePriceController.clear();
                          _expenseDescController.clear();
                          Navigator.pop(ctx);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: AppButton.primary(
                        label: "Enregistrer",
                        height: 48,
                        background: colors.accent,
                        foreground: Colors.white,
                        isLoading: isSavingExpense,
                        onPressed: isSavingExpense
                            ? null
                            : () async {
                          if (_expenseFormKey.currentState!
                              .validate()) {
                            setPopupState(
                                () => isSavingExpense = true);
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
                              if (mounted) {
                                setPopupState(() =>
                                isSavingExpense = false);
                              }
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
    );
  }
}

// ===========================================================================
// HELPERS PASTEL — présentation uniquement (aucun impact métier)
// ===========================================================================
/// Pastel déterministe par catégorie (même couleur à chaque affichage).
Color _pastelFor(String name, DashColors colors) {
  int sum = 0;
  for (final int unit in name.codeUnits) {
    sum += unit;
  }
  return colors.pastelAt(sum);
}

/// Teinte d'icône contrastée dérivée du pastel.
Color _pastelIcon(Color pastel) {
  final HSLColor hsl = HSLColor.fromColor(pastel);
  return hsl
      .withLightness((hsl.lightness - 0.30).clamp(0.0, 1.0))
      .withSaturation((hsl.saturation + 0.12).clamp(0.0, 1.0))
      .toColor();
}

// ===========================================================================
// CATEGORY CARD
// ===========================================================================
class _StoreCategoryCard extends StatefulWidget {
  final Category category;
  final String userType;
  final DashColors colors;
  final VoidCallback onEdit;
  final VoidCallback onManage;

  const _StoreCategoryCard({
    required this.category,
    required this.userType,
    required this.colors,
    required this.onEdit,
    required this.onManage,
  });

  @override
  State<_StoreCategoryCard> createState() => _StoreCategoryCardState();
}

class _StoreCategoryCardState extends State<_StoreCategoryCard> {
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
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: _expanded ? colors.floatingShadow : colors.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: AppSizes.categoryIcon,
                    height: AppSizes.categoryIcon,
                    decoration: BoxDecoration(
                      color: _pastelFor(category.name, colors),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.category_rounded,
                        color: _pastelIcon(_pastelFor(category.name, colors)),
                        size: 22),
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
                          style: AppTextStyles.productTitle.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text("Gérer le stock et les prix",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySecondary
                                .copyWith(fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: colors.fill,
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
                  Container(height: 1, color: colors.hairline),
                  const SizedBox(height: 14),
                  OverlineLabel(text: "Description"),
                  const SizedBox(height: 8),
                  Text(
                    category.description ??
                        "Aucune description fournie.",
                    style: AppTextStyles.bodySecondary.copyWith(
                        color: colors.textPrimary,
                        height: 1.45),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (widget.userType == "employer")
                        Expanded(
                          child: _StoreCategoryActionButton(
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
                        child: _StoreCategoryActionButton(
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
class _StoreCategoryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final DashColors colors;
  final VoidCallback onTap;

  const _StoreCategoryActionButton({
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
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              vertical: 11, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: filled
                ? null
                : Border.all(color: colors.border, width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: filled ? colors.onPrimary : colors.textPrimary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.button.copyWith(
                    fontSize: 13,
                    color: filled
                        ? colors.onPrimary
                        : colors.textPrimary,
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
