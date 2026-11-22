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

Les anciens barrels de compatibilité (`lib/utils/app_colors.dart`,
`lib/widgets/design_system.dart`, `lib/screens/`) ont été purgés après la
migration : tout import passe désormais par `core/`, `shared/` ou `features/`.
`lib/utils/message.dart` fournit les snackbars premium (`showSuccessMessage`,
`showErrorMessage`, `showExceptionMessage`, `showSubscriptionExpiredMessage`).

### 2 bis. Architecture applicative — `core / shared / features`

```
lib/
├── core/
│   ├── config/      app_config.dart, saas_module.dart, saas_module_manager.dart
│   ├── constants/   app_spacing.dart (Spacing, AppRadius, AppSizes)
│   ├── router/      app_router.dart, route_arguments.dart
│   ├── services/    api_client.dart
│   ├── theme/       app_colors, app_text_styles, app_dimensions, …
│   ├── utils/       formatters, date_utils, color_utils
│   └── widgets/     boutons, champs, cartes, dialogues, listes, chargement
├── shared/
│   ├── models/      Store, Category, Product, Order, Spending, Withdrawal, …
│   ├── services/    ProductService, OrderService, UserService, …
│   └── widgets/     kit partagé (ui_kit.dart) + loading/boutika_loader.dart
├── features/        un dossier par domaine (auth, stores, store_detail,
│                    dashboard, categories, products, stock, history,
│                    order_story, spending, withdrawals, reports,
│                    subscription, welcome)
└── main.dart        MaterialApp + AppRouter
```

### 2 ter. Routage — `core/router/`

`AppRouter` remplace la table de routes déclarée en ligne dans `main.dart` :

| Membre | Rôle |
|---|---|
| `AppRouter.initialRoute` | `/` (`AppConfig.routeRoot`) — accueil pré-login |
| `AppRouter.routes` / `routesFor(manager)` | routes statiques `/` et `/login`, filtrées par `SaaSModuleManager` |
| `AppRouter.onGenerateRoute` | routes des modules à arguments (`/store`, `/history`, `/expenses`, …) via `RouteArguments` typés |
| `AppRouter.moduleForRoute(route)` | associe une route à son `SaaSModule` |

Invariance : `/` et `/login` gardent exactement les mêmes builders ; les écrans
poussés par `MaterialPageRoute` dans les modules ne changent pas.

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

- **Police Poppins (nouvelle passe « Teal / Navy »)** : la typographie passe
  d'Inter à **Poppins** via le paquet `google_fonts` (résolution + mise en
  cache au premier rendu ; repli automatique sur la police système hors ligne).
  Lancer `flutter pub get` après récupération de la branche.
  ➜ Voir **DESIGN_SYSTEM.md** pour le design system complet (palette teal/navy,
  13 composants, écrans refondus).
- **Captures d'écran before/after** : le SDK Flutter/Dart n'est pas disponible
  dans l'environnement de travail (aucune compilation ni `flutter test`
  possible). Les captures avant/après n'ont donc pas pu être produites ; la
  validation s'est faite par revue statique + vérificateur syntaxique maison
  (`tools/dart_check.py`).
