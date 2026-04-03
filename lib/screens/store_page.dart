import 'package:flutter/material.dart';
import 'package:mobile_store_app/models/category.dart';
import 'package:mobile_store_app/models/order.dart';
import 'package:mobile_store_app/models/product.dart';
import 'package:mobile_store_app/models/subscription.dart';
import 'package:mobile_store_app/screens/category_detail_screen.dart';
import 'package:mobile_store_app/screens/low_stock_product.dart';
import 'package:mobile_store_app/screens/order_story_screen.dart';
import 'package:mobile_store_app/screens/stock_history_screen.dart';
import 'package:mobile_store_app/screens/subscription_screen_page.dart';
import 'package:mobile_store_app/service/category_service.dart';
import 'package:mobile_store_app/service/employee_service.dart';
import 'package:mobile_store_app/service/order_service.dart';
import 'package:mobile_store_app/utils/message.dart';
import '../models/Store.dart';
import '../models/employee.dart';
import '../service/product_service.dart';
import '../service/user_service.dart';
import 'package:dropdown_search/dropdown_search.dart';

import 'login_screen.dart';

// Modèle de données pour une ligne de vente
class OrderLine {
  Product? product;
  double quantity;
  double salingPrice;
  double? maxStock;

  OrderLine({
    this.product,
    this.quantity = 1, // Commencer à 1 pour faciliter la saisie
    this.salingPrice = 0,
    this.maxStock,
  });
}
class AppColors {
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const background = Color(0xFFF5F7FB);
  static const card = Colors.white;
}

class StoreDetailScreen extends StatefulWidget {
  final Store store;
  final String userType;
  final List<Store> otherStores;
  StoreDetailScreen({super.key, required this.store, required this.userType,required this.otherStores});
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

  // Controllers
  final _firstnameController = TextEditingController();
  final _secondnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _categoryNameController = TextEditingController();
  final _categoryDescController = TextEditingController();

  final _categoryFormKey = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();
  List<Store> displayStore = [];
  @override
  void initState() {
    super.initState();
    _fetchAllData();
     displayStore =  List.from(widget.otherStores);
     displayStore.removeWhere((e)=>e.id == widget.store.id);
  }

  Future<void> _fetchAllData() async {
      await getEmployeeByStoreId(widget.store.id);
      await _loadAllProductsForSale();

  }

  Future<void> getEmployeeByStoreId(String storeId) async {
      EmployeeService em = EmployeeService();
      CategoryService categoryService = CategoryService();
      List<Employee> list = await em.getEmployeeOfStore(storeId,context);
      List<Category> cats = await categoryService.getCategoryByStoreId(storeId,context);
      if (mounted) {
        setState(() {
          employees = list;
          categories = cats;
        });
      }

  }

  Future<void> _loadAllProductsForSale() async {
      List<Product> products = await ProductService().getAllProductByStoreId(
          widget.store.id);
      if (mounted) {
        setState(() {
          allStoreProducts = products;
          lowStockProducts = _getLowStockProduct(allStoreProducts);
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.store.name),
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent, // IMPORTANT
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [IconButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>LowStockProductDetailsScreen(products: lowStockProducts, userType: widget.userType)));
            },
            icon: Icon(Icons.warning_amber_rounded,color:lowStockProducts.isEmpty?Colors.grey: Colors.red,))],
      ),
      drawer: _buildStoreDrawer(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStartSaleDialog(context),
        backgroundColor: const Color(0xFF6366F1),
        elevation: 6,
        icon: const Icon(Icons.shopping_cart_checkout, color: Colors.white),
        label: const Text("Vendre", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildEmployeeSection(context),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Inventaire", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            _buildCategoryList(context, categories),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // --- LOGIQUE DE VENTE ---

  void _showStartSaleDialog(BuildContext context) async {
    OrderService orderService = OrderService();
    Order? createdOrder;

    final bool? wantsToCreate = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (stfBuilder,setPopupState){
          return AlertDialog(
            title: const Text("Nouvelle Vente"),
            content: const Text("Voulez-vous créer un nouvel ordre de vente ?"),
            actions: [
              TextButton(onPressed: () { Navigator.pop(dialogContext, false); setPopupState(()=>isCreatingOrder = false);}, child: const Text("Non")),
              ElevatedButton(
                onPressed: isCreatingOrder?null:() async {
                  setPopupState((){
                    isCreatingOrder = true;
                  });
                  createdOrder = await orderService.createOrder(widget.store.id,context);
                  if(mounted) setPopupState(()=>isCreatingOrder = false);
                  Navigator.pop(dialogContext, createdOrder != null);
                },
                child: isCreatingOrder?CircularProgressIndicator():const Text("Oui"),
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
        const SnackBar(content: Text("Erreur lors de la création de l'ordre."), backgroundColor: Colors.red),
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
          double calculateTotal() {
            return saleLines.fold(0, (sum, item) => sum + ((item.product?.stock?.sellingPrice ?? 0) * item.quantity));
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("Choix des produits"),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Form(
                key: formKey,
                // On active la validation seulement quand l'utilisateur interagit
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Ordre de vente", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const Divider(),
                      ...saleLines.asMap().entries.map((entry) {
                        int index = entry.key;
                        OrderLine line = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ... (début du code inchangé)
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
                                      // On valide pour mettre à jour l'affichage de l'erreur
                                      formKey.currentState?.validate();
                                    });
                                  },
                                  validator: (item) {
                                    if (item == null) return 'Requis';

                                    // LOGIQUE D'INDEX : On ne cherche les doublons que dans les lignes PRÉCÉDENTES
                                    // Ainsi, seule la nouvelle ligne (celle du bas) affichera "Déjà ajouté"
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
// ... (reste du code inchangé)

                            ],
                          ),
                        );
                      }).toList(),
                      TextButton.icon(
                        onPressed: () => setPopupState(() => saleLines.add(OrderLine())),
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text("Ajouter un produit a la commande"),
                      ),
                      const Divider(),
                      Text("TOTAL: ${calculateTotal().toStringAsFixed(0)} F",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueAccent)),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(onPressed:isCancelingSale?null: () async {
                try {
                  setPopupState(()=>isCancelingSale = true);
                  await OrderService().deleteOrder(orderId,context);
                  if(mounted)setPopupState(()=>isCancelingSale =false);
                  Navigator.pop(dialogContext);
                  showSuccessMessage("ordre annulée avec success", context);
                } catch (e) {
                  showErrorMessage("Erreur lors de la liaison avec le serveur.", context);
                }
              }, child: const Text("Annuler")),
              ElevatedButton(
                onPressed:() {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(dialogContext);
                    _showFinalConfirmationDialog(context, orderId, saleLines, calculateTotal());
                  }
                },
                child: isCancelingSale?CircularProgressIndicator():const Text("Valider"),
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
      builder: (dialogContext) => StatefulBuilder(builder: (stfContext,setConfirmationStat){
        return AlertDialog(
          title: const Text("Confirmer la Vente"),
          content: Text("Valider la vente de ${total.toStringAsFixed(0)} F ?"),
          actions: [
            TextButton(onPressed: () {
              setConfirmationStat(()=>isValidatingSale = false);
              Navigator.pop(dialogContext);
              }
                , child: const Text("Non")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: isValidatingSale? null:() async {
                // On génère la liste finale à envoyer ici
                List<Map<String, dynamic>> requestData = saleLines.map((line) => {
                  "orderId": orderId,
                  "productId": line.product!.id,
                  "quantity": line.quantity,
                }).toList();
                setConfirmationStat(()=>isValidatingSale = true);
                try{
                  Order? order = await OrderService().makeOrder(orderId, requestData,context);
                  if(mounted)setConfirmationStat(()=>setConfirmationStat(()=>isValidatingSale = false));
                  Navigator.pop(dialogContext);
                  if (order != null) {
                    showSuccessMessage("Vente enregistrée !", context);
                    _loadAllProductsForSale(); // Rafraîchir les stocks
                  } else {
                    showErrorMessage("Erreur lors de la validation.", context);
                  }
                }catch(e){

                  print(e);
                  showExceptionMessage(context);

                }
              },
              child:isValidatingSale? CircularProgressIndicator(): const Text("Oui, Valider", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      }),
    );
  }

  // --- WIDGETS DE LA PAGE ---
  Widget _buildEmployeeSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Équipe de vente",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 15),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (employees.isEmpty)
                  const Text(
                    "Aucun employé",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  )
                else
                  ...employees.map((emp) => _buildClickableAvatar(context, emp)),

                if (widget.userType == "employer")
                  IconButton(
                    onPressed: () => _showAddEmployeeForm(context),
                    icon: const Icon(
                      Icons.add_circle,
                      size: 40,
                      color: Colors.white,
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableAvatar(BuildContext context, Employee emp) {
    return GestureDetector(
      onLongPress: () {
        // On n'affiche les options que si l'utilisateur est un "employer" (admin)
        if (widget.userType == "employer") {
          _showEmployeeOptions(context, emp);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white24,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(height: 5),
            Text(
              emp.username ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmployeeOptions(BuildContext context, Employee emp) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
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
      builder: (context) => StatefulBuilder(builder: (stContext,setDelEmployeeState){
        return AlertDialog(
          title: const Text("Confirmation"),
          content: Text("Voulez-vous vraiment supprimer ${emp.username} ?"),
          actions: [
            TextButton(onPressed:
                (){
                setDelEmployeeState(()=>isDeletingEmployee = false);
                Navigator.pop(context);
              }, child: const Text("Annuler")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed:isDeletingEmployee?null : () async {
                setDelEmployeeState(()=>isDeletingEmployee =true);
                EmployeeService empService = EmployeeService();
                bool deleted = await empService.deleteEmployee(emp,context);
                if(mounted) setDelEmployeeState(()=> isDeletingEmployee = false);
                if(deleted == true){
                  showSuccessMessage("employée ${emp.username} est supprimé de votre boutique", context);
                }
                Navigator.pop(context);
                _fetchAllData();
              },
              child:isDeletingEmployee?CircularProgressIndicator(): const Text("Supprimer", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCategoryList(BuildContext context, List<Category> cats) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: cats.length + (widget.userType == "employer" ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < cats.length) {
          return _buildExpandableCategory(context, cats[index]);
        } else {
          return IconButton(
            onPressed: () => _showAddCategoryForm(context, null),
            icon: const Icon(Icons.add_circle_outline, size: 35, color: Colors.orange),
          );
        }
      },
    );
  }

  Widget _buildExpandableCategory(BuildContext context, Category category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          // Utilisation du même style d'icône que le Drawer (Container coloré 10%)
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.category_rounded, color: Colors.orange, size: 24),
          ),
          title: Text(
            category.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            "Gérer le stock et les prix",
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "DESCRIPTION",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.description ?? "Aucune description fournie pour cette catégorie.",
                    style: const TextStyle(color: Colors.black54, height: 1.4),
                  ),
                  const Divider(height: 32),
                  Row(
                    children: [
                      // Bouton Modifier (Outline)
                      if (widget.userType == "employer")
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showAddCategoryForm(context, category),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text("Modifier"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: const BorderSide(color: Colors.orange),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      if (widget.userType == "employer") const SizedBox(width: 12),
                      // Bouton Gérer les produits (Principal)
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EmployerCategoryDetailScreen(
                                category: category,
                                userType: widget.userType,
                              ),
                            ),
                          ).then((_) => _fetchAllData()),
                          icon: const Icon(Icons.inventory_2_outlined, size: 18),
                          label: const Text("Gérer les produits"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- FORMULAIRES AJOUT ---
  // (Note: Implémentations simplifiées pour la clarté, à adapter selon vos besoins de validation)

  void _showAddCategoryForm(BuildContext context,Category? category) {
    if(category != null){
      _categoryNameController.text = category.name;
      _categoryDescController.text = category.description ?? "";
    } else {
      _categoryNameController.clear();
      _categoryDescController.clear();
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(builder: (stContext,setCatState){
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.category, color: Colors.orange),
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
                setCatState(()=>isSavingCategory = false);
                _categoryNameController.clear();
                _categoryDescController.clear();
                Navigator.pop(context);
              },
              child: const Text("Annuler", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed:isSavingCategory?null: () async{
                if (_categoryFormKey.currentState!.validate()) {
                  setCatState(()=>isSavingCategory = true);
                  Map<String, dynamic> categoryData = {
                    "name": _categoryNameController.text,
                    "description": _categoryDescController.text,
                  };
                  CategoryService cs = CategoryService();
                  try {
                    if(category != null){
                      Category? cat = await cs.update(category.id, categoryData,context);
                      if(mounted) setCatState(()=>isSavingCategory = false);
                      if(cat == null){
                        showErrorMessage("mise a jour a echouer", context);
                      }else{
                        int index = categories.indexOf(category);
                        if(index != -1) {
                          setState(() {
                            categories[index] = cat;
                          });

                        }
                      }
                      showSuccessMessage("category mise a jour", context);
                    } else {
                      await cs.create(categoryData,widget.store.id,context);
                      showSuccessMessage("category ajouté", context);
                      _fetchAllData();
                    }
                    Navigator.pop(context); // Recharger toutes les données

                  } catch (e) {
                    showExceptionMessage(context);
                  }
                }
              },
              child: isSavingCategory?CircularProgressIndicator(): Text(category == null ? "Créer" : "Enregistrer", style: const TextStyle(color: Colors.white)),
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
      builder: (context) => StatefulBuilder(builder: (stContext,setSaveEmpState){
        return AlertDialog(
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
            TextButton(onPressed: () { Navigator.pop(context); setSaveEmpState(()=>isSavingEmployee);}, child: const Text("Annuler")),
            ElevatedButton(
              onPressed: isSavingEmployee?null:  () async {
                setSaveEmpState(()=>isSavingEmployee = true);
                if (_formKey.currentState!.validate()) {
                  Map<String,dynamic> employeeMap = {};
                  employeeMap.putIfAbsent("firstname", ()=>_firstnameController.text);
                  employeeMap.putIfAbsent("secondName", ()=>_secondnameController.text);
                  employeeMap.putIfAbsent("username", ()=>_usernameController.text);
                  employeeMap.putIfAbsent("post", ()=>"SALESPERSON");
                  employeeMap.putIfAbsent("password", ()=>_passwordController.text);
                  employeeMap.putIfAbsent("phone", ()=>_phoneController.text);
                  try {
                    await EmployeeService().addEmployee(
                        employeeMap, widget.store.id,context);
                    if(mounted) setSaveEmpState(()=>isSavingEmployee = false);
                    Navigator.pop(context);
                    showSuccessMessage("employée ajouté", context);
                    _fetchAllData(); // Rafraîchir la liste
                  }catch(e){
                    showExceptionMessage(context);
                  }
                }
              },
              child:isSavingEmployee? CircularProgressIndicator(): Text(employee == null ? "Ajouter" : "Enregistrer"),
            ),
          ],
        );
      }),
    );
  }




  // --- LE DRAWER ---
  Widget _buildStoreDrawer(BuildContext context) {
    return Drawer(
      elevation: 10,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [

          // 🔷 HEADER MODERNE
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Icon(Icons.person, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${UserService.username}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          (widget.userType == 'employee') ? "EMPLOYÉ" : "PROPRIÉTAIRE",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 🔽 CONTENU
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 15),
              children: [

                _sectionTitle("BOUTIQUE ACTUELLE"),

                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  leading: _iconBox(Icons.storefront, Colors.orange),
                  title: Text(
                    widget.store.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text("Session active"),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Divider(),
                ),

                _sectionTitle("NAVIGATION"),

                _drawerItem(
                  icon: Icons.history_rounded,
                  color: Colors.blueGrey,
                  title: "Historique des Ventes",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderStoryScreen(storeId: widget.store.id, userType: widget.userType, categories: categories)));
                  },
                ),
                _drawerItem(icon: Icons.history_edu,
                    color: Colors.blueGrey,
                    title: "Historique des restockage",
                    onTap:(){
                      List<String>  productIds = [];
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>RestockHistoryScreen(products: allStoreProducts)));
                    }
                ),
                ?widget.store.subscription == null? null:_drawerItem(
                    icon: Icons.subscriptions,
                    color: Colors.grey,
                    onTap: (){
                      Subscription subscription =widget.store.subscription!;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubscriptionScreen(
                            storeName: widget.store.name,
                            planType: subscription.plan!, // À remplacer par tes données réelles
                            duration: subscription.duration!,
                            startDate: subscription.startDate!,
                            expiryDate: subscription.expirationDate!,
                          ),
                        ),
                      );
                    },
                  title: "mon abonnement"
                ),

                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 20),
                    leading: _iconBox(Icons.swap_horiz_rounded, Colors.purple),
                    title: const Text("Changer de boutique"),
                    children: displayStore.map((store) {
                      return ListTile(
                        contentPadding: const EdgeInsets.only(left: 70),
                        leading: const Icon(Icons.location_on_outlined, size: 18),
                        title: Text(store.name),
                        onTap: () {
                            displayStore.add(store);


                          Navigator.push(context, MaterialPageRoute(builder:(context)=> StoreDetailScreen(store: store, userType: widget.userType, otherStores: widget.otherStores)));},
                      );
                    }).toList()
                  ),
                ),
              ],
            ),
          ),

          // 🔻 FOOTER
          const Divider(),

          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: const Text(
              "Déconnexion",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {
              _handleLogout(context);
            },
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: _iconBox(icon, color),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
  // Dans ta page d'accueil (WelcomeScreen ou autre)
  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Déconnexion"),
        content: Text("Voulez-vous vraiment quitter BouTiKa ?"),
        actions: [
          TextButton(
            onPressed: () =>Navigator.pop(context), // Ferme l'alerte
            child: Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              // Appel de la logique de déconnexion
              await UserService.logout();

              // Navigation vers l'écran de Login en vidant toute la pile de navigation
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false, // Supprime toutes les pages précédentes
              );
            },
            child: Text("Se déconnecter", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  List<Product> _getLowStockProduct(List<Product> products){
    List<Product> lowStock = [];
    products.forEach((e){
      double restOfStock = e.stock!.baseStock - e.stock!.totalSell;
      if(restOfStock < 10) {
        lowStock.add(e);
      }
    });
    return lowStock;


  }

}
