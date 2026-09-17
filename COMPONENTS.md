# 🧩 Composants — Référence API

Tous les composants du design system vivent dans `lib/core/widgets/`.
Ils sont theme-aware (light/dark automatique via `DashColors`), accessibles
(cibles ≥ 48 px) et animés (scale press, transitions).

---

## Boutons — `core/widgets/buttons/app_button.dart`

### AppButton

```dart
AppButton.primary(              // .primary .secondary .soft .danger .ghost
  label: "Valider",
  icon: Icons.check_rounded,    // optionnel
  onPressed: () {},             // null → désactivé (opacity .5)
  background: c.success,        // override couleur (primary/danger)
  foreground: Colors.white,
  softColor: c.successSoft,     // OBLIGATOIRE pour .soft
  height: 52,                   // AppSizes.buttonHeight ; ghost = 44
  expand: true,                 // false → largeur intrinsèque
  fontSize: 15,
  isLoading: false,             // → BouTikaLoader.compact + désactivé
)
```

- Radius 12, élévation 0, scale **0.98** au press + haptic.
- Label : 15 / SemiBold / uppercase via style.

### AppIconButton

```dart
AppIconButton(icon: Icons.refresh_rounded, tooltip: "Actualiser",
              onTap: …, badge: 3, badgeColor: c.danger, size: 44)
```

### AppBackButton — bouton retour standard (`maybePop`).

## Champs — `core/widgets/inputs/app_text_field.dart`

### AppTextField — hauteur 56, radius 12, focus glow

```dart
AppTextField(
  controller: ctrl, initialValue: "…", label: "Nom du produit",
  hint: "Ex: Savon", icon: Icons.inventory_2_outlined,
  obscure: false, suffix: IconButton(…),           // œil mot de passe
  validator: (v) => v!.isEmpty ? "Champ requis" : null,
  onChanged: (v) => …, textInputAction: TextInputAction.next,
  keyboardType: TextInputType.number, enabled: true, maxLines: 1,
)
```

### AppSearchField — recherche avec bouton d'effacement intégré.

### FilterDateChip — chip de date compacte (label + valeur + croix d'effacement).

```dart
FilterDateChip(label: "Date début", date: startDate,
               onTap: () => pickDate(), onClear: () => clear())
```

## Cartes — `core/widgets/cards/app_card.dart`

| Widget | Usage |
|---|---|
| `AppCard` | Conteneur standard (radius 16, ombre douce, bordure). `.outlined` / `.filled`, `onTap` → PressableScale, `padding` personnalisable |
| `StatCard` | KPI compact : `icon, label, value, color, softColor` |
| `ActionTile` | Ligne d'action : `icon, title, subtitle?, badge?, trailing?` |
| `InfoTile` | Ligne d'information en lecture seule |

## États — `core/widgets/lists/empty_state.dart`

```dart
EmptyState(icon: Icons.receipt_long_rounded,
           title: "Aucune commande",
           message: "…",                       // contextuel, jamais ignoré
           actionLabel: "Actualiser", onAction: …,
           iconColor: c.primary, iconSoftColor: c.primarySoft)  // optionnels

ErrorState(message: "…", onRetry: …)
InfoCallout(icon: …, text: "…", color: c.danger, softColor: c.dangerSoft)
```

## Chargement — `core/widgets/loading/shimmer.dart`

`ShimmerBox(width, height, radius)` · `ListRowSkeleton` · `ListSkeleton` ·
`StatGridSkeleton` · `AppSpinner`.
Skeletons pour écrans pleine page ; `AppButton(isLoading: true)` pour les actions.

## Dialogs & Sheets — `core/widgets/dialogs/app_dialog.dart`

```dart
AppDialog.show(context,
  icon: Icons.delete_forever_rounded,
  iconColor: c.danger, iconSoft: c.dangerSoft,   // ou customTitle:
  title: "Supprimer le produit ?",
  message: "Cette action est irréversible.",
  content: Widget?,                              // formulaire, etc.
  actions: [ AppButton.secondary(…), AppButton.danger(…) ],
)
// blur 4 + scale .92→1 + radius 20

AppSheet.show(context, title: "Choisir un employé",
              builder: (ctx) => …, maxHeightFactor: .85)
```

Convention actions : `Row` avec `Expanded` + `SizedBox(width: 10)`.

## Navigation — `core/widgets/navigation/`

- `AppScreenHeader(title, subtitle?, actions?)` — en-tête 64 px standard (titre 20/SemiBold + actions à droite).
- `AppBrandMark` — logo BouTiKa pilule.
- `AppBottomNav(items: [AppBottomNavItem(icon, label)], currentIndex, onTap, badges: {1: 3})` — barre 68 px, indicateur pilule, point rouge danger pour les badges.

## Primitives — `core/widgets/common/primitives.dart`

| Widget | Usage |
|---|---|
| `PressableScale(onTap, onLongPress, pressedScale: .98)` | Wrapper tactile universel |
| `AppBadge(count, color)` | Pastille de compteur |
| `SoftChip(icon, label, color, softColor)` | Puce d'information teintée |
| `StatusPill(label, color, softColor)` | Statut coloré (texte 10.5/w700) |
| `SectionHeader(title, subtitle?, trailing?)` | Titre de section premium |
| `OverlineLabel(text)` | Surtitre 11/w700/letterspacing 1.2 |

## Composants applicatifs (hors core)

| Widget | Fichier | Usage |
|---|---|---|
| `BouTikaLoader` / `.compact` | `lib/widgets/boutika_loader.dart` | Spinner de marque (écrans + boutons) |
| Store card | `lib/widgets/store_item.dart` | Carte de boutique (liste post-login) |

## Constantes — `core/constants/`

- `Spacing.xs…huge` (4→64), `Spacing.screenH`
- `AppRadius.xs(8) sm(10) md(12) mlg(14) lg(16) xl(20) xxl(26) pill(999)`
- `AppSizes.buttonHeight(52) inputHeight(56) appBarHeight(64) bottomNavHeight(68) touchTarget(48)…`
- `AppDurations.instant/fast/normal/medium/slow/page(350ms)/shimmer`
- `AppCurves.standard/entrance/exit/emphasized/press`
