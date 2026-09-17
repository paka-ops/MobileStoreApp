# 🎨 Passe 3 — Palette « Calm Premium » + correctifs pixel overflow

Objectif : **arrêter de fatiguer l'œil**. La couleur ne porte plus de grandes
surfaces ; elle devient une trace, comme dans les apps haut de gamme.

### Palette ré-agencée (`app_colors.dart`)
- Base **neutre chaude** : fond `#F7F6F3`, cartes blanc pur, remplissages
  `#F1F0EC`, hairlines `#F2F0EC`.
- **Encre** `#17171B` : tous les boutons sont des pilules noires douces
  (remplace les aplats navy/teal).
- **Corail** `#E0653F` : accent réservé aux pastilles, points et chiffres clés.
- **Teal profond désaturé** `#0F766E` : marque + états interactifs (focus).
- Sémantiques désaturées : succès `#33946A`, note `#E0A04A`, erreur `#CF5A55`.
- **Pastels d'icônes adoucis** (peach/bleu/violet/menthe/sable/ciel/rose/gris).
- Mode sombre entièrement re-décliné (neutres profonds, encre inversée).

### Dégradés → « washes »
- `accentGradient` = dégradé de **marque** (teal profond), réservé au logo/héro.
- Nouveau `c.wash(tint:)` : teinte pâle (~5 %) → blanc, **texte encre**.
- `c.inkWash` : surface encre, pour **un seul** élément fort par écran.

### Typographie
- Hiérarchie « petit label gris → grande valeur encre » ;
  nouveaux styles `eyebrow`, `metric`, `sectionTitle`, `brand`.
- Graisses bornées à **w700** (fin des w800/w900).
- `greeting` = alias de `eyebrow` (13/w500).

### Composants retravaillés
`AppGreetingHeader` (cloche cercle gris + point corail, avatar carré arrondi),
`FloatingBottomNavBar` + `AppBottomNav` (barre **claire**, icône active encre),
`GradientInfoCard` (wash pastel), `CategoryCard` (adaptatif), `ChatFab` (encre),
`FloatingPriceTag`, `FloatingRatingCard`, `ProfileHeaderCard`,
`CustomTabBar` (onglet actif encre), `AppointmentCard`, `ServiceListTile`,
`AppTextField` / `AppSearchField` / `FilterDateChip` (fond gris, sans bordure).

### Écrans
Hub boutique (header allégé, KPI en wash, tuiles équipe en pastel,
onglet « Plus » : bascule de thème + `ServiceListTile`), pré-login (héro pastel
au lieu du dégradé saturé), connexion, sélection de boutique, `StoreItem`.

### 🐞 Correctifs pixel overflow
- `CategoryCard` : hauteur fixe supprimée → `LayoutBuilder` adaptatif
  (icône 32→48 px, lignes de texte ajustées) : plus de débordement en grille.
- `FloatingRatingCard`, `FloatingPriceTag`, `ChatFab.labeled` : largeur bornée
  + textes `Flexible` + ellipsis (usage en `Stack`/`Align`).
- `AppointmentCard` : blocs Date/Heure `Flexible` dans une `Row` bornée.
- Pré-login : `SingleChildScrollView` + `minHeight` (débordement vertical).
- KPI : `IntrinsicHeight` + `stretch` (hauteurs alignées).
- 4 écrans : Rows « texte dynamique + pastille » passées en `Flexible` + ellipsis.
- 7 `withOpacity` dépréciés migrés en `withValues(alpha:)`.

---

# 🎨 Passe 2 — Design system « Teal / Navy » (13 composants + écrans cœur)

Refonte visuelle selon le design system fourni (style santé type « DocSpot »)
appliqué au métier de BouTiKa. **Aucune logique métier modifiée.**

### Tokens ré-écrits
- `lib/core/theme/app_colors.dart` — palette teal `#0D9488` / émeraude
  `#10B981`, navy `#0F172A` (bouton primaire), fond `#FAFAFA`, pastels
  d'icônes, note `#FBBF24`, + variantes sombres complètes.
- `lib/core/theme/app_text_styles.dart` — **Poppins** (`google_fonts`) +
  styles `greeting`, `name`, `subtitle`, `label`, `cardTitle`, `rating`,
  `statValue` et helper `AppTextTheme(context)`.
- `lib/core/theme/app_shadows.dart` — ombre « soft elevation »
  (noir 5 %, blur 20, y 8) + `floating` / `floatNav` / `glow`.
- `lib/core/theme/app_decorations.dart` — `softCard`, `floatingCard`,
  `softIconCircle`, `pastelTile`, `floatingNav`, `AppGradients.teal`.
- `lib/core/theme/app_theme.dart` — boutons navy en pilule (rayon 28),
  champs remplis gris clair sans bordure (rayon 16), FAB circulaire,
  chip/snackbar navy, `tertiary` = note.
- `lib/core/constants/app_spacing.dart` — `AppRadius.card/button/navPill/search`,
  `AppSizes.primaryButtonHeight(56)`, `searchBarHeight(52)`,
  `categoryIcon(48)`, `profileAvatar(100)`, `floatingNav*`.

### 13 composants créés (`lib/widgets/`, export `design_system.dart`)
`AppGreetingHeader`, `SearchBarWidget`, `CategoryCard`/`CategoryGrid`,
`GradientInfoCard`/`GradientCardChip`, `FloatingRatingCard`,
`AppointmentCard`, `FloatingBottomNavBar`/`FloatingNavItem`,
`ProfileHeaderCard`/`ProfileStat`, `FloatingPriceTag`,
`CustomTabBar`/`CustomTabItem`, `ServiceListTile`,
`PrimaryButton`/`RoundActionButton`, `ChatFab`.

### Écrans refondus
- `store_page.dart` (hub) : header → `AppGreetingHeader`, nav → barre navy
  flottante, FAB → `ChatFab.labeled` + `RoundActionButton`, KPI →
  `GradientInfoCard`, inventaire → `CustomTabBar` (grille `CategoryCard` /
  gestion), catégories et équipe en pastels, onglet « Plus » →
  `ServiceListTile`.
- `welcome_screen_before_login.dart`, `login_screen.dart`,
  `welcome_screen.dart` + `widgets/store_item.dart` : dégradés teal, cartes
  sans bordure, `PrimaryButton` navy, typographie Poppins.
- Composants core alignés : `AppButton.primary` (navy), `AppIconButton` et
  `AppBackButton` (cercles blancs + ombre), `AppBottomNav` (barre navy
  flottante).

### Corrections de compilation
Imports manquants ajoutés (pré-existants) : `app_button`, `app_card`,
`app_dialog`, `app_bottom_nav`, `store_page`, `category_detail_screen`,
`order_story_screen`, `store_item`.

---

# 📋 CHANGELOG — Refonte UI/UX Premium

Historique complet de la refonte, écran par écran, commit par commit.
**Périmètre : UI uniquement** — logique métier, appels API, modèles,
navigation (destinations), validation de formulaires et gestion d'erreurs
**strictement inchangés**.

Branche : `feature/ui-refonte-complete-premium`

---

## Phase 1 — Design system

### `39a6096` feat(ui): create complete premium design system
- `lib/core/constants/` : `Spacing` (base 4 px), `AppRadius` (8→pill), `AppSizes` (cibles tactiles 48 px, bouton 52, input 56, AppBar 64, bottom nav 68), `AppDurations` (100/150/200/300/400/350 ms) + `AppCurves`.
- `lib/core/theme/` : palette light/dark complète (aucun blanc/noir pur en surface/texte), `DashColors` (résolveur contextuel, garde tous les getters legacy), `AppTextStyles` (échelle Inter : Display 40/Bold → Caption 11/Medium, Button 15/SemiBold uppercase), `AppShadows`, `AppDecorations`, `buildAppTheme(dark)` (Material 3, transitions de page slide+fade `PremiumPageTransitionsBuilder`).
- `lib/core/widgets/` : AppButton (5 variantes, scale 0.98 + haptique, loading), AppIconButton/AppBackButton, AppTextField/AppSearchField/FilterDateChip (focus glow + états d'erreur), AppCard/StatCard/ActionTile/InfoTile, EmptyState/ErrorState/InfoCallout, ShimmerBox + skeletons, AppDialog.show (blur + scale) / AppSheet.show, AppScreenHeader/AppBrandMark, AppBottomNav (indicateur pilule + badges), primitives (PressableScale, SoftChip, StatusPill, AppBadge, SectionHeader, OverlineLabel).
- `lib/main.dart` : MaterialApp thématé (light + dark + `themeMode` piloté par `appDarkMode`), key `rootScaffoldMessengerKey`.
- `lib/utils/app_colors.dart` : shim de ré-export vers `core/theme/` (zéro import cassé).
- `lib/utils/message.dart` : snackbars premium (succès / erreur / exception / abonnement expiré).

## Phase 2 — Authentification & sélection de boutique

### `0d2c947` feat(ui): redesign auth flow and store list
- **welcome_screen_before_login** : hero premium, boutons pilule, entrées animées.
- **login_screen** : carte de formulaire centrée, champs premium avec icônes, œil mot de passe, bouton de chargement intégré (flux `LoginService` inchangé, redirection `WelcomeScreen(stores, userType: UserService.userType ?? '')` conservée).
- **welcome_screen** : en-tête avec avatar utilisateur, liste de boutiques en cartes (`store_item.dart` : icône.camel, badges localisation/employés, chevron animé).
- **store_item** : carte premium + bouton « Gérer ».

## Phase 3 — Cœur métier

### `34cf696` feat(ui): complete premium redesign of the main store screen
- Hub boutique entièrement refondu : `IndexedStack` Accueil / Ventes / Stock / Plus, gate `BouTikaLoader` pendant le chargement.
- `AppBottomNav` avec badge de stock bas, header boutique avec avatar cliquable.
- Dialogs vente/employé/catégorie/dépense/déconnexion redessinés (AppDialog/AppSheet), flux `createOrder → formulaire → confirmation → makeOrder` et annulation-de-suppression **inchangés**.

### `29130c3` feat(ui): premium redesign of category product management screen
- Header standardisé + badges d'alerte, 3 StatCards KPI, recherche avec effacement.
- Cartes produits extensibles : barre de stock animée, chips de détail, actions Restocker/Modifier/Supprimer/Infos douces.
- Tous les dialogs (ajout, édition, restock, suppression, infos) redessinés ; validators identiques.

### `639ec08` feat(ui): premium redesign of product statistics screen
- Hero card (nom, prix, pilule de statut, barre de progression, chips achat/vente — achat masqué aux `employee`).
- Grille de KPI (Vendus / Entrés / CA / Marge / Taux de vente), skeleton shimmer au chargement, historique de restockage en cartes avec badges ±.
- Calculs `_fetchProductStats` et formatage monétaire conservés à l'identique.

### `4da4abe` feat(ui): premium redesign of low stock alerts screen
- Stats KPI (total / critique / bas), cartes extensibles avec barre de progression.
- Dialog restock avec encart d'alerte ; validation, `updateStock` et retrait automatique si stock > 10 conservés.

### `93ee9aa` feat(ui): premium redesign of sales history screen
- Barre de filtres premium (chips de dates, dropdown de statut), raccourcis rapports général/par catégorie.
- Cartes commandes extensibles : statut coloré par état, lignes produits, vendeur, total encadré.
- Suppression employer (`deleteOrder`) vs demande d'annulation employee (`changeOrderStatus("DELETION_PENDING")`) inchangées ; bouton « Modifier » conservé (NO-OP d'origine).

## Phase 4 — Analyses & rapports

### `c9a97fc` feat(ui): premium redesign of expenses screen
- Résumé (total / nombre) + filtres de période en cartes premium, chips de dates standardisées.
- Liste des dépenses avec icônes camel et montants en badge rouge doux.
- Tri descendant, filtres par dates et appels `SpendingServcie` inchangés.

### `5ca5fe6` feat(ui): redesign stock movements screen + fix pre-existing syntax error
- ⚠️ **Correctif inclus** : l'ancien fichier contenait une expression invalide `?(…)` qui empêchait toute compilation — remplacée par une condition correcte (prix d'achat masqué aux employés).
- Filtre de période premium, cartes de mouvement extensibles avec badge de quantité.
- `initState` complété avec `super.initState()` (absent d'origine) ; FAB « Nouvel Arrivage » conservé (NO-OP d'origine).

### `d582486` feat(ui): redesign category and general report screens
- Rapport par catégorie : cartes colorées par catégorie (cycle conservé), CA/bénéfice, barre de rentabilité bénéfice/vente (employer uniquement).
- Rapport général : grille de KPI premium (ventes, commandes, panier moyen, bénéfice), placeholder graphique premium.
- Calculs `_getSalesInformationByCategory` / `_computeResult` inchangés.

## Phase 5 — Comptes, abonnement, dashboard

### `d0fb733` feat(ui): premium redesign of subscription screen (screen + 4 widgets)
- Carte plan avec bandeau dégradé, statut Actif/Expiré calculé, jours restants.
- Liste des fonctionnalités, dialog de contact (numéro `+228 99691176` conservé).
- Écran désormais 100 % theme-aware (l'original était codé en clair).

### `5d85ead` feat(ui): polish employer signup stepper with premium buttons
- Boutons du stepper remplacés par AppButton ; garde `mounted` sur le timer 7 s.
- Validators, séquence de création et message d'origine (« Compte creer avec success », typo conservée) inchangés ; redirection `pushNamed("/login")` conservée.

### `4562c70` feat(ui): align dashboard on global theme system
- Suppression du `Theme` local redondant : le dashboard multi-boutiques hérite du thème global.
- Ombre de carte dark-compatible, snackbar premium ; données fictives (mock) inchangées.

### `ec0561e` fix(ui): replace legacy AppColors refs in dashboard header with DashColors

## Phase 6 — Nettoyage

### `b361d79` + `73a3f35` chore(ui): clean unused imports + replace stale widget test
- Imports inutilisés supprimés (cupertino, low_stock_product dans main, etc.).
- `test/widget_test.dart` : le boilerplate Counter de `flutter create` (cassé) est remplacé par un smoke test aligné sur l'app réelle.

### `debf67b` chore(ui): remove dead legacy UI widgets
- Suppression de 13 fichiers orphelins de l'ancien design (dialogs helpers de store_page, anciens widgets subscription, `build_empty_state.dart`).
- Conservés : `get_low_stock_product.dart` (utilisé par le hub), les 4 nouveaux widgets subscription, `boutika_loader.dart`, `store_item.dart`.

---

## Invariants respectés (audit)

| Invariant | Statut |
|---|---|
| Modèles (`lib/models/`) | ✅ 0 modification (`order_content.dart` non modifié) |
| Services (`lib/service/`) | ✅ 0 modification (typo `SpendingServcie` conservée) |
| Destinations de navigation | ✅ identiques (routes `/`, `/login`, push existants) |
| Noms de variables/fonctions/classes | ✅ identiques |
| Validation de formulaires | ✅ mêmes règles et messages |
| Gestion d'erreurs | ✅ mêmes messages et flux |

## Limitations connues

1. **Captures before/after** : pas de SDK Flutter dans l'environnement (ni
   compilation, ni `flutter test`, ni émulateur). Les captures n'ont pas pu
   être produites ; validation par revue statique + `tools/dart_check.py`.
2. **Police Inter** : déclarée dans `AppTextStyles.fontFamily` mais les TTF ne
   sont pas embarqués (pas d'accès réseau pour les télécharger). Fallback
   automatique sur la police système. Voir README_DESIGN.md §5.
3. **Dashboard** : données 100 % fictives (mock) — était déjà le cas avant la
   refonte ; aucune donnée réelle n'a été branchée (hors périmètre UI).
