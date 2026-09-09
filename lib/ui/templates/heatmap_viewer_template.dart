import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

// The canvas is grounded in DiagnosticImageTokens.canvasGround, which is
// mode-exempt: identical in light and dark. Pixel data is evidence, and the
// perceived contrast of an image depends on its surround, so the surround must
// not move with a user preference (DL §3.7, D-004). It is deliberately not a
// semantic surface token — picking one for being "dark enough" is the
// appearance-based reasoning D-001 forbids.
//
// The chrome around the canvas is forced dark for the same reason, via the
// mechanism design_tokens.md §10.2 specifies for this file.
class HeatmapViewerTemplate extends StatelessWidget {
  const HeatmapViewerTemplate({
    super.key,
    required this.appBar,
    required this.baseImage,
    required this.opacityControl,
    this.heatmapOverlay,
  });

  final PreferredSizeWidget appBar;
  final Widget baseImage;

  /// Pre-wrapped by the page in `Opacity(opacity: value, child: ...)`.
  /// Null when heatmap data has not yet been received from the backend.
  final Widget? heatmapOverlay;

  /// Slider or custom widget; the page owns the opacity state.
  final Widget opacityControl;

  /// Built once — the viewer's chrome is dark in both modes, so this never
  /// depends on the ambient theme (design_tokens.md §10.2, DL §6.5).
  static final ThemeData _forcedDark = buildAppTheme(Brightness.dark);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _forcedDark,
      child: Scaffold(
        backgroundColor: DiagnosticImageTokens.canvasGround,
        appBar: appBar,
        body: Stack(
          fit: StackFit.expand,
          children: [
            baseImage,
            if (heatmapOverlay != null) heatmapOverlay!,
          ],
        ),
        bottomNavigationBar: ColoredBox(
          color: DiagnosticImageTokens.canvasGround,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: opacityControl,
          ),
        ),
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

// Simulates the dark image-viewer canvas; real usage receives a DICOM widget.
Widget _previewBaseImage() => const ColoredBox(
      color: AppColors.surfaceBrandSecondary,
      child: Center(
        child: AppText(
          'Chest X-Ray (PA)',
          style: AppTypography.labelMd,
          color: AppColors.textOnBrand,
        ),
      ),
    );

// Simulates a warm-toned heatmap overlay (the actual widget comes from the backend).
Widget _previewHeatmap(double opacity) => Opacity(
      opacity: opacity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.statusError.withValues(alpha: 0.7),
              AppColors.statusWarning.withValues(alpha: 0.4),
              AppColors.statusInfo.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );

PreferredSizeWidget _previewAppBar(String title) => AppBar(
      backgroundColor: AppColors.surfaceBrand,
      foregroundColor: AppColors.textOnBrand,
      title: Text(title),
    );

@Preview(
    name: 'with heatmap', size: Size(390, 844), wrapper: previewWrapperFull)
Widget previewHeatmapViewerWithOverlay() => HeatmapViewerTemplate(
      appBar: _previewAppBar('Chest XR — Heatmap'),
      baseImage: _previewBaseImage(),
      heatmapOverlay: _previewHeatmap(0.6),
      opacityControl: const SliderTheme(
        data: SliderThemeData(
          activeTrackColor: AppColors.interactivePrimary,
          thumbColor: AppColors.interactivePrimary,
          inactiveTrackColor: AppColors.borderSubdued,
        ),
        child: Slider(value: 0.6, onChanged: null),
      ),
    );

@Preview(
    name: 'without heatmap', size: Size(390, 844), wrapper: previewWrapperFull)
Widget previewHeatmapViewerNoOverlay() => HeatmapViewerTemplate(
      appBar: _previewAppBar('Chest XR'),
      baseImage: _previewBaseImage(),
      opacityControl: const SliderTheme(
        data: SliderThemeData(
          activeTrackColor: AppColors.interactivePrimary,
          thumbColor: AppColors.interactivePrimary,
          inactiveTrackColor: AppColors.borderSubdued,
        ),
        child: Slider(value: 0, onChanged: null),
      ),
    );
