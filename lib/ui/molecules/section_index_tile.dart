import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

/// One row of a title index — a list of section names beside their content,
/// as in `SettingsTemplate`'s expanded-tier layout. Highlights when selected
/// and reports taps; the caller owns which index is selected.
class SectionIndexTile extends StatelessWidget {
  const SectionIndexTile({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected ? colors.surfaceSubdued : null,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: AppText(
          title,
          style: AppTypography.labelMd,
          color: isSelected ? colors.interactivePrimary : colors.textPrimary,
        ),
      ),
    );
  }
}
