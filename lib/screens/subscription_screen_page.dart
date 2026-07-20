import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile_store_app/utils/message.dart';
import 'package:mobile_store_app/widgets/subscription_page/build_info_tiltle.dart';
import 'package:mobile_store_app/widgets/subscription_page/build_renew_button.dart';
import 'package:mobile_store_app/widgets/subscription_page/build_selection_label.dart';
import 'package:mobile_store_app/widgets/subscription_page/build_subscription_card.dart';

class SubscriptionScreen extends StatelessWidget {
  final String storeName;
  final String planType;
  final String duration;
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
      body: SafeArea(
          child:SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. CARTE DE MEMBRE STYLEE
                BuildSubscriptionCard(daysRemaining: daysRemaining, storeName: storeName, planType: planType),

                const SizedBox(height: 30),
                BuildSelctionLabel(label: "DÉTAILS DU PLAN"),
                const SizedBox(height: 12),

                // 2. LISTE DES INFOS
                BuildInfoTitle(icon:Icons.stars_rounded,title:  "Type de Plan",value:  planType,color: Colors.orange),
                BuildInfoTitle(icon:  Icons.timer_rounded,title:  "Durée choisie",value:  duration,color:  Colors.blue),
                BuildInfoTitle(icon:  Icons.calendar_today_rounded,title:  "Date de début",value: DateFormat('dd MMMM yyyy').format(startDate),color:  Colors.green),
                BuildInfoTitle(icon:  Icons.event_busy_rounded,title:  "Date d'expiration",
                  value:   DateFormat('dd MMMM yyyy').format(expiryDate),color:  Colors.red),

                const SizedBox(height: 40),

                // 3. BOUTON RENOUVELER
                BuildRenewButton(),

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
          ) ),
    );
  }

  void _copyClipBoard(String text,BuildContext context){
    Clipboard.setData(ClipboardData(text: text)).then((_){
      showSuccessMessage("numero copié", context);
    } );
  }
}