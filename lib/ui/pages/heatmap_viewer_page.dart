import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/templates/heatmap_viewer_template.dart';

class HeatmapViewerPage extends StatefulWidget {
  const HeatmapViewerPage({super.key});

  @override
  State<HeatmapViewerPage> createState() => _HeatmapViewerPageState();
}

class _HeatmapViewerPageState extends State<HeatmapViewerPage> {
  double _opacity = 0.5;

  @override
  Widget build(BuildContext context) {
    return HeatmapViewerTemplate(
      appBar: AppBar(title: const Text('Heatmap')),
      baseImage: const Placeholder(),
      opacityControl: Slider(
        value: _opacity,
        onChanged: (value) => setState(() => _opacity = value),
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'heatmap viewer', size: Size(390, 844), wrapper: previewWrapperFull)
Widget previewHeatmapViewerPage() => const HeatmapViewerPage();
