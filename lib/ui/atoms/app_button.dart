import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

enum AppButtonVariant { primary, secondary, ghost, iconOnly }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    this.label,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
  }) : assert(
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

  static const _buttonPadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.xl,
    vertical: AppSpacing.md,
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
    final effectiveOnPressed = isLoading ? null : onPressed;

    if (variant == AppButtonVariant.iconOnly) {
      return IconButton(
        onPressed: effectiveOnPressed,
        icon: isLoading
            ? const SizedBox(
                width: AppSpacing.lg,
                height: AppSpacing.lg,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: AppColors.icon,
                ),
              )
            : Icon(icon, color: AppColors.icon),
      );
    }

    return switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.interactivePrimary,
            foregroundColor: AppColors.interactivePrimaryForeground,
            disabledBackgroundColor: AppColors.interactiveDisabled,
            disabledForegroundColor: AppColors.interactiveDisabledForeground,
            textStyle: AppTypography.labelLg,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderButton,
            ),
            padding: _buttonPadding,
          ),
          child: _buildChild(AppColors.interactivePrimaryForeground),
        ),
      AppButtonVariant.secondary => OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.interactiveSecondary,
            foregroundColor: AppColors.interactiveSecondaryForeground,
            disabledForegroundColor: AppColors.interactiveDisabledForeground,
            textStyle: AppTypography.labelLg,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderButton,
            ),
            padding: _buttonPadding,
          ),
          child: _buildChild(AppColors.interactiveSecondaryForeground),
        ),
      AppButtonVariant.ghost => TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.interactiveSecondaryForeground,
            disabledForegroundColor: AppColors.interactiveDisabledForeground,
            textStyle: AppTypography.labelLg,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderButton,
            ),
            padding: _buttonPadding,
          ),
          child: _buildChild(AppColors.interactiveSecondaryForeground),
        ),
      AppButtonVariant.iconOnly => const SizedBox.shrink(), // unreachable
    };
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'primary', wrapper: previewWrapper)
Widget previewAppButtonPrimary() =>
    AppButton(label: 'Confirm', onPressed: () {});

@Preview(name: 'secondary', wrapper: previewWrapper)
Widget previewAppButtonSecondary() => AppButton(
      label: 'Cancel',
      variant: AppButtonVariant.secondary,
      onPressed: () {},
    );

@Preview(name: 'ghost', wrapper: previewWrapper)
Widget previewAppButtonGhost() =>
    AppButton(label: 'Skip', variant: AppButtonVariant.ghost, onPressed: () {});

@Preview(name: 'icon-only', wrapper: previewWrapper)
Widget previewAppButtonIconOnly() => AppButton(
      icon: Icons.send,
      variant: AppButtonVariant.iconOnly,
      onPressed: () {},
    );

@Preview(name: 'primary with icon', wrapper: previewWrapper)
Widget previewAppButtonWithIcon() =>
    AppButton(label: 'Upload', icon: Icons.upload, onPressed: () {});

@Preview(name: 'loading', wrapper: previewWrapper)
Widget previewAppButtonLoading() =>
    AppButton(label: 'Saving…', isLoading: true, onPressed: () {});

@Preview(name: 'disabled', wrapper: previewWrapper)
Widget previewAppButtonDisabled() =>
    const AppButton(label: 'Unavailable', onPressed: null);
