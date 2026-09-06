import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
  });

  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.interactivePrimary,
        borderRadius: AppRadius.borderInput,
      ),
      child: Text(
        label,
        style: AppTypography.labelSm.copyWith(
          color: textColor ?? AppColors.interactivePrimaryForeground,
        ),
      ),
    );
  }
}
