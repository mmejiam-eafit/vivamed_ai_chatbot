import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/atoms/app_badge.dart';
import 'package:radiologist_helper/ui/atoms/app_image.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

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
    return GestureDetector(
      onTap: onTap,
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

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'plain thumbnail', size: Size(80, 80), wrapper: previewWrapper)
Widget previewImageThumbnailPlain() => const ImageThumbnail(
      url: 'https://picsum.photos/80/80',
    );

@Preview(name: 'with findings badge', size: Size(80, 80), wrapper: previewWrapper)
Widget previewImageThumbnailBadge() => const ImageThumbnail(
      url: 'https://picsum.photos/80/80',
      badgeLabel: '3',
    );

@Preview(name: 'large — 160×120', size: Size(160, 120), wrapper: previewWrapper)
Widget previewImageThumbnailLarge() => const ImageThumbnail(
      url: 'https://picsum.photos/160/120',
      width: 160,
      height: 120,
      badgeLabel: '7 findings',
    );
