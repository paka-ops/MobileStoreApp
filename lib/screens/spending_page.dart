import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_store_app/models/spending.dart';
import 'package:mobile_store_app/service/spending_service.dart';

class ExpensesScreen extends StatefulWidget {
  final String storeId;
  const ExpensesScreen({super.key, required this.storeId});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  bool isLoading = false;
  List<Spending> allExpenses = []; // Liste complète chargée depuis l'API
  List<Spending> filteredExpenses = []; // Liste affichée après filtrage

  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    setState(() => isLoading = true);
    try {
      SpendingServcie spendingServcie = SpendingServcie();
      // On récupère toutes les dépenses (tu peux aussi adapter ton service pour filtrer côté serveur si besoin)
      List<dynamic> spendings = await spendingServcie.getAllSpending(widget.storeId, context);

      setState(() {
        allExpenses = spendings.cast<Spending>();
        _applyLocalFilter(); // Appliquer le filtre initial
      });
    } catch (e) {
      debugPrint("Erreur lors de la récupération : $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Logique de filtrage par date
  void _applyLocalFilter() {
    setState(() {
      filteredExpenses = allExpenses.where((expense) {
        if (expense.createdAt == null) return false;

        bool isAfterStart = startDate == null ||
            expense.createdAt!.isAfter(startDate!);

        bool isBeforeEnd = endDate == null ||
            expense.createdAt!.isBefore(endDate!.add(const Duration(days: 1)));

        return isAfterStart && isBeforeEnd;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Historique des Dépenses",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchExpenses,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(), // Ajout de la barre de filtre
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredExpenses.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredExpenses.length,
              itemBuilder: (context, index) {
                return _buildExpenseCard(filteredExpenses[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BARRE DE FILTRE (Design BouTiKa) ---
  Widget _buildFilterBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildDatePickerChip("Du", startDate, (date) {
            setState(() => startDate = date);
            _applyLocalFilter();
          })),
          const SizedBox(width: 12),
          Expanded(child: _buildDatePickerChip("Au", endDate, (date) {
            setState(() => endDate = date);
            _applyLocalFilter();
          })),
          if (startDate != null || endDate != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.redAccent),
              onPressed: () {
                setState(() {
                  startDate = null;
                  endDate = null;
                });
                _applyLocalFilter();
              },
            )
        ],
      ),
    );
  }

  Widget _buildDatePickerChip(String label, DateTime? date, Function(DateTime) onPicked) {
    return InkWell(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2022),
          lastDate: DateTime(2100),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: Colors.orange),
            ),
            child: child!,
          ),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              date == null ? label : DateFormat('dd/MM/yy').format(date),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseCard(Spending spending) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.money_off_rounded, color: Colors.orange, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spending.description ?? "Sans description",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  spending.createdAt != null
                      ? DateFormat('dd MMM yyyy • HH:mm').format(spending.createdAt!)
                      : "Date inconnue",
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            "- ${spending.price?.toStringAsFixed(0)} F",
            style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.redAccent,
                fontSize: 15
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
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Aucune dépense trouvée",
              style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}