import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

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
    if (imageUrl != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl!),
        backgroundColor: AppColors.surfaceBrandSecondary,
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.surfaceBrandSecondary,
      child: initials != null
          ? Text(
              initials!,
              style: AppTypography.labelMd.copyWith(
                color: AppColors.textOnBrand,
              ),
            )
          : Icon(
              Icons.person,
              color: AppColors.textOnBrand,
              size: radius,
            ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'initials — default', wrapper: previewWrapper)
Widget previewAppAvatarInitials() => const AppAvatar(initials: 'JD');

@Preview(name: 'fallback icon', wrapper: previewWrapper)
Widget previewAppAvatarFallback() => const AppAvatar();

@Preview(name: 'large initials', wrapper: previewWrapper)
Widget previewAppAvatarLarge() => const AppAvatar(initials: 'AB', radius: 36.0);
