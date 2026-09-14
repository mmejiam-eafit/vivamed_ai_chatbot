import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radiologist_helper/services/providers.dart';
import 'package:radiologist_helper/ui/atoms/app_image.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/atoms/lung_heatmap_overlay.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/templates/heatmap_viewer_template.dart';

class HeatmapViewerPage extends ConsumerStatefulWidget {
  const HeatmapViewerPage({super.key, required this.findingId});

  final String findingId;

  @override
  ConsumerState<HeatmapViewerPage> createState() => _HeatmapViewerPageState();
}

class _HeatmapViewerPageState extends ConsumerState<HeatmapViewerPage> {
  double _opacity = 0.5;

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(title: const Text('Heatmap'));
    final heatmapAsync = ref.watch(heatmapProvider(widget.findingId));
    final heatmapData = heatmapAsync.value;

    if (heatmapData == null) {
      return Scaffold(
        appBar: appBar,
        body: const Center(child: AppLoadingIndicator()),
      );
    }

    return HeatmapViewerTemplate(
      appBar: appBar,
      baseImage: AppImage(url: heatmapData.baseImageUrl, fit: BoxFit.cover),
      heatmapOverlay: Opacity(
        opacity: _opacity,
        child: LungHeatmapOverlay(
          color: heatmapData.overlayColor,
          focusAlignment: heatmapData.focusAlignment,
        ),
      ),
      opacityControl: Slider(
        value: _opacity,
        onChanged: (value) => setState(() => _opacity = value),
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'heatmap viewer', size: Size(390, 844), wrapper: previewWrapperFull)
Widget previewHeatmapViewerPage() =>
    const HeatmapViewerPage(findingId: 'finding-1');
