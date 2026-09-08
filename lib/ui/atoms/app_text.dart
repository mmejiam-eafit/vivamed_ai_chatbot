import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

/// Semantic color role — resolves via `context.colors`, so a call site stays
/// `const` and mode-correct without picking a token by appearance.
enum AppTextRole {
  primary,
  secondary,
  tertiary,
  muted,
  onBrand,
  onAccent,
  disabled,
  placeholder,
  link,
  linkVisited,
}

class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    super.key,
    this.style,
    this.color,
    this.role,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  });

  final String text;
  final TextStyle? style;
  final Color? color;
  final AppTextRole? role;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticsLabel;

  static Color _roleColor(AppColorsData colors, AppTextRole role) =>
      switch (role) {
        AppTextRole.primary => colors.textPrimary,
        AppTextRole.secondary => colors.textSecondary,
        AppTextRole.tertiary => colors.textTertiary,
        AppTextRole.muted => colors.textMuted,
        AppTextRole.onBrand => colors.textOnBrand,
        AppTextRole.onAccent => colors.textOnAccent,
        AppTextRole.disabled => colors.textDisabled,
        AppTextRole.placeholder => colors.textPlaceholder,
        AppTextRole.link => colors.textLink,
        AppTextRole.linkVisited => colors.textLinkVisited,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final resolvedColor = color ??
        (role != null ? _roleColor(colors, role!) : colors.textPrimary);
    final effectiveStyle = (style ?? AppTypography.bodyMd).copyWith(
      color: resolvedColor,
    );
    return Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
    );
  }
}
