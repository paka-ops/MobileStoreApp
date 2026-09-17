# 🎨 BouTiKa — Design System « Teal / Navy »

Refonte **visuelle** de l'application selon le design system fourni (style
type « santé / DocSpot ») appliqué au métier réel de BouTiKa (gestion de
boutique : stock, ventes, dépenses, abonnements).

> **Règle d'or respectée : 0 % de logique métier modifiée.**
> Aucun service, modèle, contrôleur, appel API, identifiant, nom de variable
> ou destination de navigation n'a changé. Seuls les widgets de présentation
> (couleurs, formes, espacements, typographie, animations) ont été retravaillés.

---

## 1. Ce qui a été fait

| Étape | Détail |
|---|---|
| **1. Tokens** | `lib/core/theme/` ré-écrit (couleurs, typographie, ombres, décorations) + nouveaux rayons/tailles dans `lib/core/constants/app_spacing.dart` + `ThemeData` mis à jour |
| **2. Composants** | **13 composants réutilisables** créés dans `lib/widgets/` + un import unique (`design_system.dart`) |
| **3. Écrans cœur** | Hub boutique (4 onglets), pré-login, connexion, sélection de boutique re-skinés |
| **4. Composants core** | `AppButton`, `AppIconButton`, `AppBackButton`, `AppBottomNav`, `AppCard`… alignés sur le nouveau langage visuel |

### Écrans refondus dans cette passe

| Écran | Fichier |
|---|---|
| Accueil pré-login | `lib/screens/welcome_screen_before_login.dart` |
| Connexion | `lib/screens/login_screen.dart` |
| Sélection de boutique | `lib/screens/welcome_screen.dart` + `lib/widgets/store_item.dart` |
| Hub boutique (Accueil / Ventes / Stock / Plus) | `lib/screens/store_page.dart` |

### Écrans restants (passe suivante, mêmes tokens déjà en place)

`category_detail_screen`, `product_details_page`, `order_story_screen`,
`low_stock_product`, `stock_history_screen`, `spending_page`,
`general_report_screen`, `category_report_screen`, `EmployerFormPage`,
`dashboard_screens`, `subscription_screen_page`.

Ils héritent **déjà** de la nouvelle palette, typographie et `ThemeData` ;
il reste à y remplacer les quelques widgets « maison » par les composants
du design system (ex. `ServiceListTile`, `CustomTabBar`, `ProfileHeaderCard`).

---

## 2. Palette

| Rôle | Clair | Sombre |
|---|---|---|
| Accent primaire (teal) | `#0D9488` | `#2DD4BF` |
| Dégradé signature | `#0D9488 → #10B981` | `#0D9488 → #10B981` |
| Fond général | `#FAFAFA` | `#0B1120` |
| Cartes | `#FFFFFF` | `#111C2E` |
| Zone remplie / recherche | `#F3F4F6` | `#16233A` |
| Bordure / hairline | `#EDEFF3` / `#F1F3F6` | `#22314A` / `#1B2739` |
| Texte principal | `#1A1A2E` | `#F1F5F9` |
| Texte secondaire | `#9CA3AF` | `#94A3B8` |
| Bouton primaire (navy) | `#0F172A` | `#1E293B` |
| Succès / Confirmé | `#22C55E` | `#4ADE80` |
| Note / étoile | `#FBBF24` | `#FBBF24` |
| Ambre (accent 2) | `#F59E0B` | `#FBBF24` |
| Erreur | `#EF4444` | `#F87171` |

**Pastels d'icônes** (cyclage automatique) : rose `#FCE7F3`, rouge `#FEE2E2`,
violet `#EDE9FE`, orange `#FFEDD5`, bleu `#DBEAFE`, teal `#CCFBF1`,
vert `#DCFCE7`, ambre `#FEF3C7` — avec une variante sombre dédiée.

### Utilisation

```dart
final c = DashColors(context);      // résout clair / sombre automatiquement

c.primary          c.accentGradient     c.pastelAt(2)
c.navy             c.cardShadow         c.floatingShadow
c.textPrimary      c.fill               c.hairline
c.buttonPrimary    c.buttonOnPrimary    c.rating
```

> ⚠️ **Mode sombre conservé** : chaque couleur a une variante sombre
> (la bascule clair/sombre de l'app continue de fonctionner).

---

## 3. Typographie — Poppins

Police **Poppins** via `google_fonts` (`AppTextStyles.fontFamily = 'Poppins'`).

| Usage | Style | Taille / graisse |
|---|---|---|
| Greeting « Bonjour Amanda » | `AppTextStyles.greeting` | 24 / Bold |
| Nom principal (fiche) | `AppTextStyles.name` | 22 / Bold |
| Titre de page | `AppTextStyles.h2` | 24 / Bold |
| Sous-titre (localisation, rôle) | `AppTextStyles.subtitle` | 15 / Medium |
| Titre de carte / ligne | `AppTextStyles.cardTitle` | 15 / SemiBold |
| Corps de texte | `AppTextStyles.body` | 14 / Regular |
| Sous-titre de liste (gris) | `AppTextStyles.tileSubtitle` | 13 / Regular |
| Label « Date / Heure » | `AppTextStyles.label` | 11.5 / Regular |
| Montant / KPI | `AppTextStyles.amount` | 18 / Bold tabulaire |

Raccourci thémé : `final t = AppTextTheme(context); t.greeting, t.muted…`

> Les styles sont `final` (et non `const`) car GoogleFonts résout la police à
> l'exécution : **la famille est téléchargée puis mise en cache au premier
> rendu**. Hors ligne, Flutter retombe proprement sur la police système.

---

## 4. Composants réutilisables (13)

Tous dans `lib/widgets/`, exportés par un seul fichier :

```dart
import 'package:mobile_store_app/widgets/design_system.dart';
```

| # | Composant | Fichier | Spécificité |
|---|---|---|---|
| 1 | `AppGreetingHeader` | `greeting_header.dart` | Greeting + localisation + chevron, cloche (cercle clair) + avatar, padding 20 px |
| 2 | `SearchBarWidget` | `search_bar_widget.dart` | Fond `#F3F4F6`, rayon 16, hauteur 52, sans bordure |
| 3 | `CategoryCard` / `CategoryGrid` | `category_card.dart` | Carte blanche rayon 20, icône en cercle pastel 48, grille 3 colonnes |
| 4 | `GradientInfoCard` / `GradientCardChip` | `gradient_info_card.dart` | Dégradé teal diagonal, rayon 20, texte blanc, padding 16 |
| 5 | `FloatingRatingCard` | `floating_rating_card.dart` | Carte flottante rayon 16, avatar + badge étoile jaune |
| 6 | `AppointmentCard` | `appointment_card.dart` | Avatar + nom/rôle + menu, badge « Confirmé », divider, Date \| Heure |
| 7 | `FloatingBottomNavBar` / `FloatingNavItem` | `custom_bottom_nav.dart` | Barre navy flottante rayon 30, marges 24/16, pilule active translucide |
| 8 | `ProfileHeaderCard` / `ProfileStat` | `profile_header_card.dart` | Avatar 100 px centré, badge « Top » étoilé, stats à dividers fins |
| 9 | `FloatingPriceTag` | `floating_price_tag.dart` | Étiquette blanche flottante rayon 16, positionnable en `Stack` |
| 10 | `CustomTabBar` / `CustomTabItem` | `custom_tab_bar.dart` | Onglets texte, actif teal + underline animé |
| 11 | `ServiceListTile` | `service_list_tile.dart` | Icône pastel ronde, titre bold + sous-titre gris, chevron, padding v12 |
| 12 | `PrimaryButton` / `RoundActionButton` | `primary_button.dart` | Pilule navy pleine largeur, hauteur 56, rayon 28 (+ variantes `.gradient`, `.outline`) |
| 13 | `ChatFab` | `chat_fab.dart` | Cercle dégradé teal flottant (+ variante pilule `.labeled`) |

### Exemples

```dart
// Header de hub
AppGreetingHeader(
  greeting: "Bonjour, ${UserService.username} 👋",
  title: widget.store.name,
  subtitle: widget.store.location,
  onTapSubtitle: () => _showStoreSwitcherSheet(context, colors),
  notificationCount: lowStockProducts.length,
  onTapNotifications: () => openLowStock(),
  onTapAvatar: () => _showStoreSwitcherSheet(context, colors),
);

// Grille de catégories
CategoryGrid(
  itemCount: categories.length,
  itemBuilder: (i) => CategoryCard(
    label: categories[i].name,
    icon: Icons.category_rounded,
    index: i,
    onTap: () => openCategory(categories[i]),   // même destination qu'avant
  ),
);

// Bouton principal
PrimaryButton(label: "Enregistrer", icon: Icons.check_rounded,
              isLoading: _isSaving, onPressed: _submit);

// Navigation flottante
FloatingBottomNavBar(
  items: [FloatingNavItem(icon: Icons.home_outlined,
                          activeIcon: Icons.home_rounded, label: "Accueil"), …],
  currentIndex: _currentIndex,
  onTap: (i) => setState(() => _currentIndex = i),
  badges: [0, 0, lowStockProducts.length, 0],
);
```

---

## 5. Effets visuels

| Règle | Valeur appliquée |
|---|---|
| Rayons des cartes | 16 → 24 px (`AppRadius.lg`, `AppRadius.xl`, `AppRadius.card = 24`) |
| Ombre « soft elevation » | `Colors.black @5 %`, `blurRadius: 20`, `offset: (0, 8)` |
| Ombre flottante (nav, FAB, tag) | `@12 %`, `blurRadius: 24`, `offset: (0, 10)` |
| Espacement entre sections | 20 → 24 px |
| Icônes | Material rounded / outlined (pas d'ajout de `flutter_iconly`) |
| Hero | Support `heroTag` sur `AppointmentCard`, `ProfileHeaderCard`, `ChatFab` |
| Transitions de page | `PremiumPageTransitionsBuilder` (fade + slide, déjà en place) |

---

## 6. Ce qui n'a PAS été touché (garantie logique métier)

- ✅ `lib/service/**` (API, Dio/http, endpoints) — **aucune modification**
- ✅ `lib/models/**` — **aucune modification**
- ✅ Contrôleurs, `TextEditingController`, `GlobalKey<FormState>`, validation
- ✅ `initState` / `dispose` / `_fetchAllData` / `_handleLogin` / tous les
  handlers métier : **appelés exactement comme avant**
- ✅ Destinations de navigation (écrans, arguments passés) — identiques
- ✅ Noms de classes, méthodes, variables publiques — inchangés
- ✅ Modes clair **et** sombre — tous deux opérationnels

Toutes les lignes de logique supprimées puis ré-introduites ont été
vérifiées : elles sont **identiques** (ex. `_showStoreSwitcherSheet`,
`_showStartSaleDialog`, `_showExpenseDialog`, `.then((_) => _fetchAllData())`),
simplement branchées sur les nouveaux widgets.

### Corrections d'imports pré-existantes (nécessaires à la compilation)

Le dépôt contenait des références à des classes **sans import** (le code ne
pouvait pas compiler). Ces imports manquants ont été ajoutés, sans toucher à
la logique : `app_button.dart` (primitives), `app_card.dart` et
`app_dialog.dart` (`AppDecorations`), `store_page.dart` (`AppCard`,
`ActionTile`, `BouTikaLoader`), `category_detail_screen.dart` et
`order_story_screen.dart` (`AppScreenHeader`), `store_item.dart`
(`AppSpacing`), `app_bottom_nav.dart` (`AppSpacing`).

---

## 7. À faire de ton côté

```bash
flutter pub get      # obligatoire : le paquet google_fonts vient d'être ajouté
flutter analyze      # vérification de compilation
flutter run
```

- **Premier lancement avec réseau** recommandé (téléchargement de Poppins
  puis mise en cache). Sans réseau, la police système est utilisée : le
  design reste cohérent (tailles, graisses, espacements).
- Le sandbox de refonte n'avait **ni SDK Flutter ni réseau** : aucune
  compilation n'a pu y être lancée. La validation a été faite par revue
  statique (équilibrage des délimiteurs + résolution de tous les imports
  sur les 77 fichiers Dart).
