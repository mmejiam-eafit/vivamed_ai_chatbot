import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

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
