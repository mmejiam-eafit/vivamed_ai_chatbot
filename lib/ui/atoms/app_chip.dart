import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/focus_ring.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onSelected,
    this.onDeleted,
    this.avatar,
    this.focusNode,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final VoidCallback? onDeleted;
  final Widget? avatar;

  /// Only meaningful when [onSelected] is set — a plain [Chip] (no
  /// [onSelected]) has no primary tap target of its own to focus.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final labelWidget = Text(
      label,
      style: AppTypography.labelMd.copyWith(
        color: selected
            ? colors.interactivePrimaryForeground
            : colors.textOnAccent,
      ),
    );

    final shape = RoundedRectangleBorder(
      borderRadius: AppRadius.borderButton,
    );

    if (onSelected != null) {
      return FocusRing(
        // Mirrors AppButton's ring: the control's own radius plus the
        // offset the ring sits outside it by (DL §8.4).
        borderRadius: BorderRadius.circular(
          AppRadius.button + AppInteraction.focusRingOffset,
        ),
        child: FilterChip(
          label: labelWidget,
          selected: selected,
          onSelected: onSelected!,
          onDeleted: onDeleted,
          avatar: avatar,
          focusNode: focusNode,
          backgroundColor: colors.surfaceAccent,
          selectedColor: colors.interactivePrimary,
          checkmarkColor: colors.interactivePrimaryForeground,
          showCheckmark: false,
          shape: shape,
          side: BorderSide.none,
        ),
      );
    }

    return Chip(
      label: labelWidget,
      onDeleted: onDeleted,
      avatar: avatar,
      backgroundColor: colors.surfaceAccent,
      shape: shape,
      side: BorderSide.none,
    );
  }
}
