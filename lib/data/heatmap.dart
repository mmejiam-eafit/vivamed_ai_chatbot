import 'package:flutter/material.dart';

/// Still explicitly a visual stand-in, not gap 19's real perceptual ramp —
/// that stays deferred, blocked on specifying the backend's data contract
/// (per-pixel intensity vs. pre-rendered RGBA, and how alpha/transparency
/// works). This is just enough shape for a page to render *something*.
class HeatmapData {
  const HeatmapData({required this.baseImageUrl, required this.overlayColor});

  final String baseImageUrl;
  final Color overlayColor;
}
