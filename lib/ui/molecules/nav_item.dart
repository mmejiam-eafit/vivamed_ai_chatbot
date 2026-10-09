import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/atoms/app_icon.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/focus_ring.dart';

/// Layout used by [NavItem].
///
/// [vertical] stacks icon above label — suited for a mobile bottom navigation bar.
/// [horizontal] places icon and label side-by-side — suited for a web/desktop sidebar.
enum NavItemLayout { vertical, horizontal }

class NavItem extends StatelessWidget {
  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selectedColor,
    required this.unselectedColor,
    this.isSelected = false,
    this.onTap,
    this.layout = NavItemLayout.vertical,
    this.focusNode,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final NavItemLayout layout;
  final FocusNode? focusNode;

  /// Resolved color for the selected/unselected state. No default: every real
  /// caller (`ConversationDrawer`, `MenuRail`, `PrimaryNavDrawer`) sits on its
  /// own brand-dark background and needs its own token pair anyway, so a
  /// shared `NavigationTokens.bottomNav*` fallback had nothing left relying on
  /// it except by omission -- which is exactly how `PrimaryNavDrawer` ended up
  /// resolving its selected color through the wrong semantic token
  /// (`bottomNavSelected` instead of `sideNavSelected`) without anyone
  /// choosing to. Required, no-default parameters make that a compile error
  /// instead of a silent wrong-token fallback.
  final Color selectedColor;
  final Color unselectedColor;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? selectedColor : unselectedColor;

    final iconWidget = AppIcon(icon, color: color, size: 24.0);
    final labelWidget = AppText(label, style: AppTypography.labelSm, color: color);

    final child = switch (layout) {
      NavItemLayout.horizontal => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            const SizedBox(width: AppSpacing.sm),
            labelWidget,
          ],
        ),
      NavItemLayout.vertical => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            const SizedBox(height: AppSpacing.xxs),
            labelWidget,
          ],
        ),
    };

    return ConstrainedBox(
      // 44px floor in every direction (DL §8.5) — neither layout's natural
      // padding+content reliably clears it (the horizontal layout's height
      // is ~40px), so this wraps the whole tappable area rather than relying
      // on padding tuning per layout.
      constraints: const BoxConstraints(
        minWidth: AppInteraction.minTouchTarget,
        minHeight: AppInteraction.minTouchTarget,
      ),
      child: FocusRing(
        // The ring sits outside the control by focusRingOffset, so its own
        // radius grows by the same amount — mirrors AppButton's ring (DL §8.4).
        borderRadius: BorderRadius.circular(
          AppRadius.button + AppInteraction.focusRingOffset,
        ),
        child: InkWell(
          onTap: onTap,
          focusNode: focusNode,
          hoverColor: color.withValues(alpha: AppInteraction.hoverOverlayOpacity),
          borderRadius: AppRadius.borderButton,
          child: Padding(
            padding: layout == NavItemLayout.horizontal
                ? const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  )
                : const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
