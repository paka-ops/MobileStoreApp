# 🌈 Palette de couleurs — BouTiKa

Toutes les couleurs vivent dans `lib/core/theme/app_colors.dart`.
**Règle d'or** : jamais de `Colors.black` / `Colors.white` en surface ou texte —
toujours passer par `DashColors` (ou `AppColors` pour du statique).

```dart
final c = DashColors(context);   // résout clair/sombre selon le thème courant
c.primary; c.card; c.textPrimary; c.dangerSoft; …
```

## 1. Couleurs de marque

| Token | Light | Dark | Usage |
|---|---|---|---|
| `primary` | `#3E63DD` | `#8A9EF4` | Boutons, éléments actifs, lien signature |
| `primarySoft` | `#E9EEFE` | `#212A4E` | Fond teinté derrière le primaire |
| `onPrimary` | `#FFFFFF` | `#0D1226` | Texte/icône posés sur le primaire |
| `accent` | `#C08552` | `#D9A876` | Camel chaleureux — dépenses, highlights |
| `accentSoft` | `#F6ECE3` | `#2B2118` | Fond teinté accent |

## 2. Couleurs sémantiques

| Token | Light | Dark | Usage |
|---|---|---|---|
| `success` | `#2F9E68` | `#52C186` | Validations, stock sain, gains |
| `successSoft` | `#E8F6EE` | `#16301F` | Fond teinté succès |
| `danger` | `#DE4A52` | `#F0767D` | Suppression, erreurs, stock critique |
| `dangerSoft` | `#FDEDEE` | `#331D20` | Fond teinté danger |
| `warning` | `#DE911D` | `#EDB24E` | Alertes, stock bas |
| `warningSoft` | `#FDF4E1` | `#2F2611` | Fond teinté alerte |
| `info` | `#4A8DDC` | `#7FB1EA` | Infos, badges neutres |
| `infoSoft` | `#EAF2FB` | `#1A2634` | Fond teinté info |

## 3. Surfaces & textes

| Token | Light | Dark | Usage |
|---|---|---|---|
| `background` | `#F6F7F9` | `#0E1116` | Fond des écrans (jamais blanc/noir pur) |
| `card` | `#FFFFFF` | `#161B22` | Cartes, niveau 1 |
| `cardElevated` | `#FFFFFF` | `#1E242D` | Inputs, zones élevées |
| `border` | `#E7EAEE` | `#272E39` | Bordures 1px |
| `textPrimary` | `#22262D` | `#E9ECF2` | Texte principal (anthracite) |
| `textSecondary` | `#6E7681` | `#8C93A0` | Texte secondaire |

Tokens utilitaires exposés par `DashColors` : `isDark`, `barrier` (voile de
dialog), `shimmerBase`/`shimmerHighlight`, `glow` (focus), `hairline`,
`cardShadow`.

## 4. Couleurs fixées par fonctionnalité (héritage, à ne pas unifier)

Ces couleurs proviennent des écrans d'origine et sont volontairement conservées :

- **Dépenses** : `_accent = #C08552`, `_danger = #DE4A52` (statique, les deux modes).
- **Rapport par catégorie** : cycle de couleurs
  `#4A7C82 · #C08552 · #6FA687 · #8A7CB8 · #D8A657 · #5C8AAE`.
- **Rapport général** : bénéfice employer = `#8A7CB8`.

## 5. Seuils de stock (métier — ne pas unifier)

| Écran | Règle | Labels |
|---|---|---|
| Alertes stock (`get_low_stock_product`) | inclusion si `stock < 10` | — |
| Cartes/alertes | `≤ 5` critique (rouge) · `≤ 15` bas (ambre) · sinon sain (vert) | « Critique » / « Bas » / « Normal » ou « Stock critique » / « Stock bas » / « Stock sain » |
| Gestion catégorie | inclusion alertes si `stock ≤ 10` | — |

## 6. Accessibilité

- Contrastes vérifiés : texte anthracite sur fond gris clair ≥ 12:1 ;
  texte sombre `#E9ECF2` sur `#0E1116` ≥ 13:1.
- États « soft » garantissent un fond teinté peu saturé derrière chaque
  couleur vive → pas de fatigue visuelle en usage prolongé.
