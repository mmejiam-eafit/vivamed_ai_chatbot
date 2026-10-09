import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/nav_item.dart';

/// A narrow persistent column carrying just a "Menu" trigger, for pages with
/// no `ConversationDrawer` to repurpose (Case List, Settings) at
/// `expanded`/`ultrawide` once their app bar is gone. Same 64px width and
/// brand-navy background `CollapsedNavRail` already establishes for an
/// icon-only rail, but a distinct organism: `CollapsedNavRail` opens
/// `ConversationDrawer`/findings overlays specifically for Chat's medium
/// tier, while this always opens `PrimaryNavDrawer` -- different purpose,
/// not a variant of the same one.
class MenuRail extends StatelessWidget {
  const MenuRail({super.key, required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: NavigationTokens.sideNavCollapsedWidth,
      color: NavigationTokens.sideNavBackground(context),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.md,
              ),
              child: NavItem(
                icon: Icons.menu,
                label: 'Menu',
                layout: NavItemLayout.vertical,
                // Never actually selected today (this rail has no notion of
                // an active destination), but sideNavSelected is still the
                // semantically correct pair for this on-brand background.
                selectedColor: NavigationTokens.sideNavSelected(context),
                unselectedColor: context.colors.iconOnBrand,
                onTap: onMenuTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
