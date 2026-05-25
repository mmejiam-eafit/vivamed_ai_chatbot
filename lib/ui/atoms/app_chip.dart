import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onSelected,
    this.onDeleted,
    this.avatar,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final VoidCallback? onDeleted;
  final Widget? avatar;

  @override
  Widget build(BuildContext context) {
    final labelWidget = Text(
      label,
      style: AppTypography.labelMd.copyWith(
        color: selected
            ? AppColors.interactivePrimaryForeground
            : AppColors.textOnAccent,
      ),
    );

    final shape = RoundedRectangleBorder(
      borderRadius: AppRadius.borderButton,
    );

    if (onSelected != null) {
      return FilterChip(
        label: labelWidget,
        selected: selected,
        onSelected: onSelected!,
        onDeleted: onDeleted,
        avatar: avatar,
        backgroundColor: AppColors.surfaceAccent,
        selectedColor: AppColors.interactivePrimary,
        checkmarkColor: AppColors.interactivePrimaryForeground,
        showCheckmark: false,
        shape: shape,
        side: BorderSide.none,
      );
    }

    return Chip(
      label: labelWidget,
      onDeleted: onDeleted,
      avatar: avatar,
      backgroundColor: AppColors.surfaceAccent,
      shape: shape,
      side: BorderSide.none,
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'display chip', wrapper: previewWrapper)
Widget previewAppChipDisplay() => const AppChip(label: 'Radiology');

@Preview(name: 'filter — unselected', wrapper: previewWrapper)
Widget previewAppChipFilterOff() =>
    AppChip(label: 'Chest X-Ray', onSelected: (_) {});

@Preview(name: 'filter — selected', wrapper: previewWrapper)
Widget previewAppChipFilterOn() =>
    AppChip(label: 'Chest X-Ray', selected: true, onSelected: (_) {});

@Preview(name: 'with avatar icon', wrapper: previewWrapper)
Widget previewAppChipAvatar() => const AppChip(
      label: 'CT',
      avatar: Icon(Icons.radio, size: 16),
    );
