import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

/// One row of a title index — a list of section names beside their content,
/// as in `SettingsTemplate`'s expanded-tier layout. Highlights when selected
/// and reports taps; the caller owns which index is selected. Built on
/// Flutter's own `ListTile` (`selected` + `selectedTileColor` are exactly a
/// tappable row's highlight-when-selected fill) rather than a hand-rolled
/// `InkWell` + `Container`.
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
    return ListTile(
      title: AppText(
        title,
        style: AppTypography.labelMd,
        color: isSelected ? colors.interactivePrimary : colors.textPrimary,
      ),
      selected: isSelected,
      selectedTileColor: colors.surfaceSubdued,
      hoverColor: colors.textPrimary.withValues(
        alpha: AppInteraction.hoverOverlayOpacity,
      ),
      onTap: onTap,
    );
  }
}
