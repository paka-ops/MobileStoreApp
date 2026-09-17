# 🎨 BouTiKa — Design System « Calm Premium »

Refonte **visuelle** de l'application : base neutre chaude, texte encre, et
la couleur réduite à de **petites touches** — la recette des apps haut de
gamme, qui ne fatigue pas l'œil sur une journée de travail.

> **Règle d'or respectée : 0 % de logique métier modifiée.**
> Aucun service, modèle, contrôleur, appel API, identifiant, nom de variable
> ou destination de navigation n'a changé. Seuls les widgets de présentation
> (couleurs, formes, espacements, typographie, animations) ont été retravaillés.

---

## 1. Les 4 règles de couleur (pourquoi ça ne pique plus les yeux)

| # | Règle | Mise en œuvre |
|---|---|---|
| 1 | **La couleur ne porte jamais une grande surface** | Fonds neutres (`#F7F6F3`), cartes blanches, texte encre. Aucun aplat saturé plein écran. |
| 2 | **L'accent est une trace, pas un bloc** | Corail `#E0653F` uniquement en pastille, point ou chiffre clé (≤ 2 % de l'écran). |
| 3 | **Les dégradés sont des washes** | Teinte pâle (~5 %) → blanc. Le texte reste encre : jamais de blanc sur couleur saturée. |
| 4 | **Une seule famille d'action** | Les boutons sont des pilules encre `#17171B` (comme « See all » / « Details »), pas des aplats colorés. |

**Résultat** : l'écran se lit en niveaux de gris chauds ; la couleur ne
revient que là où elle porte une information (alerte, statut, catégorie).

---

## 2. Palette

| Rôle | Clair | Sombre |
|---|---|---|
| Fond général | `#F7F6F3` (blanc cassé chaud) | `#121215` |
| Voile haut d'écran | `#F9F2EE` | `#171315` |
| Cartes | `#FFFFFF` | `#1A1A1E` |
| Zone remplie (recherche, champs) | `#F1F0EC` | `#202026` |
| Bordure / hairline | `#ECEAE5` / `#F2F0EC` | `#2B2B32` / `#23232A` |
| **Encre** (boutons, icônes actives, titres) | `#17171B` | `#F5F4F1` (pastille claire) |
| Texte principal | `#1A1A1F` | `#F2F1EE` |
| Texte secondaire | `#8B8B92` | `#9A9AA1` |
| Texte tertiaire (labels) | `#B3B3B9` | `#6E6E76` |
| **Accent corail** (alertes, points, highlights) | `#E0653F` | `#F08A66` |
| **Teal de marque** (interactif, focus, logo) | `#0F766E` | `#5FB3A8` |
| Succès / « Confirmé » | `#33946A` | `#6BC094` |
| Note / étoile | `#E0A04A` | `#EFB65C` |
| Erreur | `#CF5A55` | `#E58B85` |
| Info / Warning | `#5278B8` / `#C88324` | `#8AA9D8` / `#DCA85C` |

**Pastels d'icônes** (désaturés, cyclage automatique) : peach `#FBEDE7`,
bleu `#EDF2FA`, violet `#F3F1FB`, menthe `#E9F5EF`, sable `#FBF3E6`,
ciel `#EAF3F9`, rose `#FCEFF0`, gris `#F3F2EF`.

```dart
final c = DashColors(context);

c.ink / c.onInk              // pilules d'action (noir doux)
c.accent / c.accentSoft      // corail : alertes, points, chiffres clés
c.primary / c.primarySoft    // teal de marque : focus, icônes interactives
c.textPrimary / textSecondary / textTertiary
c.card / c.fill / c.hairline
c.wash(tint: c.pastelAt(2))  // dégradé très pâle teinte → blanc
c.inkWash                    // surface encre (usage rare, 1 par écran)
c.cardShadow / c.floatingShadow
c.navSurface / c.navActive / c.navInactive / c.navPill
```

> ⚠️ **Mode sombre conservé** : chaque couleur possède sa variante sombre
> (fonds neutres profonds, encre inversée en pastille claire). La bascule
> clair/sombre de l'app continue de fonctionner — elle est désormais dans
> l'onglet **« Plus »** pour alléger l'en-tête.

---

## 3. Typographie — Poppins

Police **Poppins** via `google_fonts`. Principe : *petit label gris → grande
valeur encre*. Graisses bornées à w700 (fini les w800/w900 « criards »).

| Usage | Style | Taille / graisse |
|---|---|---|
| Ligne d'accroche grise (« Bonjour, Amanda ») | `AppTextStyles.eyebrow` (= `greeting`) | 13 / w500 |
| Nom / valeur d'en-tête | `AppTextStyles.name` | 21 / w700 |
| Grand chiffre (KPI, solde) | `AppTextStyles.metric` | 26 / w700 |
| Titre de section | `AppTextStyles.sectionTitle` | 17.5 / w700 |
| Titre de page | `AppTextStyles.h2` | 22 / w700 |
| Titre de carte / ligne | `AppTextStyles.cardTitle` | 14.5 / w600 |
| Corps | `AppTextStyles.body` | 14 / w400 |
| Sous-titre de ligne | `AppTextStyles.tileSubtitle` | 12.5 / w400 |
| Label « Date / Heure » | `AppTextStyles.label` | 11.5 / w400 |
| Montant | `AppTextStyles.amount` | 15 / w700 tabulaire |
| Marque (« BouTiKa ») | `AppTextStyles.brand` | 17 / w700 |

Raccourci thémé : `final t = AppTextTheme(context); t.eyebrow, t.metric…`

---

## 4. Composants réutilisables (13)

```dart
import 'package:mobile_store_app/widgets/design_system.dart';
```

| # | Composant | Fichier | Style « calm premium » |
|---|---|---|---|
| 1 | `AppGreetingHeader` | `greeting_header.dart` | Ligne grise + nom encre + localisation ; cloche en cercle gris clair avec **point corail** ; avatar carré arrondi |
| 2 | `SearchBarWidget` | `search_bar_widget.dart` | Fond `#F1F0EC`, rayon 16, h 52, zéro bordure |
| 3 | `CategoryCard` / `CategoryGrid` | `category_card.dart` | Carte blanche, icône en cercle pastel (taille **adaptative**), grille 3 colonnes |
| 4 | `GradientInfoCard` | `gradient_info_card.dart` | **Wash pastel → blanc**, texte encre, chevron optionnel (variante `inkVariant` pour une carte forte) |
| 5 | `FloatingRatingCard` | `floating_rating_card.dart` | Carte flottante, avatar pastel, pastille note sable (largeur bornée) |
| 6 | `AppointmentCard` | `appointment_card.dart` | Avatar + nom/rôle + menu ; badge « Confirmé » pastel ; divider ; Date \| Heure |
| 7 | `FloatingBottomNavBar` | `custom_bottom_nav.dart` | Barre flottante **claire**, rayon 30, marges 24/16, icône active encre sur pilule gris clair |
| 8 | `ProfileHeaderCard` | `profile_header_card.dart` | Avatar 100 px, badge « Top » sable/ambre, stats à dividers fins |
| 9 | `FloatingPriceTag` | `floating_price_tag.dart` | Étiquette blanche flottante (largeur bornée), variante `.accent` encre |
| 10 | `CustomTabBar` | `custom_tab_bar.dart` | Onglet actif **encre** + underline fin (plus de teal vif) |
| 11 | `ServiceListTile` | `service_list_tile.dart` | Icône pastel ronde, titre encre, sous-titre gris, chevron, padding v12 |
| 12 | `PrimaryButton` / `RoundActionButton` | `primary_button.dart` | Pilule **encre** pleine largeur, h 56, rayon 28 |
| 13 | `ChatFab` | `chat_fab.dart` | Cercle **encre** (+ variante pilule `.labeled`) |

---

## 5. Correctifs « pixel overflow » de cette passe

Sans SDK Flutter dans l'environnement, ces correctifs viennent d'un audit
statique des causes classiques (et non d'un `flutter run`). Ce qui a été
corrigé :

| Cause | Correctif |
|---|---|
| **`CategoryCard` à hauteur fixe (118) dans une cellule de grille plus petite** → débordement sur écrans étroits | La tuile n'impose plus de hauteur : `LayoutBuilder` mesure la cellule et adapte la taille de l'icône (32→48) + le nombre de lignes du texte. Ratio de grille ajusté (0.88). |
| **`FloatingRatingCard` / `FloatingPriceTag` / `ChatFab.labeled`** dans un `Stack`/`Align` → largeur non bornée, texte sans ellipsis | `ConstrainedBox(maxWidth: 300 / 230 / 220)` + textes `Flexible` + ellipsis → plus d'assertion « unbounded flex » ni de débordement. |
| **`AppointmentCard`** : `Flexible` dans une `Row` non bornée (assertion RenderFlex) | Les blocs Date/Heure sont `Flexible` dans la `Row` **bornée** de la carte ; les textes sont ellipsés. |
| **En-tête** : nom de boutique + cloche + avatar sur une seule ligne | Hiérarchie revue (3 lignes courtes côté gauche) ; chaque texte est `Flexible` + ellipsis ; bascule de thème déplacée vers « Plus ». |
| **Écran pré-login** : `Column` + `Spacer` en plein écran → débordement vertical sur petits écrans / grande police | Passage en `SingleChildScrollView` + `ConstrainedBox(minHeight)` + `IntrinsicHeight` : la page défile au lieu de déborder. |
| **KPI côte à côte** de hauteurs différentes | `IntrinsicHeight` + `CrossAxisAlignment.stretch` : tuiles alignées et bornées. |
| **Rows « texte dynamique + pastille »** (prix + badge, n° de commande + statut, « X restant » + %) sur 4 écrans | Texte dynamique en `Flexible` + `maxLines: 1` + ellipsis. |
| **`FilterDateChip` / champs** : bordures + rayon 14 incohérents | Fond gris clair, rayon 16, bordures transparentes (focus teal 1.4). |
| **7 `withOpacity`** (dépréciés → warnings d'analyse) dans `dashboard_screens.dart` | Migrés en `withValues(alpha:)`. |

**S'il reste un débordement** : Flutter affiche des rayures jaunes/noires et
une ligne du type `A RenderFlex overflowed by N pixels on the right/bottom`
dans la console. Envoyez-moi ce message + l'écran concerné, je corrige ciblé.

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
flutter pub get      # obligatoire : le paquet google_fonts a été ajouté
flutter analyze      # vérification de compilation
flutter run
```

- **Premier lancement avec réseau** recommandé (téléchargement de Poppins
  puis mise en cache). Sans réseau, la police système est utilisée : le
  design reste cohérent (tailles, graisses, espacements).

---

## 8. Écrans refondus / restants

**Refondus** : hub boutique (Accueil · Ventes · Stock · Plus),
pré-login, connexion, sélection de boutique + `StoreItem`,
`AppGreetingHeader`, `PrimaryButton`, `AppCard`, `AppTextField`,
`FilterDateChip`, `AppBottomNav`.

**Restants (passe suivante)** : `category_detail_screen`,
`product_details_page`, `order_story_screen`, `low_stock_product`,
`stock_history_screen`, `spending_page`, `general_report_screen`,
`category_report_screen`, `EmployerFormPage`, `dashboard_screens`,
`subscription_screen_page`. Ils héritent **déjà** des nouveaux tokens
(couleurs, typographie, ombres) ; il reste à y remplacer les widgets maison
par les composants du design system.
