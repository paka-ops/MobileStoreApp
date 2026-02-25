
import 'package:flutter/material.dart';
import 'package:mobile_store_app/models/category.dart';
import 'package:mobile_store_app/models/product.dart';
import 'package:mobile_store_app/screens/category_detail_screen.dart';
import 'package:mobile_store_app/screens/employer_category_detail_screen.dart';
import 'package:mobile_store_app/service/category_service.dart';
import 'package:mobile_store_app/service/employee_service.dart';
import '../models/Store.dart';
import '../models/employee.dart';
import '../service/product_service.dart';

// Modèle pour gérer les lignes de vente dynamiques
class OrderLine {
  String? productId;
  double quantity;
  double price;

  OrderLine({this.productId, this.quantity = 1, this.price = 0});
}

class StoreDetailScreen extends StatefulWidget {
  final Store store;
  List<Employee> employees = [];
  List<Category> categories = [];
  StoreDetailScreen({required this.store});

  @override
  State createState() => _StoreDetailScreen();
}

class _StoreDetailScreen extends State<StoreDetailScreen> {
  // --- CONTROLLERS POUR LE FORMULAIRE AJOUT EMPLOYÉ ---
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _secondnameController = TextEditingController();
  final TextEditingController _posteController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // --- CONTROLLERS POUR LE FORMULAIRE AJOUT CATÉGORIE ---
  final TextEditingController _categoryNameController = TextEditingController();
  final TextEditingController _categoryDescController = TextEditingController();
  final _categoryFormKey = GlobalKey<FormState>();

  // CLÉ GLOBALE POUR LA VALIDATION DU FORMULAIRE
  final _formKey = GlobalKey<FormState>();

  void getEmployeeByStoreId(String storeId) async {
    EmployeeService em = EmployeeService();
    CategoryService categoryService = CategoryService();
    ProductService productService = ProductService();
    print("voci l' id $storeId");
    List<Employee> list = await em.getEmployeeOfStore(storeId);
    List<Category> categories = await categoryService.getCategoryByStoreId(storeId);
    print("voici la liste affecter $list");
    setState(() {
      widget.employees = list;
      widget.categories = categories;
    });
  }

  @override
  void initState() {
    super.initState();
    getEmployeeByStoreId(widget.store.id);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.store.name),
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      drawer: _buildStoreDrawer(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSaleForm(context),
        backgroundColor: Colors.blueAccent,
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
            _buildCategoryList(context,widget.categories),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Équipe de vente", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 15),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (widget.employees.isEmpty)
                  const Text("Aucun employé trouvé", style: TextStyle(color: Colors.white, fontSize: 12))
                else
                  for (var emp in widget.employees)
                    _buildClickableAvatar(context, emp.username ?? '', "Vendeur", Icons.person),

                // BOUTON ADD POUR AJOUTER PERSONNEL
                IconButton(
                  onPressed: () => _showAddEmployeeForm(context),
                  icon: const Icon(Icons.add_circle, size: 40),
                  color: Colors.white,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableAvatar(BuildContext context, String name, String role, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (ctx) => Container(
              padding: const EdgeInsets.all(20),
              height: 200,
              child: Column(
                children: [
                  CircleAvatar(radius: 30, child: Icon(icon, size: 30)),
                  const SizedBox(height: 10),
                  Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(role, style: const TextStyle(color: Colors.grey)),
                  const Spacer(),
                  ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text("Contacter")),
                ],
              ),
            ),
          );
        },
        child: Column(
          children: [
            CircleAvatar(radius: 25, backgroundColor: Colors.white24, child: Icon(icon, color: Colors.white)),
            const SizedBox(height: 5),
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context,List<Category> categories) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        if(categories.isEmpty)
          Text("empty")
        else
          for(Category category in categories)
            _buildExpandableCategory(context, category),
        IconButton(
              onPressed: () => _showAddCategoryForm(context,null),
              icon: const Icon(Icons.add_circle_outline, size: 35, color: Colors.orange),

        )
      ],
    );
  }

  Widget _buildExpandableCategory(BuildContext context, Category category) {
    return Padding(
      // Empêche le widget d'occuper toute la largeur de l'écran
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Theme(
          // Enlève les bordures par défaut de l'ExpansionTile
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.orangeAccent,
              child: Icon(Icons.category_outlined, color: Colors.white, size: 20),
            ),
            title: Text(
              category.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            // Actions : Modification et Suppression
            trailing: Wrap(
              spacing: 0,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 22),
                  onPressed: () {
                    _showAddCategoryForm(context,category);
                    print("Modifier ${category.name}");
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                  onPressed: () async {
                    bool delete = await CategoryService().delete(category.id);
                    if(delete){
                      setState(() {
                        widget.categories.removeWhere((c) => c.id == category.id);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Catégorie supprimée !")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Erreur lors de la suppression")),
                      );
                    }
                    print("Supprimer ${category.name}");
                  },
                ),
                const Icon(Icons.expand_more), // L'icône standard d'expansion
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    // Affichage de la description
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Description : ",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                        Expanded(
                          child: Text(
                            category.description ?? "Aucune description",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Affichage du nombre total de produits
                    Row(
                      children: [
                        const Text("Nombre total de produits : ",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            // Vérifie si getTotalProduct est une méthode ou un champ
                            "",
                            style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Bouton optionnel pour voir les détails
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () async{
                          ProductService productService = ProductService();
                          List<Product> products = await productService.getAllProductByCategoryId(category.id);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EmployerCategoryDetailScreen(category: category),
                            ),
                          );
                          // Navigation vers le détail
                        },
                        child: const Text("Voir tous les produits"),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.blueAccent),
            accountName: Text(widget.store.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: Text(widget.store.location ?? "Lomé, Togo"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.store, color: Colors.blueAccent, size: 40),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.people_alt_outlined, color: Colors.blue),
            title: const Text("Gestion du Personnel"),
            onTap: () => _showNavigationMessage(context, "Page Personnel"),
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined, color: Colors.orange),
            title: const Text("Catégories & Rayons"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics_outlined, color: Colors.green),
            title: const Text("Rapports & Stats"),
            onTap: () => _showNavigationMessage(context, "Page Rapports"),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text("Paramètres"),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showSaleForm(BuildContext context) {
    List<OrderLine> saleLines = [OrderLine()];
    final List<Map<String, dynamic>> allProducts = [
      {"id": "uuid-1", "name": "iPhone 15", "price": 750000.0},
      {"id": "uuid-2", "name": "Samsung S23", "price": 450000.0},
      {"id": "uuid-3", "name": "Chargeur", "price": 15000.0},
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setPopupState) {
          double calculateTotal() {
            return saleLines.fold(0, (sum, item) => sum + (item.price * item.quantity));
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("Nouvelle Vente"),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Magasin: ${widget.store.name}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const Divider(),
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
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(labelText: "Produit", isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                                isExpanded: true,
                                items: allProducts.map((p) {
                                  return DropdownMenuItem<String>(
                                    value: p['id'],
                                    child: Text(p['name'], overflow: TextOverflow.ellipsis),
                                    onTap: () => line.price = p['price'],
                                  );
                                }).toList(),
                                onChanged: (val) => setPopupState(() => line.productId = val),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                initialValue: "1",
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(labelText: "Qté", isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                                onChanged: (val) {
                                  setPopupState(() {
                                    line.quantity = double.tryParse(val) ?? 0;
                                  });
                                },
                              ),
                            ),
                            if (saleLines.length > 1) IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), onPressed: () => setPopupState(() => saleLines.removeAt(index))),
                          ],
                        ),
                      );
                    }).toList(),
                    TextButton.icon(
                      onPressed: () => setPopupState(() => saleLines.add(OrderLine())),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text("Ajouter une ligne"),
                    ),
                    const Divider(),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("TOTAL :", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("${calculateTotal().toStringAsFixed(0)} F", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 18)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                onPressed: () {
                  Map<String, double> finalProducts = {};
                  for (var l in saleLines) {
                    if (l.productId != null) finalProducts[l.productId!] = l.quantity;
                  }
                  print("StoreId: ${widget.store.id} | Produits: $finalProducts");
                  Navigator.pop(context);
                },
                child: const Text("Valider", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.category, color: Colors.orange),
            SizedBox(width: 10),
            Text("Nouvelle Catégorie"),
          ],
        ),
        content: Form(
          key: _categoryFormKey, // Utilisation de la clé spécifique
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // CHAMP NOM DE LA CATÉGORIE
              TextFormField(
                controller: _categoryNameController,
                decoration: const InputDecoration(
                  labelText: "Nom de la catégorie",
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le nom est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              // CHAMP DESCRIPTION
              TextFormField(
                controller: _categoryDescController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Description",
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez ajouter une description';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _categoryNameController.clear();
              _categoryDescController.clear();
              Navigator.pop(context);
            },
            child: const Text("Annuler", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async{
              if (_categoryFormKey.currentState!.validate()) {
                // Logique de création de l'objet
                Map<String, dynamic> categoryData = {
                  "name": _categoryNameController.text,
                  "description": _categoryDescController.text,
                  "storeId": widget.store.id, // Liaison avec le magasin actuel
                };
                CategoryService cs = CategoryService();
                // Ici, j'appelle votre service (assurez-vous que addCategory existe)
                try {
                  if(category != null){
                    // Logique de modification
                    Category? updatedCat = await cs.update(category.id, categoryData);
                    setState(() {
                      if(updatedCat != null) {
                        int index = widget.categories.indexWhere((c) => c.id == category.id);
                        if(index != -1) {
                          widget.categories[index] = updatedCat;
                        }
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Catégorie mise à jour !")),
                    );
                    Navigator.pop(context);
                    return;
                  }
                  Category? newCat = await cs.create(categoryData,widget.store.id);
                  setState(() {
                    if(newCat != null) {
                      widget.categories.add(newCat);
                    }
                  });
                  Navigator.pop(context);
                  _categoryNameController.clear();
                  _categoryDescController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Catégorie ajoutée !")),
                  );
                } catch (e) {
                  print("Erreur lors de l'ajout: $e");
                }
              }
            },
            child: const Text("Créer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  // --- POPUP FORMULAIRE AJOUT PERSONNEL AVEC VALIDATION ---
  void _showAddEmployeeForm(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Force à utiliser les boutons pour fermer
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.person_add, color: Colors.blueAccent),
            SizedBox(width: 10),
            Text("Nouveau Personnel"),
          ],
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // CHAMP NOM
                TextFormField(
                  controller: _firstnameController,
                  decoration: const InputDecoration(
                    labelText: "Nom",
                    prefixIcon: Icon(Icons.badge),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                // CHAMP PRÉNOM
                TextFormField(
                  controller: _secondnameController,
                  decoration: const InputDecoration(
                    labelText: "Prénom",
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un prénom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                // CHAMP POSTE
                TextFormField(
                  controller: _posteController,
                  decoration: const InputDecoration(
                    labelText: "Poste",
                    prefixIcon: Icon(Icons.work),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez préciser le poste';
                    }
                    return null;
                  },
                ),
                TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: "Nom d' utilisateur",
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez entrer un nom d' utilisateur";
                      }
                      return null;}
                ),
                TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                        labelText: "Téléphone",
                        prefixIcon: Icon(Icons.phone)
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez entrer un numéro de téléphone";
                      }
                      return null;
                    }
                ),
                TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                        labelText: "Mot de passe",
                        prefixIcon: Icon(Icons.lock)
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Veuillez entrer un mot de passe";
                      }
                      return null;
                    }
                )
              ],
            ),
          ),
        ),
        actions: [
          // BOUTON RETOUR / ANNULER
          TextButton(
            onPressed: () {
              _firstnameController.clear();
              _secondnameController.clear();
              _posteController.clear();
              _usernameController.clear();
              _phoneController.clear();
              _passwordController.clear();
              Navigator.pop(context);
            },
            child: const Text("Annuler", style: TextStyle(color: Colors.red)),
          ),
          // BOUTON VALIDER
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                // LOGIQUE D'ENVOI ICI
                Map<String,dynamic> requestBody = {
                  "firstname": _firstnameController.text,
                  "lastname": _secondnameController.text,
                  "poste": _posteController.text,
                  "username": _usernameController.text,
                  "phone": _phoneController.text,
                  "password": _passwordController.text,
                };
                EmployeeService em = EmployeeService();
                Employee employee = await em.addEmployee(requestBody, widget.store.id);
                setState(() {
                  widget.employees.add(employee);
                });
                Navigator.pop(context);
                _firstnameController.clear();
                _secondnameController.clear();
                _posteController.clear();
                _usernameController.clear();
                _phoneController.clear();
                _passwordController.clear();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Personnel enregistré avec succès")),
                );
              }
            },
            child: const Text("Enregistrer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showNavigationMessage(BuildContext context, String pageName) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ouverture de $pageName")));
  }
}