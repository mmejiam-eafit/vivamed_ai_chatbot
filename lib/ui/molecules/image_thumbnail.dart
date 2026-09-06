import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/atoms/app_badge.dart';
import 'package:radiologist_helper/ui/atoms/app_image.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

class ImageThumbnail extends StatelessWidget {
  const ImageThumbnail({
    super.key,
    required this.url,
    this.badgeLabel,
    this.width = 80.0,
    this.height = 80.0,
    this.onTap,
  });

  final String url;
  final String? badgeLabel;
  final double width;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderCard,
      child: ClipRRect(
        borderRadius: AppRadius.borderCard,
        child: Stack(
          children: [
            AppImage(
              url: url,
              width: width,
              height: height,
              fit: BoxFit.cover,
            ),
            if (badgeLabel != null)
              Positioned(
                bottom: AppSpacing.xs,
                right: AppSpacing.xs,
                child: AppBadge(label: badgeLabel!),
              ),
          ],
        ),
      ),
    );
  }
}
