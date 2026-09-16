import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile_store_app/utils/app_colors.dart'
    show appDarkMode, DashColors;
import 'package:mobile_store_app/utils/message.dart';
import 'package:mobile_store_app/widgets/subscription_page/build_info_tiltle.dart';
import 'package:mobile_store_app/widgets/subscription_page/build_renew_button.dart';
import 'package:mobile_store_app/widgets/subscription_page/build_selection_label.dart';
import 'package:mobile_store_app/widgets/subscription_page/build_subscription_card.dart';
import 'package:mobile_store_app/widgets/premium_kit.dart';

// =====================================================================
// MON ABONNEMENT — visuel « BouTika Premium »
// ---------------------------------------------------------------------
// LOGIQUE INCHANGÉE : calcul des jours restants, progression, copie du
// support — tout est conservé. La présentation passe au thème
// (clair/sombre), carte membre émeraude et bouton 60 px.
// =====================================================================
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
    final int daysRemaining = value < 0 ? 0 : value;
    final double progress =
        (daysRemaining / 30).clamp(0.0, 1.0); // Exemple sur 30 jours

    return ValueListenableBuilder<bool>(
      valueListenable: appDarkMode,
      builder: (context, _, __) {
        final colors = DashColors(context);

        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            title: const Text("Mon Abonnement"),
          ),
          body: SafeArea(
              child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. CARTE DE MEMBRE STYLEE
                BuildSubscriptionCard(
                    daysRemaining: daysRemaining,
                    storeName: storeName,
                    planType: planType),

                const SizedBox(height: 24),
                BuildSelctionLabel(label: "DÉTAILS DU PLAN"),
                const SizedBox(height: 12),

                // 2. LISTE DES INFOS
                BuildInfoTitle(
                    icon: Icons.stars_rounded,
                    title: "Type de Plan",
                    value: planType,
                    color: colors.accent),
                BuildInfoTitle(
                    icon: Icons.timer_rounded,
                    title: "Durée choisie",
                    value: duration,
                    color: colors.info),
                BuildInfoTitle(
                    icon: Icons.calendar_today_rounded,
                    title: "Date de début",
                    value: DateFormat('dd MMMM yyyy').format(startDate),
                    color: colors.success),
                BuildInfoTitle(
                    icon: Icons.event_busy_rounded,
                    title: "Date d'expiration",
                    value: DateFormat('dd MMMM yyyy').format(expiryDate),
                    color: colors.danger),

                const SizedBox(height: 12),
                // Jauge de progression (variable `progress` d'origine).
                PremiumCard(
                  padding: const EdgeInsets.all(16),
                  radius: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Validité restante",
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "$daysRemaining j",
                            style: TextStyle(
                              color: colors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: colors.background,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              colors.primary),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 3. BOUTON RENOUVELER
                BuildRenewButton(),

                const SizedBox(height: 20),
                Center(
                    child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    String number = '+228 99691176';
                    final dialogColors = DashColors(context);
                    showDialog(
                        context: context,
                        builder: (context) => SimpleDialog(
                              backgroundColor: dialogColors.card,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                    color: dialogColors.border, width: 1),
                              ),
                              children: [
                                SimpleDialogOption(
                                    child: ListTile(
                                  leading: PremiumIconTile(
                                    icon: Icons.phone_rounded,
                                    color: dialogColors.primary,
                                    softColor: dialogColors.primarySoft,
                                    size: 42,
                                    iconSize: 20,
                                  ),
                                  title: Text(
                                    number,
                                    style: TextStyle(
                                      color: dialogColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  trailing: IconButton(
                                      onPressed: () {
                                        _copyClipBoard(number, context);
                                      },
                                      icon: Icon(
                                        Icons.copy_rounded,
                                        color: dialogColors.textSecondary,
                                        size: 20,
                                      )),
                                ))
                              ],
                            ));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: Text(
                      "Besoin d'aide ? Contactez le support",
                      style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ))
              ],
            ),
          )),
        );
      },
    );
  }

  void _copyClipBoard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      showSuccessMessage("numero copié", context);
    });
  }
}
