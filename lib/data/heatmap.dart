import 'package:flutter/material.dart';

/// Still explicitly a visual stand-in, not gap 19's real perceptual ramp —
/// that stays deferred, blocked on specifying the backend's data contract
/// (per-pixel intensity vs. pre-rendered RGBA, and how alpha/transparency
/// works). This is just enough shape for a page to render *something*.
class HeatmapData {
  const HeatmapData({
    required this.baseImageUrl,
    required this.overlayColor,
    required this.imageAspectRatio,
    this.focusAlignment = Alignment.center,
  });

  final String baseImageUrl;

  /// Width divided by height of the base image. The viewer shows the whole
  /// image at this ratio and lays the overlay out against the same frame, so
  /// neither is cropped to fit the screen (DL D-020). A DICOM image always has
  /// rows and columns, so a backend can supply this with the image.
  final double imageAspectRatio;
  final Color overlayColor;

  /// Where within the lung silhouette the overlay's intensity peaks (see
  /// LungHeatmapOverlay) -- defaults to centered for findings with no
  /// particular side/region.
  final Alignment focusAlignment;
}
