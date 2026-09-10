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

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? NavigationTokens.bottomNavSelected(context)
        : NavigationTokens.bottomNavUnselected(context);

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

    return FocusRing(
      // The ring sits outside the control by focusRingOffset, so its own
      // radius grows by the same amount — mirrors AppButton's ring (DL §8.4).
      borderRadius: BorderRadius.circular(
        AppRadius.button + AppInteraction.focusRingOffset,
      ),
      child: InkWell(
        onTap: onTap,
        focusNode: focusNode,
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
          child: child,
        ),
      ),
    );
  }
}
