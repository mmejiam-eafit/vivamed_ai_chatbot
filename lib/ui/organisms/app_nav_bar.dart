import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

/// The app's bottom navigation — Chat / Studies / Settings. Built on Flutter's
/// own `NavigationBar`/`NavigationDestination` rather than a hand-rolled row of
/// `NavItem`s: three destinations with a filled/outline icon swap per selection
/// is exactly what `NavigationDestination.icon`/`.selectedIcon` already do.
class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

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

@Preview(name: 'chat selected', size: Size(390, 72), wrapper: previewWrapper)
Widget previewAppNavBarChat() => AppNavBar(
      selectedIndex: 0,
      onDestinationSelected: (_) {},
    );

@Preview(name: 'studies selected', size: Size(390, 72), wrapper: previewWrapper)
Widget previewAppNavBarStudies() => AppNavBar(
      selectedIndex: 1,
      onDestinationSelected: (_) {},
    );

@Preview(name: 'settings selected', size: Size(390, 72), wrapper: previewWrapper)
Widget previewAppNavBarSettings() => AppNavBar(
      selectedIndex: 2,
      onDestinationSelected: (_) {},
    );
