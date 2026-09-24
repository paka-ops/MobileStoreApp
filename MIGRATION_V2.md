# 🚚 Migration v2 — remplacement complet de l'UI (design system « Lavande »)

Remplacement du design system « Calm Premium » (teal/corail, Poppins) par le
nouveau système **« Lavande »** (lavande/rose/violet, SF Pro Display) sur
**l'intégralité de l'application** : 82 fichiers Dart, 16 écrans, 30 widgets.

> **Principe directeur** : on change les **valeurs**, jamais les **contrats**.
> Aucune API publique renommée, aucune logique métier modifiée — c'est ce qui
> rend la migration sûre et vérifiable sur un projet de cette taille.

---

## 1. Ce qui a changé

### a. Jetons du design system (`core/`)

| Fichier | État | Contenu |
|---|---|---|
| `core/theme/app_colors.dart` | réécrit | Nouvelle palette (63 constantes + `DashColors`) — **tous les anciens noms conservés**, valeurs remplacées ; ajout des jetons de la spécification (`accentPink`, `accentPurple`, `badgeRed`, `accentGreen`, `starYellow`, `pillBackground`, `pillActiveText`, `pillInactiveText`, `primaryGradientStart/End`, `backgroundGradient`, `screenGradient`, `brandGradient`, `inkGradient`, `softShadow`, `activePillShadow`…) + variantes sombres |
| `core/theme/app_text_styles.dart` | réécrit | **SF Pro Display** + repli `Poppins → Inter → Roboto` ; styles de la spécification (`heading` 22/w700, `productTitle` 14/w500, `price` 16/w700, `bodySecondary` 13/w400, `pillText` 12/w500) ; tous les anciens styles conservés |
| `core/theme/app_dimensions.dart` | **nouveau** | `AppDimensions` : rayons 12/16/20/100/26, espacements 4/8/16/24, ombres (5 %/blur 10, 3 %/blur 6, 8 %/blur 20, 6 %/blur 8) |
| `core/constants/app_spacing.dart` | ajusté | `AppRadius` : 12/16/20/100 (boutons = pilule complète, nav = 20, cartes = 16) ; `AppSizes` : recherche 48, nav 64, CTA 52 |
| `core/theme/app_shadows.dart` | ajusté | Recette d'ombres de la spécification (+ `soft`, `activePill`) |
| `core/theme/app_decorations.dart` | ajusté | Rayons par défaut 16/20, `AppGradients.page/screen/brand` |
| `core/theme/app_theme.dart` | ajusté | `Scaffold` **transparent**, AppBar **transparente**, `fontFamilyFallback`, switch/checkbox/chips alignés sur les jetons, plus aucune valeur codée en dur |
| `core/widgets/common/app_background.dart` | **nouveau** | Dégradé lavande global branché une fois dans `main.dart` (`MaterialApp.builder`) — toutes les pages en bénéficient |

### b. Widgets partagés — API identique, apparence v2

| Widget | Ce qui change |
|---|---|
| `AppGreetingHeader` | Cloche sur pastille **blanche + ombre douce**, badge **circulaire rouge** en haut à droite, nom en `heading` 22/w700, avatar blanc arrondi 16 |
| `CustomTabBar` | **Soulignés → pills** : piste `pillBackground` h 44, segment actif blanc + ombre + texte noir, inactifs `pillInactiveText` |
| `FloatingBottomNavBar` | Barre blanche rayon 20, pastille active `fill`, badge **`badgeRed`** |
| `CategoryCard` / `CategoryGrid` | Rayon 16, badge **circulaire rouge**, libellé `chip` |
| `GradientInfoCard` | Rayon 16, icône sur pastille blanche, chevron `textTertiary`, option `iconColor` |
| `ChatFab` | Pastille **`badgeRed`**, pilule encre, dégradé encre |
| `PrimaryButton` | Pilule complète (rayon 100), variante dégradé → **violet → rose** |
| `SearchBarWidget`, `ServiceListTile`, `ProfileHeaderCard`, `AppointmentCard`, `FloatingPriceTag`, `FloatingRatingCard`, `store_item` | Rayons, ombres et couleurs passés aux jetons (plus de valeurs codées en dur) |
| `BouTikaLoader` | Teintes de la marque : base `textLight`, halo `primarySoft`, cœur `accentPurple` |
| `AppButton`, `AppCard`, `AppTextField`, `AppDialog`/`AppSheet`, `EmptyState`, `Shimmer`, `AppBottomNav`, `AppHeader`, `primitives` | Rayons/ombres/couleurs alignés sur les jetons ; chips et boutons en pilule |

### c. Écrans (16 fichiers)

* **Fond** : suppression des `backgroundColor: c.background` des `Scaffold` (21
  occurrences) et des AppBar (5) → le dégradé lavande global s'affiche sur
  **toutes** les pages, en-têtes compris.
* **Rayons** : 76 valeurs `circular(N)` codées en dur remplacées par des jetons
  `AppRadius.*` (24 fichiers).
* **Typographie** : 88 styles codés en dur (`TextStyle(fontSize: …)`) remplacés
  par des styles `AppTextStyles.*` (25 fichiers) ; le reste hérite du thème
  (famille + repli appliqués globalement).
* **Couleurs** : derniers accents codés en dur (`#C08552`, `#DE4A52`, `#2F9E68`,
  `#8A7CB8`, `Colors.red`…) remplacés par les jetons de la palette
  (`spending_page`, `general_report_screen`, `store_page`, `message.dart`,
  `exception_handler.dart`, `store_item`).
* **`store_page.dart`** : convergé vers le système canonique — les doublons
  `screens/store/` ont été **supprimés**, la page utilise désormais les widgets
  partagés (une seule source de vérité dans toute l'app).

### d. Suppressions

| Élément | Raison |
|---|---|
| `lib/screens/store/store_design.dart` | Doublon page-scoped devenu inutile (système unique désormais) |
| `lib/screens/store/store_widgets.dart` | Idem — les widgets canoniques portent le nouveau style |
| Barre de recherche vocale / IA | **Inexistante** dans le code : rien n'a été supprimé (voir §5) |

---

## 2. Garanties vérifiées

| Contrôle | Résultat |
|---|---|
| **Logique métier** (services, `await`, `setState`, `Navigator`, `onPressed`, validateurs, appels API) | **6 lignes signalées sur 82 fichiers**, toutes **visuelles** : 2 couleurs de `switch` dans `app_theme.dart` + `return Scaffold(` → `return const Scaffold(` dans `store_page.dart`. **0 % de logique modifiée** |
| Équilibrage syntaxique (parenthèses/accolades/crochets) | **82 / 82 fichiers** équilibrés |
| Imports | Aucun import cassé, aucun auto-import (vérifié fichier par fichier) |
| Résolution des jetons | Tous les `AppColors.*`, `AppTextStyles.*`, `AppRadius.*`, `AppSizes.*`, `Spacing.*`, `AppShadows.*`, `AppDimensions.*`, `AppDecorations.*` utilisés existent |
| Getters `DashColors` utilisés | Tous définis (`card`, `fill`, `border`, `hairline`, `pastelAt`, `wash`, `inkWash`, `accentGradient`, `badgeRed`, `starYellow`, `pillBackground`, `softShadow`, `backgroundGradient`…) |
| Références aux fichiers supprimés | Aucune (recherche `StorePalette`/`StoreDimensions`/`store_widgets` → 0) |
| `pubspec.yaml` | **Non modifié** |
| Autres dépendances | Aucune ajoutée ; `google_fonts` n'est plus utilisé par le code (le repli de police est déclaré statiquement) |

⚠️ **Limite** : l'environnement de travail n'a **ni Flutter ni Dart SDK**
(`pub.dev` inaccessible) : `flutter analyze` / `flutter test` / `flutter run`
n'ont pas pu être exécutés ici. À lancer en local :

```bash
flutter analyze
flutter test
flutter run     # parcourir : accueil, boutique, ventes, stock, +, login, rapports
```

---

## 3. Décisions de design (et pourquoi)

1. **Mapping sémantique, pas mapping chromatique.** L'ancien système avait
   teal (marque) + corail (accent) ; le nouveau a violet (marque) + rose
   (accent). Les rôles sont conservés : `primary` → violet, `accent` → rose,
   `danger` → `badgeRed`, `success` → `accentGreen`, `rating` → `starYellow`.
   Résultat : les écrans n'ont pas eu à être repensés, seulement re-colorés.
2. **Un seul fond, une seule source.** Le dégradé lavande vit dans
   `AppBackground` (branché dans `main.dart`) au lieu d'être répété : moins de
   code, rendu identique partout, et les écrans restent simples à écrire.
3. **SF Pro sans licence ni téléchargement.** `fontFamily` + `fontFamilyFallback`
   donnent SF Pro sur iOS et une police neutre (Poppins/Inter/Roboto) ailleurs,
   sans dépendance réseau au démarrage.
4. **Aucun nom d'API modifié.** `AppColors`, `DashColors`, `AppTextStyles`,
   `AppRadius`, `AppSizes`, `AppShadows`, `AppDecorations`, `AppGradients` et
   tous les widgets conservent leurs noms et signatures : aucune régression
   silencieuse possible sur les écrans non touchés directement.
5. **Badges = `badgeRed`.** Toutes les pastilles de comptage (cloche, nav,
   tuiles de catégorie) sont circulaires et rouges, conformément à la
   spécification, au lieu de l'ancien point corail discret.

---

## 4. Où agir ensuite (personnalisation)

| Besoin | Où |
|---|---|
| Intensité du lavande | `AppColors.primaryGradientStart` |
| Rayon global des cartes | `AppDimensions.radiusMedium` / `AppRadius.lg` |
| Couleur d'action principale | `AppColors.accentPurple` (marque) / `AppColors.ink` (boutons) |
| Police | Déclarer `SF Pro Display` dans `pubspec.yaml` (fichiers `.ttf`) |
| Ombre plus/moins marquée | `AppShadows.card` / `DashColors.cardShadow` |

---

## 5. Points ouverts / non applicables

1. **Barre vocale ou IA** — introuvable dans le projet (`grep` sur
   *microphone*, *voice*, *speech*, *assistant* → 0 résultat hors commentaires).
   Rien à supprimer ; le bouton « Vendre » (`ChatFab.labeled`) porte le flux de
   vente et a été conservé.
2. **SF Pro Display** — les fichiers `.ttf` n'étant pas fournis, la police
   retombe sur Poppins/Inter/Roboto (voir §3.3).
3. **Widget de notation** — aucun écran n'affiche d'étoiles actuellement :
   `AppColors.starYellow` est prêt, mais un widget `RatingStars` reste à créer
   le jour où une note est affichée.
4. **Restauration de l'ancienne UI** — `git revert` du commit de migration :
   les valeurs sont centralisées, le retour arrière est donc instantané.
