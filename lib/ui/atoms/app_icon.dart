import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

/// Semantic color role — resolves via `context.colors`, so a call site stays
/// `const` and mode-correct without picking a token by appearance.
enum AppIconRole { defaultIcon, onBrand, accent, disabled }

class AppIcon extends StatelessWidget {
  const AppIcon(
    this.icon, {
    super.key,
    this.size = 24.0,
    this.color,
    this.role,
    this.semanticLabel,
  });

  final IconData icon;
  final double size;
  final Color? color;
  final AppIconRole? role;
  final String? semanticLabel;

  static Color _roleColor(AppColorsData colors, AppIconRole role) =>
      switch (role) {
        AppIconRole.defaultIcon => colors.icon,
        AppIconRole.onBrand => colors.iconOnBrand,
        AppIconRole.accent => colors.iconAccent,
        AppIconRole.disabled => colors.iconDisabled,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final resolvedColor =
        color ?? (role != null ? _roleColor(colors, role!) : colors.icon);
    return Icon(
      icon,
      size: size,
      color: resolvedColor,
      semanticLabel: semanticLabel,
    );
  }
}
