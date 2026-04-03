import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_store_app/models/category.dart';
import 'package:mobile_store_app/models/enums.dart';
import 'package:mobile_store_app/models/order.dart';
import 'package:mobile_store_app/models/product.dart';
import 'package:mobile_store_app/service/user_service.dart';
import 'package:mobile_store_app/utils/message.dart';
import '../service/order_service.dart';
import 'category_report_screen.dart';
import 'general_report_screen.dart';

class OrderStoryScreen extends StatefulWidget {
  final String storeId;
  final String userType;
  final List<Category> categories;
  const OrderStoryScreen({super.key, required this.storeId,required this.userType,required this.categories});

  @override
  State<OrderStoryScreen> createState() => _OrderStoryScreenState();
}

class _OrderStoryScreenState extends State<OrderStoryScreen> {
  List<Order> allOrders = [];
  List<Order> filteredOrders = [];
  bool isLoading = false; // Pour l'indicateur de chargement

  DateTime? startDate;
  DateTime? endDate;
  OrderStatus? selectedStatus;

  @override
  void initState() {
    super.initState();
    _getOrders(storeId: widget.storeId);
  }

  Future<void> _setContentsToOrders(List<Order> orders) async {
    if (orders.isEmpty) return;

    List<String> ordersIds = orders.map((o) => o.orderId).toList();


     List<Map<String, dynamic>> contents = await OrderService().getcontentsByOrdersIds(ordersIds,context);
      Map<String, List<Map<String, dynamic>>> contentOrderIdMap = {};
      for (var content in contents) {
        contentOrderIdMap.putIfAbsent(content['orderId'], () => []).add(content);
      }

      for (var order in orders) {
        List<Map<String, dynamic>> products = contentOrderIdMap[order.orderId] ?? [];
        // On vide pour éviter les doublons en cas de refresh
        order.products.clear();
        for (var productData in products) {
          order.products.putIfAbsent(
              Product.fromJson(productData['productDto']),
                  () => productData['quantity']
          );
        }
      }


      /*OrderService orderService = OrderService();
      for (var o in orders) {
         Map<Product,dynamic> orderContent = await orderService.getOrderContent(o.orderId);
         o.products = orderContent;
      }*/

  }

  void _getOrders({required String storeId, DateTime? startDate, DateTime? endDate}) async {
    setState(() => isLoading = true);

    try {
      // Appel API pour filtrer par date
      List<Order> orders = await OrderService().getAllOrderBetweenTwoDate(
        widget.storeId,
        startDate ?? DateTime.now().add(Duration(days: -1)),
        endDate?? DateTime.now().add(Duration(days: 1)),
          context
      );

      if (orders.isNotEmpty) {
        await _setContentsToOrders(orders);
      }
      allOrders = orders;



      // Appliquer le filtre de statut localement sur les résultats
      _runFilterLogic();
    } catch (e) {
      debugPrint("Erreur lors de la récupération des commandes: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _runFilterLogic() {
    setState(() {
      if (selectedStatus == null) {
        filteredOrders = allOrders;
      } else {
        filteredOrders = allOrders.where((order) => order.status == selectedStatus).toList();
      }
    });
  }

  void _applyFilters() {
    // On relance l'appel API car les dates impactent la requête serveur
     _getOrders(
        storeId: widget.storeId,
        startDate: startDate,
        endDate: endDate
    );
  }

  double _calculateTotal(Order order) {
    double total = 0;
    if (order.products.isNotEmpty) {
      order.products.forEach((product, quantity) {
        total += (product.stock?.sellingPrice ?? 0) * (quantity ?? 0);
      });
    }
    return total;
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.VALIDATED: return Colors.green;
      case OrderStatus.CREATED: return Colors.orange;
      case OrderStatus.DELETION_PENDING: return Colors.red;
      case OrderStatus.UPDATED: return Colors.blue;
      case OrderStatus.SCRAPPED: return Colors.grey;
      default: return Colors.grey;
    }
  }

  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.VALIDATED: return "Validé";
      case OrderStatus.CREATED: return "Créé";
      case OrderStatus.DELETION_PENDING: return "Attente d'annulation";
      case OrderStatus.UPDATED: return "Modifié";
      case OrderStatus.SCRAPPED: return "Annulé";
      default: return "Inconnu";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Historique des Ventes",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _getOrders(
                  storeId: widget.storeId,
                  endDate: endDate,
                  startDate: startDate
              )
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredOrders.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) => _buildOrderCard(filteredOrders[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "Aucune commande trouvée",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _filterChipDate("Début", startDate, true)),
              const SizedBox(width: 8),
              Expanded(child: _filterChipDate("Fin", endDate, false)),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<OrderStatus>(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              prefixIcon: const Icon(Icons.filter_list, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            hint: const Text("Tous les statuts"),
            value: selectedStatus,
            items: OrderStatus.values
                .map((s) => DropdownMenuItem(value: s, child: Text(_getStatusLabel(s))))
                .toList(),
            onChanged: (val) {
              setState(() => selectedStatus = val);
              _runFilterLogic(); // On filtre localement par statut
            },
          ),
          const Divider(),

          _buildDashboardShortcuts()
        ],
      ),
    );
  }

  Widget _filterChipDate(String label, DateTime? date, bool isStart) {
    return InkWell(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2022),
          lastDate: DateTime(2100),
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, size: 18, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Text(
              date == null ? label : DateFormat('dd/MM/yy').format(date),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final Color statusColor = _getStatusColor(order.status);
    final double totalAmount = _calculateTotal(order);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.shopping_bag_outlined, color: statusColor, size: 24),
          ),
          title: Text("N°${order.orderId.substring(0, 8)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat('dd MMM yyyy • HH:mm').format(order.createdAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(_getStatusLabel(order.status),
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("${totalAmount.toStringAsFixed(0)} F",
                  style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.blueAccent, fontSize: 16)),
              const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey),
            ],
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
                  const Text("DÉTAILS PRODUITS",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  if (order.products.isNotEmpty)
                    ...order.products.entries.map((entry) {
                      final product = entry.key;
                      final quantity = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${product.name ?? 'Inconnu'} x${quantity}",
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "${((quantity ?? 0) * (product.stock?.sellingPrice ?? 0)).toStringAsFixed(0)} F",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text("Vendeur: ${order.maker?['username'] ?? 'N/A'}",
                          style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildActionButtons(order),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _navigateToGeneralReport() {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GeneralReportScreen(storeId: widget.storeId,userType: widget.userType,orders: allOrders,))
    );
  }

  void _navigateToCategoryReport() {
    List<Order> valideOrder = allOrders.where((order) =>order.products.isNotEmpty).toList();
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CategoryReportScreen(storeId: widget.storeId,userType: widget.userType,categories: widget.categories,orders:valideOrder))
    );
  }

  Widget _buildActionButtons(Order order) {
    String? username = UserService.username;
    return Row(
      children: (username == order.maker['username'] || ( widget.userType=='employer' && order.status == OrderStatus.DELETION_PENDING ))? [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text("Modifier"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              side: const BorderSide(color: Colors.orange),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _confirmDelete(order),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text("Supprimer"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ]:[],
    );
  }

  void _confirmDelete(Order order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirmer suppression"),
        content: Text("Voulez-vous vraiment supprimer l'ordre ${order.orderId} ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: ()async {
              if(widget.userType == "employee"){
                Order? value = await OrderService().changeOrderStatus("DELETION_PENDING", order.orderId,context);
                if(value != null){
                 int index =  allOrders.indexOf(order);
                 if(index != -1){
                   allOrders[index] = value;
                   setState(() {
                     allOrders;
                   });
                   showSuccessMessage("Demande d' annulation envoyée", context);
                 }
                }else{
                  _showMessage("operation refusé vous n' êtes pas le vendeur de ces produits", Colors.red);
                }
              }else{
                await OrderService().deleteOrder(order.orderId,context);
                showSuccessMessage("ordre annulée ", context);
                setState(() {

                  allOrders.removeWhere((o) => o.orderId == order.orderId);
                  _runFilterLogic();
                });
              }
              Navigator.pop(ctx);
            },
            child: Text(
              UserService.userType == 'employee'? "Demander l' annulation":"Suprimer",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildDashboardShortcuts() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0), // Réduit l'espace avec le divider
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 2.8, // 🔥 AUGMENTÉ : Plus le chiffre est grand, plus la carte est courte
        children: [
          _buildCard(
            title: "Rapport général",
            icon: Icons.assessment_outlined,
            color: const Color(0xFF2E7D32),
            bgColor: const Color(0xFFE8F5E9),
            onTap: _navigateToGeneralReport,
          ),
          _buildCard(
            title: "Par catégorie",
            icon: Icons.pie_chart_outline,
            color: const Color(0xFF6A1B9A),
            bgColor: const Color(0xFFF3E5F5),
            onTap: _navigateToCategoryReport,
          ),
        ],
      ),
    );
  }
  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12), // Padding latéral uniquement
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row( // 🔥 Changé de Column à Row pour compacter
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Flexible( // Empêche l'erreur d'overflow si le texte est long
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showMessage(String message,Color color){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message),backgroundColor:color));
  }

}