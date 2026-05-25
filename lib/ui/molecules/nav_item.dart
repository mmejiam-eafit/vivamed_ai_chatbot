import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/atoms/app_icon.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

class NavItem extends StatelessWidget {
  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? NavigationTokens.bottomNavSelected
        : NavigationTokens.bottomNavUnselected;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderButton,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(icon, color: color, size: 24.0),
            const SizedBox(height: AppSpacing.xxs),
            AppText(label, style: AppTypography.labelSm, color: color),
          ],
        ),
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'unselected', wrapper: previewWrapper)
Widget previewNavItemUnselected() =>
    const NavItem(icon: Icons.chat_bubble_outline, label: 'Chat');

@Preview(name: 'selected', wrapper: previewWrapper)
Widget previewNavItemSelected() =>
    const NavItem(icon: Icons.chat_bubble, label: 'Chat', isSelected: true);

@Preview(name: 'studies — unselected', wrapper: previewWrapper)
Widget previewNavItemStudies() =>
    const NavItem(icon: Icons.folder_outlined, label: 'Studies');
