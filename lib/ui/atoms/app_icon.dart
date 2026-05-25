import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

class AppIcon extends StatelessWidget {
  const AppIcon(
    this.icon, {
    super.key,
    this.size = 24.0,
    this.color,
    this.semanticLabel,
  });

  final IconData icon;
  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size,
      color: color ?? AppColors.icon,
      semanticLabel: semanticLabel,
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'default — 24 dp', wrapper: previewWrapper)
Widget previewAppIconDefault() => const AppIcon(Icons.home);

@Preview(name: 'accent color', wrapper: previewWrapper)
Widget previewAppIconAccent() =>
    const AppIcon(Icons.star, color: AppColors.iconAccent);

@Preview(name: 'on-brand color', wrapper: previewWrapper)
Widget previewAppIconOnBrand() =>
    const AppIcon(Icons.person, color: AppColors.iconOnBrand);

@Preview(name: 'large — 48 dp', wrapper: previewWrapper)
Widget previewAppIconLarge() => const AppIcon(Icons.medical_services, size: 48.0);
