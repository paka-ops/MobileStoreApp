// Test de fumée (smoke test) — BouTiKa
//
// Vérifie que l'application se construit avec le design system premium
// (thème light + dark via buildAppTheme) et affiche l'écran d'accueil
// pré-login comme route initiale.
//
// NB : les écrans métier dépendent de services réseau (API) : ils ne
// peuvent pas être testés ici sans mock. Ce test couvre la coque de
// l'application (MaterialApp + thème + routes).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_store_app/main.dart';
import 'package:mobile_store_app/screens/welcome_screen_before_login.dart';

void main() {
  testWidgets(
    "MyApp affiche l'écran d'accueil pré-login avec le thème premium",
    (WidgetTester tester) async {
      // Construit l'application et déclenche une frame.
      await tester.pumpWidget(const MyApp());

      // Quelques frames pour laisser les animations de démarrage se jouer.
      // (pumpAndSettle ne termine jamais s'il reste une animation en boucle.)
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      // La coque MaterialApp est bien présente.
      expect(find.byType(MaterialApp), findsOneWidget);

      // La route initiale est l'écran d'accueil pré-login.
      expect(find.byType(WelcomePreLoginScreen), findsOneWidget);
    },
  );
}
