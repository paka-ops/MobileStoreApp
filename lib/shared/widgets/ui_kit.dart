// ============================================================================
// BOUTIKA — UI KIT (barrel du kit partagé)
//
// Import unique pour tous les composants visuels réutilisables qui ne sont pas
// des primitives du socle (`core/widgets/`) :
//
//   import 'package:mobile_store_app/shared/widgets/ui_kit.dart';
//
// ⚠️ Ces widgets sont 100 % présentation : ils reçoivent leurs données et
//    leurs callbacks de l'écran parent, aucune logique métier n'y vit.
// ============================================================================

export 'buttons/chat_fab.dart' show ChatFab;
export 'buttons/primary_button.dart' show PrimaryButton;
export 'buttons/round_action_button.dart' show RoundActionButton;
export 'cards/appointment_card.dart' show AppointmentCard;
export 'cards/category_card.dart' show CategoryCard, CategoryGrid;
export 'cards/floating_price_tag.dart' show FloatingPriceTag;
export 'cards/floating_rating_card.dart' show FloatingRatingCard;
export 'cards/gradient_info_card.dart' show GradientInfoCard, GradientCardChip;
export 'cards/profile_header_card.dart' show ProfileHeaderCard, ProfileStat;
export 'inputs/search_bar_widget.dart' show SearchBarWidget;
export 'layout/app_brand_header.dart' show AppBrandHeader;
export 'lists/service_list_tile.dart' show ServiceListTile;
export 'loading/boutika_loader.dart' show BouTikaLoader;
export 'navigation/custom_tab_bar.dart' show CustomTabBar, CustomTabItem;
export 'navigation/floating_bottom_nav_bar.dart'
    show FloatingBottomNavBar, FloatingNavItem;
export 'navigation/greeting_header.dart' show AppGreetingHeader;
