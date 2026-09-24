# 🌈 Palette — BouTiKa (design system « Lavande » v2)

Toutes les couleurs vivent dans `lib/core/theme/app_colors.dart`.
**Règle d'or** : jamais de `Colors.black` / `Colors.white` en surface ou texte —
toujours passer par `DashColors` (ou `AppColors` pour du statique).

```dart
final c = DashColors(context);   // résout clair/sombre selon le thème courant
c.accentPink; c.accentPurple; c.badgeRed; c.card; c.textPrimary; c.pastelAt(2); …
```

## 1. Fond, surfaces, traits

| Token | Light | Dark | Usage |
|---|---|---|---|
| `primaryGradientStart` | `#E8E4F3` | `#1B1826` | Haut du dégradé de fond (lavande) |
| `primaryGradientEnd` | `#F5F5F7` | `#121214` | Bas du dégradé |
| `background` / `backgroundLight` | `#FAFAFA` | `#121214` | Fond général |
| `card` / `cardBackground` | `#FFFFFF` | `#1C1C1E` | Cartes, sheets, barres |
| `fill` / `pillBackground` | `#F2F2F7` | `#2C2C2E` | Zones remplies, piste des pills |
| `fillStrong` | `#E8E8ED` | `#3A3A3C` | Remplissage appuyé, états désactivés |
| `border` | `#E5E5EA` | `#38383A` | Traits visibles |
| `hairline` / `divider` | `#EFEFF3` | `#2C2C2E` | Séparateurs doux |

## 2. Textes & encre

| Token | Light | Dark | Usage |
|---|---|---|---|
| `textPrimary` / `textDark` | `#1A1A1A` | `#F2F2F7` | Titres, valeurs, corps |
| `textSecondary` / `textGrey` | `#8E8E93` | `#9A9AA1` | Sous-titres, métadonnées |
| `textLight` / `textTertiary` | `#B0B0B5` | `#6E6E73` | Labels discrets, hints |
| `ink` | `#1A1A1A` | `#F2F2F7` | Boutons pillules, icônes actives |
| `onInk` | `#FFFFFF` | `#1A1A1A` | Contenu posé sur l'encre |

## 3. Accents & sémantiques

| Token | Light | Dark | Fond associé | Usage |
|---|---|---|---|---|
| `accentPink` (`accent`) | `#E91E8C` | `#FF6FB5` | `accentSoft` `#FDEBF5` | Accent principal |
| `accentPurple` (`primary`) | `#9C27B0` | `#CE93D8` | `primarySoft` `#F4E9F7` | Marque, focus, progression |
| `badgeRed` (`danger`) | `#FF3B30` | `#FF6B61` | `dangerSoft` `#FFEBEA` | Badges, suppressions |
| `accentGreen` (`success`) | `#4CAF50` | `#81C784` | `successSoft` `#E8F5E9` | Validations |
| `starYellow` (`rating`) | `#FFC107` | `#FFD54F` | `ratingSoft` `#FFF7E0` | Étoiles / notes |
| `warning` | `#FF9F0A` | `#FFB74D` | `warningSoft` `#FFF3E0` | Alertes douces |
| `info` | `#5E5CE6` | `#9FA8FF` | `infoSoft` `#EAE9FD` | Informations |

## 4. Pills & dégradés

| Token | Valeur | Usage |
|---|---|---|
| `pillBackground` | `#F2F2F7` | Piste des onglets / filtres |
| `pillActiveText` | `#000000` | Segment actif |
| `pillInactiveText` | `#AEAEB2` | Segments inactifs |
| `backgroundGradient` | lavande → blanc cassé | Fond de **toutes** les pages |
| `screenGradient` | lavande → blanc cassé → `#FAFAFA` | Fond d'écran long |
| `brandGradient` | violet → rose | Logo, CTA de mise en avant |
| `inkGradient` / `inkWash` | `#232326` → `#121214` | Cartes fortes, FAB |

## 5. Pastels (fonds d'icônes, cyclage `pastelAt(i)`)

`pastelViolet #F4E9F7` · `pastelPeach #FDEBF5` · `pastelMint #E8F5E9` ·
`pastelSand #FFF7E0` · `pastelBlue #E8F0FE` · `pastelLavender #E8E4F3` ·
`pastelRose #FFEBEA` · `pastelGrey #F2F2F7`

## 6. Ombres (`AppShadows` / `DashColors`)

| Token | Recette | Usage |
|---|---|---|
| `cardShadow` | `0x0D000000` · blur 10 · y 4 | Cartes |
| `softShadow` | `0x08000000` · blur 6 · y 2 | Pills actives, petits éléments |
| `floatingShadow` | `0x14000000` · blur 20 · y 8 | Nav, FAB, tags |
| `activePillShadow` | `0x0F000000` · blur 8 · y 2 | Segments actifs |
| `modalShadow` | `0x1F000000` · blur 28 · y 12 | Dialogs, modales |
