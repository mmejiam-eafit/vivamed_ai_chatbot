import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

// AppColors.surfaceBrand (deep navy #0C2B4E) is used as the background because
// it is the darkest available semantic surface token — appropriate for an
// immersive medical image viewer that conventionally uses a dark canvas.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBrand,
      appBar: appBar,
      body: Stack(
        fit: StackFit.expand,
        children: [
          baseImage,
          if (heatmapOverlay != null) heatmapOverlay!,
        ],
      ),
      bottomNavigationBar: ColoredBox(
        color: AppColors.surfaceBrand,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: opacityControl,
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
