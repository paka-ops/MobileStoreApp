import 'package:flutter/material.dart';

import 'package:mobile_store_app/features/stores/widgets/store_item.dart';
import 'package:mobile_store_app/shared/models/Store.dart';

/// ============================================================================
/// STORES LIST VIEW — liste adaptative des boutiques.
///
///   • largeur > 600 px → grille `maxCrossAxisExtent: 400`, espaces 16,
///     ratio 1.4 (padding 24‑8‑24‑110)
///   • sinon            → liste verticale, chaque carte espacée de 14 px
///     (même padding)
///
/// La suppression est déléguée au contrôleur via l'index affiché, comme le
/// faisait le `setState(() => stores.removeAt(index))` d'origine.
/// ============================================================================
class StoresListView extends StatelessWidget {
  final List<Store> stores;
  final void Function(int index) onDeleteAt;

  const StoresListView({
    super.key,
    required this.stores,
    required this.onDeleteAt,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 600;

        if (isWide) {
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 110),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.4,
            ),
            itemCount: stores.length,
            itemBuilder: (context, index) => StoreItem(
              store: stores[index],
              otherStores: stores,
              isDeleted: (value) {
                if (value) onDeleteAt(index);
              },
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 110),
          itemCount: stores.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: StoreItem(
              store: stores[index],
              otherStores: stores,
              isDeleted: (value) {
                if (value) onDeleteAt(index);
              },
            ),
          ),
        );
      },
    );
  }
}
