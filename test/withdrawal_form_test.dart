import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_store_app/models/withdrawal.dart';
import 'package:mobile_store_app/screens/withdrawal_page.dart';

void main() {
  Future<void> openForm(WidgetTester tester, {Withdrawal? withdrawal}) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(builder: (context) {
          return TextButton(
            onPressed: () => showWithdrawalFormDialog(
              context,
              storeId: 'store',
              withdrawal: withdrawal,
            ),
            child: const Text('Ouvrir'),
          );
        }),
      ),
    ));
    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('La modification affiche les valeurs existantes et peut être annulée',
      (tester) async {
    await openForm(tester, withdrawal: Withdrawal(
      id: '1', amount: 2500.5, message: 'Achat', date: DateTime(2025, 1, 2, 14, 30),
    ));
    expect(find.text('Modifier le retrait'), findsOneWidget);
    expect(find.text('2500.5'), findsOneWidget);
    expect(find.text('Achat'), findsOneWidget);
    expect(find.text('Date du retrait (non modifiable) : 02/01/2025 14:30'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, '3000');
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(find.text('Modifier le retrait'), findsNothing);
  });

  testWidgets('Le formulaire refuse un montant et un motif invalides', (tester) async {
    await openForm(tester, withdrawal: Withdrawal(id: '1', amount: 10, message: 'Motif'));
    await tester.enterText(find.byType(TextFormField).first, '0');
    await tester.enterText(find.byType(TextFormField).last, '   ');
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(find.text('Indiquez un montant valide'), findsOneWidget);
    expect(find.text('Indiquez le motif'), findsOneWidget);
  });
}
