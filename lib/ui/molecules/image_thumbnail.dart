import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/atoms/app_badge.dart';
import 'package:radiologist_helper/ui/atoms/app_image.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/focus_ring.dart';

class ImageThumbnail extends StatelessWidget {
  const ImageThumbnail({
    super.key,
    required this.url,
    this.badgeLabel,
    this.width = 80.0,
    this.height = 80.0,
    this.onTap,
    this.focusNode,
  });

  final String url;
  final String? badgeLabel;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return FocusRing(
      // Mirrors AppButton's ring: the control's own radius plus the offset
      // the ring sits outside it by (DL §8.4).
      borderRadius: BorderRadius.circular(
        AppRadius.card + AppInteraction.focusRingOffset,
      ),
      child: InkWell(
        onTap: onTap,
        focusNode: focusNode,
        hoverColor: colors.textPrimary.withValues(
          alpha: AppInteraction.hoverOverlayOpacity,
        ),
        borderRadius: AppRadius.borderCard,
        child: ClipRRect(
          borderRadius: AppRadius.borderCard,
          child: Stack(
            children: [
              // A study is evidence: letterboxed whole on the diagnostic
              // canvas ground, never cropped to fill the square (DL D-020,
              // DT §2.10). The ground is dark in both modes (DL §3.7).
              ColoredBox(
                color: diagnosticCanvasGround,
                child: AppImage(
                  url: url,
                  width: width,
                  height: height,
                  fit: BoxFit.contain,
                ),
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
      ),
    );
  }
}
