import 'package:flutter/material.dart';
import 'package:mobile_store_app/models/subscription.dart';
import 'package:mobile_store_app/widgets/subscription_page/subscription_contact_button.dart';
import 'package:mobile_store_app/widgets/subscription_page/subscription_features_list.dart';
import 'package:mobile_store_app/widgets/subscription_page/subscription_header.dart';
import 'package:mobile_store_app/widgets/subscription_page/subscription_plan_card.dart';
import 'package:mobile_store_app/utils/app_colors.dart' show DashColors;

class SubscriptionScreenPage extends StatelessWidget {
  final Subscription subscription;
  const SubscriptionScreenPage({super.key, required this.subscription});

  @override
  Widget build(BuildContext context) {
    final colors = DashColors(context);

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
