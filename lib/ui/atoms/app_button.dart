import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/focus_ring.dart';

enum AppButtonVariant { primary, secondary, ghost, iconOnly }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    this.label,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.focusNode,
  })  : assert(
          label != null || icon != null,
          'AppButton requires at least a label or icon',
        ),
        assert(
          variant != AppButtonVariant.iconOnly || icon != null,
          'AppButton with iconOnly variant requires an icon',
        );

  final VoidCallback? onPressed;
  final String? label;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool isLoading;
  final FocusNode? focusNode;

  static const _buttonPadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.xl,
    vertical: AppSpacing.md,
  );

  // 44px floor everywhere — compact/medium require it, expanded permits (but
  // never requires) 32, so one size satisfies both postures (DL §8.5).
  static const _minTouchTarget = Size(
    AppInteraction.minTouchTarget,
    AppInteraction.minTouchTarget,
  );

  static final BorderRadius _ringRadius = BorderRadius.circular(
    AppRadius.button + AppInteraction.focusRingOffset,
  );

  static WidgetStateProperty<MouseCursor> get _cursor =>
      WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? AppInteraction.mouseForbidden
            : AppInteraction.mousePointer,
      );

  Widget _buildChild(Color spinnerColor) {
    if (isLoading) {
      return SizedBox(
        width: AppSpacing.lg,
        height: AppSpacing.lg,
        child: CircularProgressIndicator(strokeWidth: 2.0, color: spinnerColor),
      );
    }
    if (icon != null && label != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(width: AppSpacing.xs),
          Text(label!),
        ],
      );
    }
    if (icon != null) return Icon(icon);
    return Text(label!);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveOnPressed = isLoading ? null : onPressed;

    if (variant == AppButtonVariant.iconOnly) {
      return FocusRing(
        borderRadius: _ringRadius,
        child: IconButton(
          onPressed: effectiveOnPressed,
          focusNode: focusNode,
          constraints: const BoxConstraints(
            minWidth: AppInteraction.minTouchTarget,
            minHeight: AppInteraction.minTouchTarget,
          ),
          style: IconButton.styleFrom(foregroundColor: colors.icon)
              .copyWith(mouseCursor: _cursor),
          icon: isLoading
              ? SizedBox(
                  width: AppSpacing.lg,
                  height: AppSpacing.lg,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: colors.icon,
                  ),
                )
              : Icon(icon, color: colors.icon),
        ),
      );
    }

    return FocusRing(
      borderRadius: _ringRadius,
      child: switch (variant) {
        AppButtonVariant.primary => ElevatedButton(
            onPressed: effectiveOnPressed,
            focusNode: focusNode,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.interactivePrimary,
              foregroundColor: colors.interactivePrimaryForeground,
              disabledBackgroundColor: colors.interactiveDisabled,
              disabledForegroundColor: colors.interactiveDisabledForeground,
              textStyle: AppTypography.labelLg,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.borderButton,
              ),
              padding: _buttonPadding,
              minimumSize: _minTouchTarget,
            ).copyWith(mouseCursor: _cursor),
            child: _buildChild(colors.interactivePrimaryForeground),
          ),
        AppButtonVariant.secondary => OutlinedButton(
            onPressed: effectiveOnPressed,
            focusNode: focusNode,
            style: OutlinedButton.styleFrom(
              backgroundColor: colors.interactiveSecondary,
              foregroundColor: colors.interactiveSecondaryForeground,
              disabledForegroundColor: colors.interactiveDisabledForeground,
              textStyle: AppTypography.labelLg,
              side: BorderSide(color: colors.border),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.borderButton,
              ),
              padding: _buttonPadding,
              minimumSize: _minTouchTarget,
            ).copyWith(mouseCursor: _cursor),
            child: _buildChild(colors.interactiveSecondaryForeground),
          ),
        AppButtonVariant.ghost => TextButton(
            onPressed: effectiveOnPressed,
            focusNode: focusNode,
            style: TextButton.styleFrom(
              foregroundColor: colors.interactiveSecondaryForeground,
              disabledForegroundColor: colors.interactiveDisabledForeground,
              textStyle: AppTypography.labelLg,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.borderButton,
              ),
              padding: _buttonPadding,
              minimumSize: _minTouchTarget,
            ).copyWith(mouseCursor: _cursor),
            child: _buildChild(colors.interactiveSecondaryForeground),
          ),
        AppButtonVariant.iconOnly => const SizedBox.shrink(), // unreachable
      },
    );
  }
}
