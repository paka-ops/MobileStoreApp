import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile_store_app/utils/message.dart';

class SubscriptionScreen extends StatelessWidget {
  final String storeName;
  final String planType; // 'Free', 'Basic', 'Pro'
  final String duration; // '1 mois', '3 mois', '12 mois'
  final DateTime startDate;
  final DateTime expiryDate;

  const SubscriptionScreen({
    super.key,
    required this.storeName,
    required this.planType,
    required this.duration,
    required this.startDate,
    required this.expiryDate,
  });

  @override
  Widget build(BuildContext context) {
    // Calcul des jours restants
    int value = expiryDate.difference(DateTime.now()).inDays;
    final int daysRemaining = value<0?0:value ;
    final double progress = (daysRemaining / 30).clamp(0.0, 1.0); // Exemple sur 30 jours

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Mon Abonnement",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CARTE DE MEMBRE STYLEE
            _buildSubscriptionCard(daysRemaining),

            const SizedBox(height: 30),
            _buildSectionLabel("DÉTAILS DU PLAN"),
            const SizedBox(height: 12),

            // 2. LISTE DES INFOS
            _buildInfoTile(Icons.stars_rounded, "Type de Plan", planType, Colors.orange),
            _buildInfoTile(Icons.timer_rounded, "Durée choisie", duration, Colors.blue),
            _buildInfoTile(Icons.calendar_today_rounded, "Date de début",
                DateFormat('dd MMMM yyyy').format(startDate), Colors.green),
            _buildInfoTile(Icons.event_busy_rounded, "Date d'expiration",
                DateFormat('dd MMMM yyyy').format(expiryDate), Colors.red),

            const SizedBox(height: 40),

            // 3. BOUTON RENOUVELER
            _buildRenewButton(context),

            const SizedBox(height: 20),
             Center(
              child:InkWell(
                onTap: (){
                  String number = '+228 99691176';
                  showDialog(context: context, builder: (context) => SimpleDialog(
                    children: [
                      SimpleDialogOption(
                          child:  ListTile(
                            leading: Icon(Icons.phone),
                            title: Text(number),
                            trailing: IconButton(onPressed:(){ _copyClipBoard(number,context);}, icon: Icon(Icons.copy)),
                          )
                      )
                    ],
                  ));
                },
                child: Text(
                  "Besoin d'aide ? Contactez le support",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              )
            )
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE COMPOSANTS ---

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2),
    );
  }

  Widget _buildSubscriptionCard(int daysRemaining) {
    final bool isExpired = daysRemaining == 0;
    final Color mainColor = isExpired ? const Color(0xFFEF4444) : const Color(0xFF3B82F6);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          children: [
            // Cercles décoratifs en arrière-plan pour le style
            Positioned(
              top: -20,
              right: -20,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ),
            Positioned(
              bottom: -30,
              left: 10,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white.withOpacity(0.05),
              ),
            ),

            // Contenu de la carte
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isExpired
                      ? [const Color(0xFFEF4444), const Color(0xFF991B1B)]
                      : [const Color(0xFF3B82F6), const Color(0xFF1E40AF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        storeName.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                      // Badge de Statut Stylisé
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isExpired ? Colors.black26 : Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: Text(
                          isExpired ? "EXPIRÉ" : "ACTIF",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Text(
                    planType == "Pro" ? "MEMBRE PRO" : "PLAN ${planType.toUpperCase()}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "TEMPS RESTANT",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$daysRemaining Jours",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // Icône décorative
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRenewButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          // Action de renouvellement
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.autorenew_rounded),
            SizedBox(width: 10),
            Text("Renouveler l'abonnement", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
  void _copyClipBoard(String text,BuildContext context){
    Clipboard.setData(ClipboardData(text: text)).then((_){
      showSuccessMessage("numero copié", context);
    } );
  }
}