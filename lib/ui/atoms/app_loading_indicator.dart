import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeWidth = 2.5,
  });

  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color ?? AppColors.interactivePrimary,
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'default — 24 dp', wrapper: previewWrapper)
Widget previewAppLoadingIndicatorDefault() => const AppLoadingIndicator();

@Preview(name: 'large — 48 dp', wrapper: previewWrapper)
Widget previewAppLoadingIndicatorLarge() =>
    const AppLoadingIndicator(size: 48.0);

@Preview(name: 'accent color', wrapper: previewWrapper)
Widget previewAppLoadingIndicatorAccent() =>
    const AppLoadingIndicator(color: AppColors.interactiveAccent);
