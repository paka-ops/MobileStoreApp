import 'package:flutter/material.dart';

import 'package:mobile_store_app/features/subscription/widgets/subscription_contact_button.dart';
import 'package:mobile_store_app/features/subscription/widgets/subscription_features_list.dart';
import 'package:mobile_store_app/features/subscription/widgets/subscription_header.dart';
import 'package:mobile_store_app/features/subscription/widgets/subscription_plan_card.dart';
import 'package:mobile_store_app/shared/models/subscription.dart';

/// ============================================================================
/// SUBSCRIPTION SCREEN PAGE — détail de l'abonnement de la boutique.
///
/// Structure identique à l'écran d'origine :
///   Scaffold → SafeArea → SingleChildScrollView (padding 20·16·20·28)
///   → [en-tête, carte du plan, inclusions, CTA support]
///
/// Écran 100 % présentation : l'abonnement est fourni par la boutique, l'état
/// (expiré / jours restants) est dérivé dans la carte du plan.
/// ============================================================================
class SubscriptionScreenPage extends StatelessWidget {
  final Subscription subscription;

  const SubscriptionScreenPage({super.key, required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SubscriptionHeader(),
              const SizedBox(height: 24),
              SubscriptionPlanCard(subscription: subscription),
              const SizedBox(height: 24),
              const SubscriptionFeaturesList(),
              const SizedBox(height: 28),
              const SubscriptionContactButton(),
            ],
          ),
        ),
      ),
    );
  }
}
