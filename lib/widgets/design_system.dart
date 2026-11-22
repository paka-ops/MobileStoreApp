// ============================================================================
// BOUTIKA — DESIGN SYSTEM (barrel de compatibilité)
//
// Les composants vivent désormais dans `lib/shared/widgets/` (kit partagé).
// Ce barrel conserve exactement la même surface publique qu'auparavant, afin
// qu'aucun écran n'ait à changer d'import pendant la migration.
//
// ➜ Nouveau code : import 'package:mobile_store_app/shared/widgets/ui_kit.dart';
// ============================================================================

export '../shared/widgets/cards/appointment_card.dart' show AppointmentCard;
export '../shared/widgets/cards/category_card.dart' show CategoryCard, CategoryGrid;
export '../shared/widgets/buttons/chat_fab.dart' show ChatFab;
export '../shared/widgets/navigation/floating_bottom_nav_bar.dart'
    show FloatingBottomNavBar, FloatingNavItem;
export '../shared/widgets/navigation/custom_tab_bar.dart'
    show CustomTabBar, CustomTabItem;
export '../shared/widgets/cards/floating_price_tag.dart' show FloatingPriceTag;
export '../shared/widgets/cards/floating_rating_card.dart' show FloatingRatingCard;
export '../shared/widgets/cards/gradient_info_card.dart'
    show GradientInfoCard, GradientCardChip;
export '../shared/widgets/navigation/greeting_header.dart' show AppGreetingHeader;
export '../shared/widgets/buttons/primary_button.dart' show PrimaryButton;
export '../shared/widgets/buttons/round_action_button.dart' show RoundActionButton;
export '../shared/widgets/cards/profile_header_card.dart'
    show ProfileHeaderCard, ProfileStat;
export '../shared/widgets/inputs/search_bar_widget.dart' show SearchBarWidget;
export '../shared/widgets/lists/service_list_tile.dart' show ServiceListTile;
