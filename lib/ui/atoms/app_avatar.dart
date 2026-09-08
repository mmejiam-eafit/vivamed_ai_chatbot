import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.radius = 20.0,
  });

  final String? imageUrl;
  final String? initials;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (imageUrl != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl!),
        backgroundColor: colors.surfaceBrandSecondary,
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: colors.surfaceBrandSecondary,
      // Shrinks to fit so long initials survive 200% text scale (DL §8.6).
      child: initials != null
          ? FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxs),
                child: Text(
                  initials!,
                  style: AppTypography.labelMd.copyWith(
                    color: colors.textOnBrand,
                  ),
                ),
              ),
            )
          : Icon(
              Icons.person,
              color: colors.textOnBrand,
              size: radius,
            ),
    );
  }
}
