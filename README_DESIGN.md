# 🎨 BouTiKa — Design System Premium

Ce document décrit le système de design mis en place lors de la refonte UI/UX
complète de BouTiKa, l'application de gestion de boutique utilisée toute la
journée en magasin.

> **Contrainte fondamentale respectée** : la refonte est **100 % UI/UX**.
> Aucune logique métier, aucun appel API, aucun modèle, aucun contrôleur,
> aucune destination de navigation et aucun identifiant existant n'a été modifié.

---

## 1. Principes de design

| Principe | Mise en œuvre |
|---|---|
| **Confort 8 h+** | Fonds grisés (`#F6F7F9` clair / `#0E1116` sombre), aucun blanc/noir pur en surface ni texte, saturations modérées |
| **Hiérarchie claire** | Échelle typographique complète (Display 40 → Caption 11), surtitres `OverlineLabel`, titres de section `SectionHeader` |
| **Cibles tactiles** | ≥ 48 px partout (`AppSizes.touchTarget`), boutons 52 px, inputs 56 px |
| **Feedback constant** | Scale 0.98 au press + haptic feedback, snackbars premium, shimmer de chargement |
| **Mode sombre parfait** | Chaque couleur a une variante sombre dédiée ; `DashColors(context)` résout automatiquement |
| **Motion mesurée** | 100/150/200/300/400 ms, courbes standardisées, transitions de page slide+fade |

## 2. Structure du design system

```
lib/core/
├── constants/
│   ├── app_spacing.dart        # Spacing (base 4px), AppRadius, AppSizes, AppShadowsSize?
│   └── app_durations.dart      # AppDurations + AppCurves
├── theme/
│   ├── app_colors.dart         # AppColors (palette statique light/dark)
│   │                           # DashColors — résolveur contextuel + appDarkMode
│   ├── app_text_styles.dart    # AppTextStyles — échelle typographique Inter
│   ├── app_shadows.dart        # AppShadows — élévations douces
│   ├── app_decorations.dart    # AppDecorations + AppGradients
│   └── app_theme.dart          # buildAppTheme(dark) — ThemeData complet M3
└── widgets/
    ├── buttons/app_button.dart     # AppButton, AppIconButton, AppBackButton
    ├── inputs/app_text_field.dart  # AppTextField, AppSearchField, FilterDateChip
    ├── cards/app_card.dart         # AppCard, StatCard, ActionTile, InfoTile
    ├── lists/empty_state.dart      # EmptyState, ErrorState, InfoCallout
    ├── loading/shimmer.dart        # ShimmerBox, skeletons, AppSpinner
    ├── dialogs/app_dialog.dart     # AppDialog.show, AppSheet.show
    ├── navigation/app_header.dart  # AppScreenHeader, AppBrandMark
    ├── navigation/app_bottom_nav.dart # AppBottomNav (indicateur pilule)
    └── common/primitives.dart      # PressableScale, SoftChip, StatusPill, AppBadge…
```

Compatibilité : `lib/utils/app_colors.dart` reste un **shim de ré-export** vers
`core/theme/` pour ne casser aucun import existant. `lib/utils/message.dart`
fournit les snackbars premium (`showSuccessMessage`, `showErrorMessage`,
`showExceptionMessage`, `showSubscriptionExpiredMessage`).

## 3. Quick start

```dart
import 'package:mobile_store_app/core/theme/app_colors.dart';
import 'package:mobile_store_app/core/widgets/buttons/app_button.dart';

// 1. Couleurs theme-aware
final c = DashColors(context);
Container(color: c.card, …)

// 2. Bouton premium
AppButton.primary(label: "Valider la vente", icon: Icons.check_rounded, onPressed: …)

// 3. Champ avec focus glow + erreur intégrée
AppTextField(controller: ctrl, label: "Quantité", icon: Icons.inventory_2_outlined,
             validator: (v) => …)

// 4. Dialog premium (blur + scale)
AppDialog.show(context, icon: Icons.delete_outline_rounded, iconSoft: c.dangerSoft,
               title: "Supprimer ?", message: "…", actions: […])
```

## 4. Écrans refondus (15/15)

Auth : pré-login, login, sélection de boutique · Cœur : hub boutique (4 onglets),
gestion produit par catégorie, stats produit, alertes stock, historique ventes ·
Analyse : rapport général, rapport par catégorie, dépenses, mouvements de stock ·
Divers : inscription employé, abonnement, dashboard multi-boutiques.

Voir **CHANGELOG_UI.md** pour le détail par écran et par commit.

## 5. Limitations connues

- **Police Inter** : `AppTextStyles.fontFamily` déclare `'Inter'`, mais les
  fichiers TTF ne sont **pas embarqués** dans le projet (aucun accès réseau
  pendant la refonte pour les télécharger). Flutter retombe proprement sur la
  police système — le design reste cohérent. Pour activer Inter : déposer les
  TTF dans `assets/fonts/` et déclarer la famille dans `pubspec.yaml`.
- **Captures d'écran before/after** : le SDK Flutter/Dart n'est pas disponible
  dans l'environnement de travail (aucune compilation ni `flutter test`
  possible). Les captures avant/après n'ont donc pas pu être produites ; la
  validation s'est faite par revue statique + vérificateur syntaxique maison
  (`tools/dart_check.py`).
