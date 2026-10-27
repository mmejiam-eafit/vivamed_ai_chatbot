import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/atoms/app_image.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

/// A study image shown whole, with a caption below it -- never over the
/// pixels, which are evidence (DL §3.7). Fills the height its parent gives
/// it; the image letterboxes inside whatever is left above the caption
/// (DL D-020).
///
/// Sits on the diagnostic canvas, which its template keeps dark in both
/// modes, so the caption reads the dark theme's text tokens there.
class CaptionedImage extends StatelessWidget {
  const CaptionedImage({super.key, required this.url, required this.caption});

  final String url;

  /// What the image is: its recorded labels, and whether it is the one
  /// flagged. Wraps rather than truncates, since a view label is transcribed.
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: AppImage(url: url, fit: BoxFit.contain)),
        const SizedBox(height: AppSpacing.xs),
        AppText(
          caption,
          style: AppTypography.labelMd,
          color: context.colors.textSecondary,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
