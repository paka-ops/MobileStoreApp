# 🛍️ Boutique — nouveau design system de `store_page.dart`

Refonte **100 % visuelle** de la page Boutique (`lib/screens/store_page.dart`),
sans aucune modification de logique métier. Périmètre volontairement **local à
cette page** : les autres écrans (login, dashboards, ventes, abonnements…)
restent strictement identiques.

> **Périmètre demandé** : « créer un nouveau `AppColors` uniquement pour cette
> page ». C'est pourquoi les jetons vivent dans `lib/screens/store/` et non dans
> `lib/core/theme/` (palette partagée par toute l'app).

---

## 1. Fichiers

| Fichier | État | Rôle |
|---|---|---|
| `lib/screens/store_page.dart` | modifié (−189 / +181) | Consomme les nouveaux jetons + widgets refaits |
| `lib/screens/store/store_design.dart` | **nouveau** | `StoreColors`, `StoreTextStyles`, `StoreDimensions`, `StorePalette` |
| `lib/screens/store/store_widgets.dart` | **nouveau** | Widgets refaits (jumeaux) : header, tabs, nav, tuiles, KPI |

`pubspec.yaml` **non modifié** (aucune police ajoutée). `main.dart` et
`core/theme/*` **non modifiés**.

---

## 2. Palette (`StoreColors`)

| Jeton | Valeur | Usage dans la page |
|---|---|---|
| `primaryGradientStart` | `#E8E4F3` | Haut du dégradé de fond (lavande) |
| `primaryGradientEnd` | `#F5F5F7` | Bas du dégradé |
| `backgroundLight` | `#FAFAFA` | Fond du `Scaffold` |
| `cardBackground` | `#FFFFFF` | Cartes, header, nav, sheets |
| `accentPink` | `#E91E8C` | Accent (dépenses, liaisons) |
| `accentPurple` | `#9C27B0` | Primaire de la page (pastilles, actions) |
| `badgeRed` | `#FF3B30` | Pastilles de notification / compteurs |
| `accentGreen` | `#4CAF50` | Validation de vente |
| `textPrimary` | `#1A1A1A` | Titres, valeurs |
| `textSecondary` | `#8E8E93` | Sous-titres |
| `textLight` | `#B0B0B5` | Métadonnées |
| `starYellow` | `#FFC107` | Étoile / alerte (icône « Alertes ») |
| `pillBackground` | `#F2F2F7` | Piste des onglets, puces neutres |
| `pillActiveText` | `#000000` | Onglet actif |
| `pillInactiveText` | `#AEAEB2` | Onglets inactifs, icônes de nav inactives |
| `screenGradient` | lavande → blanc cassé | `Container` de fond (`decoration: BoxDecoration(gradient: …)`) |

**Mode sombre conservé** : `StorePalette` bascule automatiquement (`dark*`) et le
dégradé lavande ne s'applique qu'en thème clair.

---

## 3. Typographie (`StoreTextStyles`)

Famille : **SF Pro Display** (spécification) avec repli
`['Poppins', 'Inter']` + police système — aucune erreur si SF Pro est absente.
Pour l'activer réellement : déposer les `.ttf` dans `assets/fonts/`, les déclarer
dans `pubspec.yaml` sous la famille `SF Pro Display` (aucune modification de code
nécessaire).

| Style | Taille / graisse | Usage |
|---|---|---|
| `heading` | 22 / w700 | Nom de boutique |
| `productTitle` | 14 / w500 | Libellés produits / catégories |
| `price` | 16 / w700 | Montants |
| `bodySecondary` | 13 / w400 | Sous-titres |
| `pillText` | 12 / w500 | Onglets / pastilles |
| `eyebrow`, `name`, `sectionTitle`, `cardTitle`, `metric`, `label`, `overline`, `caption`, `chip`, `button` | déclinaisons | reste de la page |

Aucun `TextStyle()` brut ne subsiste dans la page.

---

## 4. Dimensions (`StoreDimensions`)

* Rayons : `radiusSmall` 12 · `radiusMedium` 16 · `radiusLarge` 20 ·
  `radiusPill` 100 · `radiusSheet` 26 (feuilles bas d'écran)
* Espacements : `paddingXS/S/M/L` = 4 / 8 / 16 / 24 · `screenPadding` = 20
* Ombres : `cardShadow` (5 %, blur 10, y 4) · `softShadow` (3 %, blur 6, y 2) ·
  `floatingShadow` · `activePillShadow`

Correspondance appliquée : `10/12 → 12`, `14 → 16`, `20 → 20`, `26 → 26`,
padding de carte `18 → 16`.

---

## 5. Widgets refaits (jumeaux page-scoped)

Les widgets partagés sont **inchangés** (ils servent d'autres écrans, et
`CategoryCard` est aussi utilisée par `category_report_screen.dart`). La page
utilise désormais leurs jumeaux, **mêmes paramètres, mêmes callbacks, même
structure de layout**, seuls les jetons changent :

| Avant (partagé) | Après (page Boutique) |
|---|---|
| `AppGreetingHeader` | `StoreGreetingHeader` (bloc gauche identique ; cloche ronde blanche + **pastille circulaire `badgeRed`** en haut à droite) |
| `CustomTabBar` (underline) | `StoreTabBar` (onglets **pills** : piste `pillBackground`, segment actif blanc + ombre) |
| `FloatingBottomNavBar` | `StoreBottomNav` + `StoreNavItem` (barre blanche rayon 20, pastille active, badge `badgeRed`) |
| `CategoryCard` / `CategoryGrid` | `StoreCategoryCard` / `StoreCategoryGrid` (rayon 16, ombre douce, badge circulaire rouge) |
| `GradientInfoCard` (KPI) | `StoreKpiCard` (rayon 16, padding 16, icône pastillée, valeur 26/w700) |

Détails de la page :

* **Fond** : `Scaffold` → `Container(decoration: BoxDecoration(gradient: …))`
  (écran d'attente compris).
* **Boutons d'action « + »** : pilule encre (`textPrimary`) + icône claire
  (« Ajouter une catégorie », bouton circulaire « Ajouter » de l'équipe).
* **Cartes de section** : rayon 16, padding 16, `cardShadow`.
* Dialogs / feuilles : rayons passés aux jetons `StoreDimensions`
  (20 → `radiusLarge`, 26 → `radiusSheet`) ; **structure et actions inchangées**.

---

## 6. Ce qui n'a PAS changé (garanties vérifiées)

| Contrôle | Résultat |
|---|---|
| Lignes contenant de la logique (`await`, `Service(`, `setState`, `Navigator.`, `onPressed`, `try/catch`, controllers…) | **242 / 242 identiques** — aucun diff |
| Libellés & chaînes affichées | **144 / 144 identiques** |
| Signatures / noms de variables, callbacks, destinations de navigation | inchangés |
| Autres écrans et widgets partagés | **aucune modification** (`git status` : seul `store_page.dart` + `lib/screens/store/`) |
| `pubspec.yaml`, `main.dart`, `core/theme/*` | non modifiés |
| Barre de recherche vocale / IA | **inexistante dans le code** — rien à supprimer |
| Bouton « Vendre » (`ChatFab.labeled`) | **conservé** (il porte le flux de vente) |

---

## 7. Vérifications effectuées & limite

Effectué ici : équilibrage syntaxique des 3 fichiers, résolution de **tous** les
jetons utilisés (`StoreTextStyles`, `StoreDimensions`, `StoreColors`,
`StorePalette`, widgets), contrôle des paramètres de constructeurs, imports
tous utilisés, diff de logique vide, libellés identiques.

⚠️ **Limite** : l'environnement d'exécution n'a ni Flutter ni Dart SDK (et
`pub.dev` est inaccessible), donc `flutter analyze` / `flutter run` n'ont pas pu
être lancés. À faire en local pour la validation finale :

```bash
flutter analyze
flutter run        # puis vérifier l'écran Boutique en clair ET en sombre
```

---

## 8. Revenir en arrière

* Page seule : `git checkout HEAD~1 -- lib/screens/store_page.dart`
* Tout annuler : supprimer `lib/screens/store/` et restaurer `store_page.dart`
  (les widgets partagés n'ont jamais été touchés).
