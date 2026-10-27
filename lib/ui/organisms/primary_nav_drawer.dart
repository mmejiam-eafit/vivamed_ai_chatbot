import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/nav_item.dart';

/// Primary app navigation (Home/Chat/Studies/Review/Settings) at `expanded`/
/// `ultrawide`, opened via the app bar's own automatic hamburger once a
/// template wires this into `Scaffold.drawer` -- no manual `IconButton`
/// needed, Flutter shows a `DrawerButton` whenever `Scaffold.drawer != null`.
/// Distinct from `ConversationDrawer` (conversation history, Chat/Study
/// Review only): this is the same five destinations `AppNavBar` renders as a
/// bottom bar at narrower tiers, just as a drawer instead.
class PrimaryNavDrawer extends StatelessWidget {
  const PrimaryNavDrawer({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  /// Null on drill-down pages (e.g. Study Review) that aren't any of the 4
  /// destinations themselves -- nothing shows as selected.
  final int? selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  static const _destinations = [
    (icon: Icons.home_outlined, label: 'Home'),
    (icon: Icons.chat_bubble_outline, label: 'Chat'),
    (icon: Icons.folder_outlined, label: 'Studies'),
    (icon: Icons.flag_outlined, label: 'Review'),
    (icon: Icons.settings_outlined, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: NavigationTokens.sideNavWidth,
      backgroundColor: NavigationTokens.drawerBackground(context),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            for (final (i, destination) in _destinations.indexed)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                child: NavItem(
                  icon: destination.icon,
                  label: destination.label,
                  layout: NavItemLayout.horizontal,
                  isSelected: i == selectedIndex,
                  // This drawer's background is surfaceBrandSecondary, not
                  // AppNavBar's surface -- same on-brand fix already applied
                  // to ConversationDrawer's own Settings entry. sideNavSelected,
                  // not bottomNavSelected: this is a side-nav drawer, not a
                  // bottom bar -- NavItem no longer has a default to fall back
                  // to, so this is the fix, not just an override.
                  selectedColor: NavigationTokens.sideNavSelected(context),
                  unselectedColor: context.colors.iconOnBrand,
                  onTap: () => onDestinationSelected(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
