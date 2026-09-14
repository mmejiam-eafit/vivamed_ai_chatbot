import 'package:flutter/material.dart';
import 'package:radiologist_helper/data/heatmap.dart';

const mockDefaultFindingId = 'finding-1';

// Opaque -- the page applies its own Opacity(opacity: sliderValue, ...)
// wrapper on top (HeatmapViewerTemplate's documented contract), so baking an
// alpha in here too would make the two controls fight each other.
//
// baseImageUrl reuses each finding's own case's real chest X-ray (see
// case_mocks.dart's _realCaseImages) rather than an unrelated picsum photo --
// same film Study Review shows, just annotated. focusAlignment roughly
// follows what each finding's name implies, respecting standard chest X-ray
// display convention: the patient's right side renders on the image's
// *left* (confirmed from the source films' own "L" markers).
final _mockHeatmaps = <String, HeatmapData>{
  // case-1 (images/case-1.png) -- Right lower lobe / cardiac silhouette.
  'finding-1': const HeatmapData(
    baseImageUrl: 'lib/data/mocks/images/case-1.png',
    overlayColor: Colors.red,
    focusAlignment: Alignment(-0.5, 0.55), // right lower lobe -> image-left, low
  ),
  'finding-2': const HeatmapData(
    baseImageUrl: 'lib/data/mocks/images/case-1.png',
    overlayColor: Colors.orange,
    focusAlignment: Alignment(-0.1, 0.15), // cardiac silhouette -> mediastinum
  ),
  // case-2 -- abdominal, not chest; keeps the placeholder + centered default.
  'finding-3': const HeatmapData(
    baseImageUrl: 'https://picsum.photos/seed/finding-3/800/800',
    overlayColor: Colors.yellow,
  ),
  // case-3 (images/case-3.png) -- Tension pneumothorax / right upper lobe nodule.
  'finding-4': const HeatmapData(
    baseImageUrl: 'lib/data/mocks/images/case-3.png',
    overlayColor: Colors.red,
    // No side named for this one -- centered/bilateral reads as plausible.
  ),
  'finding-5': const HeatmapData(
    baseImageUrl: 'lib/data/mocks/images/case-3.png',
    overlayColor: Colors.orange,
    focusAlignment: Alignment(-0.5, -0.5), // right upper lobe -> image-left, high
  ),
  // case-6 (images/case-6.png) -- Mild cardiomegaly / resolved consolidation.
  'finding-8': const HeatmapData(
    baseImageUrl: 'lib/data/mocks/images/case-6.png',
    overlayColor: Colors.orange,
    focusAlignment: Alignment(-0.1, 0.1), // cardiomegaly -> mediastinum
  ),
  'finding-9': const HeatmapData(
    baseImageUrl: 'lib/data/mocks/images/case-6.png',
    overlayColor: Colors.yellow,
    focusAlignment: Alignment(-0.5, 0.55), // prior consolidation site, same as finding-1
  ),
};

HeatmapData mockHeatmapFor(String findingId) =>
    _mockHeatmaps[findingId] ?? _mockHeatmaps[mockDefaultFindingId]!;
