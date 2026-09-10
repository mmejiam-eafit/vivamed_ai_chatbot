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

  /// Width of the persistent control rail at expanded and up (DT §9.5).
  static const double _railWidth = 280.0;

  /// Explicit control-bar height at medium — compact keeps its intrinsic
  /// height, this tier pins it (DT §9.5).
  static const double _mediumControlBarHeight = 56.0;

  @override
  Widget build(BuildContext context) {
    final canvas = Stack(
      fit: StackFit.expand,
      children: [
        baseImage,
        if (heatmapOverlay != null) heatmapOverlay!,
      ],
    );

    return Theme(
      data: _forcedDark,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tier = constraints.maxWidth.layoutTier;
          final isRailTier = tier == AppLayoutTier.expanded ||
              tier == AppLayoutTier.ultrawide;

          if (isRailTier) {
            return Scaffold(
              backgroundColor: DiagnosticImageTokens.canvasGround,
              appBar: appBar,
              body: Row(
                children: [
                  Expanded(child: canvas),
                  Container(
                    width: _railWidth,
                    color: DiagnosticImageTokens.canvasGround,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: opacityControl,
                  ),
                ],
              ),
            );
          }

          final controlBar = Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: opacityControl,
          );
          return Scaffold(
            backgroundColor: DiagnosticImageTokens.canvasGround,
            appBar: appBar,
            body: canvas,
            bottomNavigationBar: ColoredBox(
              color: DiagnosticImageTokens.canvasGround,
              child: tier == AppLayoutTier.medium
                  ? SizedBox(height: _mediumControlBarHeight, child: controlBar)
                  : controlBar,
            ),
          );
        },
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
