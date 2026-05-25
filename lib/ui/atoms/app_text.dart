import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    super.key,
    this.style,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  });

  final String text;
  final TextStyle? style;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = (style ?? AppTypography.bodyMd).copyWith(
      color: color ?? AppColors.textPrimary,
    );
    return Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'bodyMd — default', wrapper: previewWrapper)
Widget previewAppTextBody() => const AppText('Body text (default style)');

@Preview(name: 'headingLg', wrapper: previewWrapper)
Widget previewAppTextHeading() =>
    const AppText('Heading large', style: AppTypography.headingLg);

@Preview(name: 'labelMd — accent color', wrapper: previewWrapper)
Widget previewAppTextLabel() => const AppText(
      'Label',
      style: AppTypography.labelMd,
      color: AppColors.textOnAccent,
    );

@Preview(name: 'caption — muted', wrapper: previewWrapper)
Widget previewAppTextCaption() =>
    const AppText('10:42 AM', style: AppTypography.caption, color: AppColors.textMuted);
