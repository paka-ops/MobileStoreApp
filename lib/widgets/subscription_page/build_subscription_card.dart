import 'package:flutter/material.dart';
import 'package:mobile_store_app/utils/app_colors.dart'
    show DashColors, PremiumRadii;
//
// Carte membre premium — dégradé émeraude feutré (jamais criard),
// badge de statut, jours restants Bold. Mêmes paramètres d'entrée.
//
class BuildSubscriptionCard extends StatelessWidget {
  final int daysRemaining;

  final String storeName;

  final String planType;

  BuildSubscriptionCard(
      {required this.daysRemaining,
      required this.storeName,
      required this.planType});

  @override
  Widget build(BuildContext context) {
    final colors = DashColors(context);
    final bool isExpired = daysRemaining == 0;
    final Color mainColor =
        isExpired ? colors.danger : colors.primary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.28),
            blurRadius: 22,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PremiumRadii.lg),
        child: Stack(
          children: [
            // Cercles décoratifs en arrière-plan pour le style
            Positioned(
              top: -24,
              right: -24,
              child: CircleAvatar(
                radius: 64,
                backgroundColor: Colors.white.withOpacity(0.10),
              ),
            ),
            Positioned(
              bottom: -34,
              left: 8,
              child: CircleAvatar(
                radius: 44,
                backgroundColor: Colors.white.withOpacity(0.06),
              ),
            ),

            // Contenu de la carte
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isExpired
                      ? [colors.danger, const Color(0xFF8E2F2F)]
                      : [colors.primary, colors.primaryDeep],
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
                      Expanded(
                        child: Text(
                          storeName.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Badge de Statut Stylisé
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isExpired
                              ? Colors.black26
                              : Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.white30, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isExpired ? "EXPIRÉ" : "ACTIF",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    planType == "Pro"
                        ? "MEMBRE PRO"
                        : "PLAN ${planType.toUpperCase()}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 32),
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
                              color: Colors.white.withOpacity(0.65),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$daysRemaining Jours",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      // Icône décorative
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
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
}
