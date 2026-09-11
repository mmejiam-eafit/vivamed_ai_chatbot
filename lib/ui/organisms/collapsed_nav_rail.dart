import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/atoms/app_icon.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/focus_ring.dart';

/// The 64px collapsed nav rail ChatTemplate's medium tier uses in place of
/// the full 240px sidebar (DT §9.5) — a trigger strip, not a re-rendering of
/// the conversation list: neither document specifies icon-only content for
/// an arbitrary-length conversation list, so this opens the existing,
/// unmodified `ConversationDrawer`/findings panel as overlays instead of
/// inventing a second, icon-only rendering of either.
class CollapsedNavRail extends StatelessWidget {
  const CollapsedNavRail({
    super.key,
    required this.onMenuTap,
    this.onFindingsTap,
  });

  final VoidCallback onMenuTap;
  final VoidCallback? onFindingsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: NavigationTokens.sideNavCollapsedWidth,
      color: NavigationTokens.sideNavBackground(context),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          _RailIcon(
            icon: Icons.menu,
            tooltip: 'Conversations',
            onTap: onMenuTap,
          ),
          if (onFindingsTap != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _RailIcon(
              icon: Icons.assignment_outlined,
              tooltip: 'Findings',
              onTap: onFindingsTap!,
            ),
          ],
        ],
      ),
    );
  }
}

class _RailIcon extends StatelessWidget {
  const _RailIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: AppInteraction.minTouchTarget,
          minHeight: AppInteraction.minTouchTarget,
        ),
        child: FocusRing(
          borderRadius: BorderRadius.circular(
            NavigationTokens.sideNavItemBorderRadius +
                AppInteraction.focusRingOffset,
          ),
          child: InkWell(
            onTap: onTap,
            hoverColor: NavigationTokens.sideNavHoverColor,
            borderRadius:
                BorderRadius.circular(NavigationTokens.sideNavItemBorderRadius),
            child: Center(
              child: AppIcon(
                icon,
                color: NavigationTokens.sideNavUnselected(context),
                size: 24.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
