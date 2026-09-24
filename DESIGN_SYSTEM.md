# 🎨 BouTiKa — Design System « Lavande » (v2)

Système de design **unique** de l'application : fond dégradé lavande, surfaces
blanches, texte encre, accents **rose** et **violet** utilisés avec parcimonie.

> **Migration complète** : l'ancien design system « Calm Premium » (teal/corail)
> a été remplacé dans **tout le projet**. Voir `MIGRATION_V2.md` pour le
> détail, les garanties et les vérifications.

---

## 1. Palette — `core/theme/app_colors.dart`

### Fond & surfaces

| Jeton | Clair | Sombre | Rôle |
|---|---|---|---|
| `primaryGradientStart` | `#E8E4F3` | `#1B1826` | Haut du dégradé de fond (lavande) |
| `primaryGradientEnd` | `#F5F5F7` | `#121214` | Bas du dégradé |
| `backgroundLight` / `background` | `#FAFAFA` | `#121214` | Fond général |
| `cardBackground` / `card` | `#FFFFFF` | `#1C1C1E` | Cartes, sheets, barres |
| `fill` / `pillBackground` | `#F2F2F7` | `#2C2C2E` | Zones remplies, piste des pills |
| `fillStrong` | `#E8E8ED` | `#3A3A3C` | Remplissage appuyé, désactivé |
| `border` | `#E5E5EA` | `#38383A` | Traits visibles |
| `hairline` / `divider` | `#EFEFF3` | `#2C2C2E` | Séparateurs doux |

### Textes

| Jeton | Clair | Sombre | Rôle |
|---|---|---|---|
| `textPrimary` / `textDark` | `#1A1A1A` | `#F2F2F7` | Titres, valeurs |
| `textSecondary` / `textGrey` | `#8E8E93` | `#9A9AA1` | Sous-titres, métadonnées |
| `textLight` / `textTertiary` | `#B0B0B5` | `#6E6E73` | Labels discrets |
| `ink` | `#1A1A1A` | `#F2F2F7` | Boutons pillules, icônes actives |
| `onInk` | `#FFFFFF` | `#1A1A1A` | Contenu posé sur l'encre |

### Accents & sémantiques

| Jeton | Clair | Sombre | Rôle |
|---|---|---|---|
| `accentPink` / `accent` | `#E91E8C` | `#FF6FB5` | Accent principal (rose) |
| `accentPurple` / `primary` | `#9C27B0` | `#CE93D8` | Marque (violet), états interactifs |
| `badgeRed` / `danger` | `#FF3B30` | `#FF6B61` | Badges de notification, suppressions |
| `accentGreen` / `success` | `#4CAF50` | `#81C784` | Validations |
| `starYellow` / `rating` | `#FFC107` | `#FFD54F` | Étoiles / notes |
| `warning` | `#FF9F0A` | `#FFB74D` | Alertes |
| `info` | `#5E5CE6` | `#9FA8FF` | Informations |

Chaque accent possède une variante `…Soft` (`accentSoft`, `primarySoft`,
`successSoft`, `dangerSoft`, `ratingSoft`, `warningSoft`, `infoSoft`) utilisée
comme fond de pastille.

### Pills (onglets, filtres, chips)

| Jeton | Valeur | Rôle |
|---|---|---|
| `pillBackground` | `#F2F2F7` | Piste |
| `pillActiveText` | `#000000` | Segment actif |
| `pillInactiveText` | `#AEAEB2` | Segments inactifs |

### Dégradés

| Jeton | Composition | Usage |
|---|---|---|
| `backgroundGradient` | lavande → blanc cassé | **Fond de toutes les pages** (via `AppBackground`) |
| `screenGradient` | lavande → blanc cassé → `#FAFAFA` | Fond d'écran long (héro) |
| `brandGradient` | violet → rose | Logo, CTA de mise en avant |
| `inkGradient` / `inkWash` | `#232326` → `#121214` | Cartes fortes, FAB |

### Accès

```dart
final c = DashColors(context);   // résout clair / sombre automatiquement
c.card, c.fill, c.textPrimary, c.accentPink, c.badgeRed, c.pastelAt(i)…
AppColors.accentPink             // valeur statique (hors widget tree)
```

---

## 2. Typographie — `core/theme/app_text_styles.dart`

Police : **SF Pro Display** (spécification). SF Pro n'étant pas distribuable,
le repli est explicite : `Poppins` → `Inter` → `Roboto` → police système
(sur iOS/macOS, la police système **est** SF Pro).
Pour l'embarquer : déposer les `.ttf` dans `assets/fonts/` et les déclarer dans
`pubspec.yaml` sous la famille `SF Pro Display` — aucun code à modifier.

| Style | Taille / graisse | Usage |
|---|---|---|
| `heading` | 22 / w700 | Titre d'écran, nom de boutique |
| `productTitle` | 14 / w500 | Libellé produit / catégorie |
| `price` | 16 / w700 | Prix, montants |
| `bodySecondary` | 13 / w400 | Texte secondaire, descriptions |
| `pillText` | 12 / w500 | Onglets / pills |
| `display` `h1` `h2` `h3` | 32 / 28 / 22 / 19 | Hiérarchie de base |
| `bodyLarge` `body` `bodySmall` `caption` | 16 / 14 / 13 / 12 | Corps de texte |
| `eyebrow` `subtitle` `sectionTitle` `cardTitle` | 13 / 14.5 / 17 / 15 | En-têtes de section |
| `metric` `amount` `amountSmall` `statValue` | 26 / 15 / 13.5 / 16.5 | Chiffres (chiffres tabulaires) |
| `label` `chip` `overline` `button` `brand` `rating` | 12 / 12 / 11 / 15 / 17 / 13 | Composants |
| `custom(...)` `withColor(...)` | — | Raccourcis hors échelle |

---

## 3. Dimensions — `core/theme/app_dimensions.dart`

```dart
BorderRadius.circular(AppDimensions.radiusSmall)   // 12
BorderRadius.circular(AppDimensions.radiusMedium)  // 16  ← cartes
BorderRadius.circular(AppDimensions.radiusLarge)   // 20  ← cartes premium, nav
BorderRadius.circular(AppDimensions.radiusPill)    // 100 ← pills, boutons
EdgeInsets.all(AppDimensions.paddingM)             // 16
```

| Famille | Jetons |
|---|---|
| Rayons | `radiusSmall` 12 · `radiusMedium` 16 · `radiusLarge` 20 · `radiusPill` 100 · `radiusSheet` 26 |
| Espacements | `paddingXS` 4 · `paddingS` 8 · `paddingM` 16 · `paddingL` 24 · `screenPadding` 20 |
| Ombres | `cardShadow` (5 %, blur 10, y 4) · `softShadow` (3 %, blur 6, y 2) · `floatingShadow` (8 %, blur 20, y 8) · `activePillShadow` (6 %, blur 8, y 2) · `modalShadow` (12 %, blur 28, y 12) |

Source unique : `AppRadius` / `Spacing` / `AppSizes` (`core/constants/app_spacing.dart`)
et `AppShadows` (`core/theme/app_shadows.dart`) — `AppDimensions` ne fait que
les exposer sous les noms de la spécification.

---

## 4. Règles d'application

| Élément | Règle |
|---|---|
| **Fond d'écran** | Dégradé lavande global (`AppBackground` dans `main.dart`) ; `Scaffold` **transparent**, AppBar transparente |
| **Cartes** | Blanc, rayon 16, `cardShadow`, padding 16 |
| **Pills / onglets** | Piste `pillBackground` (h 44), segment actif blanc + ombre + texte noir, inactifs `pillInactiveText` |
| **Badges de notification** | Pastille circulaire `badgeRed`, `Stack` + `Positioned` en haut à droite, texte blanc 10/w700 |
| **Boutons d'action circulaires** | `shape: BoxShape.circle` ou rayon `radiusPill`, fond encre `ink`, icône `onInk` |
| **Boutons pillules** | Hauteur 44–52, rayon `AppRadius.button` (= 100 → pilule), fond encre |
| **Étoiles / rating** | Icône `starYellow` 14 px + `AppTextStyles.bodySecondary` à côté |
| **Icônes pastillées** | Cercle 44–48 px, fond `pastelAt(i)` ou `…Soft`, icône teintée assombrie |
| **Sheets / dialogs** | Rayon 20 (dialog) / 26 (sheet haut), surface `card`, ombre modale |

---

## 5. Thème global — `core/theme/app_theme.dart`

`buildAppTheme(isDark)` configure : `ColorScheme` complet, typographie,
boutons (pilules), champs, chips (pilules), snackbars, dialogs, sheets,
navigation, switch/checkbox, date picker, transitions de page.

Points clés de la v2 :
* `scaffoldBackgroundColor: Colors.transparent` → le dégradé passe derrière ;
* `appBarTheme.backgroundColor: Colors.transparent` → en-têtes fondus ;
* `fontFamily` + `fontFamilyFallback` (SF Pro → Poppins → Inter → Roboto) ;
* tous les rayons passent par `AppRadius`, toutes les couleurs par `AppColors`.

---

## 6. Composants

* **Socle** : `core/widgets/` — `AppButton`, `AppCard`/`StatCard`/`ActionTile`/`InfoTile`,
  `AppTextField`, `AppDialog`/`AppSheet`, `EmptyState`, `Shimmer`, `AppBottomNav`,
  `AppHeader`, `PressableScale`/`AppBadge`/`SoftChip`/`StatusPill`/`SectionHeader`/`OverlineLabel`,
  `AppBackground`.
* **Design system applicatif** : `widgets/` — `AppGreetingHeader`, `CustomTabBar`,
  `FloatingBottomNavBar`, `CategoryCard`/`CategoryGrid`, `GradientInfoCard`,
  `ChatFab`, `PrimaryButton`/`RoundActionButton`, `SearchBarWidget`,
  `ServiceListTile`, `ProfileHeaderCard`, `AppointmentCard`, `FloatingPriceTag`,
  `FloatingRatingCard`, `BouTikaLoader`.

Tous conservent leur **API d'origine** (mêmes paramètres, mêmes callbacks) :
la v2 change l'apparence, jamais les contrats.
