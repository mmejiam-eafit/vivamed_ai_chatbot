import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/atoms/app_badge.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

/// The app's bottom navigation — Home / Chat / Studies / Review / Settings.
/// Built on Flutter's own `NavigationBar`/`NavigationDestination` rather than
/// a hand-rolled row of `NavItem`s: five destinations with a filled/outline icon
/// swap per selection is exactly what `NavigationDestination.icon`/
/// `.selectedIcon` already do.
class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.pendingReviewCount,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  /// Images waiting for a radiologist, badged on Review; none at 0.
  /// Required, so a page cannot drop the count by forgetting it.
  final int pendingReviewCount;

  /// The Review icon with its count over the top-right corner, where
  /// Material's `Badge` sits. `AppBadge` rather than `Badge`: Badge's fixed
  /// height clips a count at large text sizes, AppBadge grows with it. On
  /// the warning pair; its digits carry the count (DL D-021).
  Widget _reviewIcon(BuildContext context, IconData icon, Color color) {
    final iconWidget = Icon(icon, color: color);
    if (pendingReviewCount == 0) return iconWidget;
    final colors = context.colors;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        iconWidget,
        PositionedDirectional(
          start: AppSpacing.md,
          top: -AppSpacing.xs,
          child: AppBadge(
            label: '$pendingReviewCount',
            backgroundColor: colors.statusWarningSubdued,
            textColor: colors.statusWarning,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selectedColor = NavigationTokens.bottomNavSelected(context);
    final unselectedColor = NavigationTokens.bottomNavUnselected(context);

    return Container(
      decoration: BoxDecoration(
        color: NavigationTokens.bottomNavBackground(context),
        border: Border(top: BorderSide(color: colors.borderSubdued)),
      ),
      child: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          // The Container above already carries the token background — this
          // stays transparent rather than painting the same color twice.
          backgroundColor: Colors.transparent,
          // No M3 selection pill — matches this bar's existing look, which
          // signals selection through icon/label color alone.
          indicatorColor: Colors.transparent,
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => AppTypography.labelSm.copyWith(
              color: states.contains(WidgetState.selected)
                  ? selectedColor
                  : unselectedColor,
            ),
          ),
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: unselectedColor),
              selectedIcon: Icon(Icons.home, color: selectedColor),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline, color: unselectedColor),
              selectedIcon: Icon(Icons.chat_bubble, color: selectedColor),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.folder_outlined, color: unselectedColor),
              selectedIcon: Icon(Icons.folder, color: selectedColor),
              label: 'Studies',
            ),
            NavigationDestination(
              icon: _reviewIcon(context, Icons.flag_outlined, unselectedColor),
              selectedIcon: _reviewIcon(context, Icons.flag, selectedColor),
              label: 'Review',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: unselectedColor),
              selectedIcon: Icon(Icons.settings, color: selectedColor),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'home selected', size: Size(390, 72), wrapper: previewWrapper)
Widget previewAppNavBarHome() => AppNavBar(
      selectedIndex: 0,
      onDestinationSelected: (_) {},
      pendingReviewCount: 2,
    );

@Preview(name: 'chat selected', size: Size(390, 72), wrapper: previewWrapper)
Widget previewAppNavBarChat() => AppNavBar(
      selectedIndex: 1,
      onDestinationSelected: (_) {},
      pendingReviewCount: 2,
    );

@Preview(name: 'studies selected', size: Size(390, 72), wrapper: previewWrapper)
Widget previewAppNavBarStudies() => AppNavBar(
      selectedIndex: 2,
      onDestinationSelected: (_) {},
      pendingReviewCount: 2,
    );

@Preview(name: 'review selected', size: Size(390, 72), wrapper: previewWrapper)
Widget previewAppNavBarReview() => AppNavBar(
      selectedIndex: 3,
      onDestinationSelected: (_) {},
      pendingReviewCount: 2,
    );

@Preview(name: 'settings selected', size: Size(390, 72), wrapper: previewWrapper)
Widget previewAppNavBarSettings() => AppNavBar(
      selectedIndex: 4,
      onDestinationSelected: (_) {},
      pendingReviewCount: 2,
    );
