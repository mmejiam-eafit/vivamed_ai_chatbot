import 'package:flutter/material.dart';
import 'package:radiologist_helper/data/heatmap.dart';

// FindingItem has no id yet (nothing selects one without real navigation) --
// this is a placeholder key until the flow-wiring pass gives findings one,
// the same forward-flagged gap as CaseSummary had before this pass.
const mockDefaultFindingId = 'finding-1';

// Opaque -- the page applies its own Opacity(opacity: sliderValue, ...)
// wrapper on top (HeatmapViewerTemplate's documented contract), so baking an
// alpha in here too would make the two controls fight each other.
final _mockHeatmaps = <String, HeatmapData>{
  'finding-1': const HeatmapData(
    baseImageUrl: 'https://picsum.photos/seed/finding-1/800/800',
    overlayColor: Colors.red,
  ),
  'finding-2': const HeatmapData(
    baseImageUrl: 'https://picsum.photos/seed/finding-2/800/800',
    overlayColor: Colors.orange,
  ),
  'finding-3': const HeatmapData(
    baseImageUrl: 'https://picsum.photos/seed/finding-3/800/800',
    overlayColor: Colors.yellow,
  ),
};

HeatmapData mockHeatmapFor(String findingId) =>
    _mockHeatmaps[findingId] ?? _mockHeatmaps[mockDefaultFindingId]!;
